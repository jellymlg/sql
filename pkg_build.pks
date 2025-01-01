CREATE OR REPLACE PACKAGE pkg_build AS
    TYPE t_CPU IS TABLE OF CPU%ROWTYPE;
    TYPE t_Case IS TABLE OF PCCase%ROWTYPE;
    TYPE t_PSU IS TABLE OF PSU%ROWTYPE;
    TYPE t_CPUCooler IS TABLE OF CPUCooler%ROWTYPE;
    TYPE t_Mobo IS TABLE OF Mobo%ROWTYPE;
    TYPE t_GPU IS TABLE OF GPU%ROWTYPE;
    TYPE t_RAM IS TABLE OF RAM%ROWTYPE;
    FUNCTION avg_wattage(
        f_cpuId NUMBER,
        f_gpuId NUMBER
    ) RETURN NUMBER;
    FUNCTION recomm_PSU(
        f_wattage NUMBER,
        f_minEff NUMBER DEFAULT 80
    ) RETURN SYS_REFCURSOR;
    FUNCTION calc_price(
        f_buildId NUMBER
    ) RETURN NUMBER;
    PROCEDURE recomm_missing(
        p_cpuId IN NUMBER,
        p_caseId IN NUMBER,
        p_psuId IN NUMBER,
        p_coolerId IN NUMBER,
        p_moboId IN NUMBER,
        p_gpuId IN NUMBER,
        p_ramId IN NUMBER,
        p_cpu_cursor OUT SYS_REFCURSOR,
        p_case_cursor OUT SYS_REFCURSOR,
        p_psu_cursor OUT SYS_REFCURSOR,
        p_cooler_cursor OUT SYS_REFCURSOR,
        p_mobo_cursor OUT SYS_REFCURSOR,
        p_gpu_cursor OUT SYS_REFCURSOR,
        p_ram_cursor OUT SYS_REFCURSOR
    );
END pkg_build;
/
CREATE OR REPLACE PACKAGE BODY pkg_build AS
    FUNCTION avg_wattage(
        f_cpuId NUMBER,
        f_gpuId NUMBER
    ) RETURN NUMBER IS
        cpuWattage NUMBER;
        gpuWattage NUMBER;
    BEGIN
        SELECT wattage INTO cpuWattage FROM CPU WHERE CPUId = f_cpuId;
        SELECT wattage INTO gpuWattage FROM GPU WHERE GPUId = f_gpuId;
        RETURN 100 + cpuWattage + gpuWattage;
    END avg_wattage;

    FUNCTION recomm_PSU(
        f_wattage NUMBER,
        f_minEff NUMBER
    ) RETURN SYS_REFCURSOR IS
        psu_table SYS_REFCURSOR;
    BEGIN
        OPEN psu_table FOR
        SELECT PSU.* FROM PSU INNER JOIN PSUQuality pq ON PSU.quality = pq.PSUQualityId
        WHERE wattage >= f_wattage AND efficiency >= f_minEff;
        RETURN psu_table;
    END recomm_PSU;

    FUNCTION calc_price(
        f_buildId NUMBER
    ) RETURN NUMBER IS
        build Builds%ROWTYPE;
        price_cpu NUMBER;
        price_pccase NUMBER;
        price_psu NUMBER;
        price_cpuCooler NUMBER;
        price_mobo NUMBER;
        price_gpu NUMBER;
        price_ram NUMBER;
    BEGIN
        SELECT * INTO build FROM Builds WHERE buildId = f_buildId;
        SELECT MIN(price) INTO price_cpu FROM Supply WHERE productId = build.cpu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'CPU');
        SELECT MIN(price) INTO price_pccase FROM Supply WHERE productId = build.pccase AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'CASE');
        SELECT MIN(price) INTO price_psu FROM Supply WHERE productId = build.psu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'PSU');
        SELECT MIN(price) INTO price_cpuCooler FROM Supply WHERE productId = build.cpuCooler AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'COOLER');
        SELECT MIN(price) INTO price_mobo FROM Supply WHERE productId = build.mobo AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'MOBO');
        SELECT MIN(price) INTO price_gpu FROM Supply WHERE productId = build.gpu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'GPU');
        SELECT MIN(price) INTO price_ram FROM Supply WHERE productId = build.ram AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'RAM');
        RETURN price_cpu + price_pccase + price_psu + price_cpuCooler + price_mobo + price_gpu + price_ram;
    END calc_price;

    PROCEDURE recomm_missing(
        p_cpuId IN NUMBER,
        p_caseId IN NUMBER,
        p_psuId IN NUMBER,
        p_coolerId IN NUMBER,
        p_moboId IN NUMBER,
        p_gpuId IN NUMBER,
        p_ramId IN NUMBER,
        p_cpu_cursor OUT SYS_REFCURSOR,
        p_case_cursor OUT SYS_REFCURSOR,
        p_psu_cursor OUT SYS_REFCURSOR,
        p_cooler_cursor OUT SYS_REFCURSOR,
        p_mobo_cursor OUT SYS_REFCURSOR,
        p_gpu_cursor OUT SYS_REFCURSOR,
        p_ram_cursor OUT SYS_REFCURSOR
    ) IS
        cpu_table t_CPU;
        case_table t_Case;
        psu_table t_PSU;
        cooler_table t_CPUCooler;
        mobo_table t_Mobo;
        gpu_table t_GPU;
        ram_table t_RAM;
        recomm_psu_cursor SYS_REFCURSOR;
    BEGIN
        SELECT * BULK COLLECT INTO cpu_table FROM CPU;
        SELECT * BULK COLLECT INTO case_table FROM PCCase;
        SELECT * BULK COLLECT INTO psu_table FROM PSU;
        SELECT * BULK COLLECT INTO cooler_table FROM CPUCooler;
        SELECT * BULK COLLECT INTO mobo_table FROM Mobo;
        SELECT * BULK COLLECT INTO gpu_table FROM GPU;
        SELECT * BULK COLLECT INTO ram_table FROM RAM;
        IF p_cpuId IS NULL THEN
            IF p_moboId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO cpu_table FROM TABLE(cpu_table)
                WHERE socketId = (SELECT socketId FROM Mobo WHERE MoboId = p_moboId);
            END IF;
            IF p_ramId IS NOT NULL THEN
                SELECT cput.* BULK COLLECT INTO cpu_table FROM TABLE(cpu_table) cput
                INNER JOIN CPURAMComp ON cput.CPUId = CPURAMComp.CPUId
                WHERE SpeedMHZ = (SELECT RAMSpeedMHZ FROM RAM WHERE RAMId = p_ramId);
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO cpu_table FROM TABLE(cpu_table) WHERE CPUId = p_cpuId;
        END IF;
        IF p_caseId IS NULL THEN
            IF p_moboId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO case_table FROM TABLE(case_table)
                WHERE formId <= (SELECT formId FROM Mobo WHERE MoboId = p_moboId);
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO case_table FROM TABLE(case_table) WHERE CaseId = p_caseId;
        END IF;
        IF p_psuId IS NULL THEN
            IF p_cpuId IS NOT NULL AND p_gpuId IS NOT NULL THEN
                recomm_psu_cursor := recomm_PSU(avg_wattage(p_cpuId, p_gpuId));
                FETCH recomm_psu_cursor BULK COLLECT INTO psu_table;
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO psu_table FROM TABLE(psu_table) WHERE PSUId = p_psuId;
        END IF;
        IF p_coolerId IS NULL THEN
            IF p_moboId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO cooler_table FROM TABLE(cooler_table)
                WHERE socketId = (SELECT socketId FROM Mobo WHERE MoboId = p_moboId);
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO cooler_table FROM TABLE(cooler_table) WHERE CPUCoolerId = p_coolerId;
        END IF;
        IF p_moboId IS NULL THEN
            IF p_cpuId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO mobo_table FROM TABLE(mobo_table)
                WHERE socketId = (SELECT socketId FROM CPU WHERE CPUId = p_cpuId);
            END IF;
            IF p_caseId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO mobo_table FROM TABLE(mobo_table)
                WHERE formId >= (SELECT formId FROM PCCase WHERE CaseId = p_caseId);
            END IF;
            IF p_ramId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO mobo_table FROM TABLE(mobo_table)
                WHERE supportedRAMTypeId = (SELECT RAMTypeId FROM RAM WHERE RAMId = p_ramId)
                AND RAMSlotCount >= (SELECT stickCount FROM RAM WHERE RAMId = p_ramId);
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO mobo_table FROM TABLE(mobo_table) WHERE MoboId = p_moboId;
        END IF;
        IF p_gpuId IS NULL THEN
            IF p_moboId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO gpu_table FROM TABLE(gpu_table) WHERE PCIPortId IN (
                    SELECT PCIId FROM Mobo INNER JOIN MoboPCI ON Mobo.MoboId = MoboPCI.MoboId
                    WHERE Mobo.MoboId = p_moboId
                );
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO gpu_table FROM TABLE(gpu_table) WHERE GPUId = p_gpuId;
        END IF;
        IF p_ramId IS NULL THEN
            IF p_moboId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO ram_table FROM TABLE(ram_table)
                WHERE RAMTypeId = (SELECT supportedRAMTypeId FROM Mobo WHERE MoboId = p_moboId)
                AND stickCount <= (SELECT RAMSlotCount FROM Mobo WHERE MoboId = p_moboId);
            END IF;
            IF p_cpuId IS NOT NULL THEN
                SELECT * BULK COLLECT INTO ram_table FROM TABLE(ram_table)
                WHERE RAMTypeId IN (SELECT RAMTypeId FROM CPURAMComp WHERE CPUId = p_cpuId)
                AND RAMSpeedMHZ IN (SELECT SpeedMHZ FROM CPURAMComp WHERE CPUId = p_cpuId);
            END IF;
        ELSE
            SELECT * BULK COLLECT INTO ram_table FROM TABLE(ram_table) WHERE RAMId = p_ramId;
        END IF;
    END recomm_missing;
END pkg_build;