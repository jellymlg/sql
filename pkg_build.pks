CREATE OR REPLACE PACKAGE pkg_build AS
    FUNCTION avg_wattage(
        f_cpuId NUMBER,
        f_gpuId NUMBER
    ) RETURN NUMBER;
    FUNCTION recomm_PSU(
        f_wattage NUMBER,
        f_minEff NUMBER DEFAULT 80
    ) RETURN NUMBER;
    FUNCTION calc_price(
        f_buildId NUMBER
    ) RETURN NUMBER;
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
    ) RETURN NUMBER IS
        psuId NUMBER;
    BEGIN
        SELECT PSUId INTO psuId FROM PSU INNER JOIN PSUQuality pq ON PSU.quality = pq.PSUQualityId
        WHERE wattage >= f_wattage AND efficiency >= f_minEff;
        RETURN psuId;
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
        SELECT price INTO price_cpu FROM CPU WHERE CPUId = build.cpu;
        SELECT price INTO price_pccase FROM PCCase WHERE CaseId = build.pccase;
        SELECT price INTO price_psu FROM PSU WHERE PSUId = build.psu;
        SELECT price INTO price_cpuCooler FROM CPUCooler WHERE CPUCoolerId = build.cpuCooler;
        SELECT price INTO price_mobo FROM Mobo WHERE MoboId = build.mobo;
        SELECT price INTO price_gpu FROM GPU WHERE GPUId = build.gpu;
        SELECT price INTO price_ram FROM RAM WHERE RAMId = build.ram;
        RETURN price_cpu + price_pccase + price_psu + price_cpuCooler + price_mobo + price_gpu + price_ram;
    END calc_price;
END pkg_build;