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
        SELECT MIN(price) INTO price_cpu FROM Supply WHERE productId = build.cpu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'CPU');
        SELECT MIN(price) INTO price_pccase FROM Supply WHERE productId = build.pccase AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'CASE');
        SELECT MIN(price) INTO price_psu FROM Supply WHERE productId = build.psu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'PSU');
        SELECT MIN(price) INTO price_cpuCooler FROM Supply WHERE productId = build.cpuCooler AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'COOLER');
        SELECT MIN(price) INTO price_mobo FROM Supply WHERE productId = build.mobo AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'MOBO');
        SELECT MIN(price) INTO price_gpu FROM Supply WHERE productId = build.gpu AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'GPU');
        SELECT MIN(price) INTO price_ram FROM Supply WHERE productId = build.ram AND productTypeId = (SELECT productTypeId FROM ProductType WHERE productName = 'RAM');
        RETURN price_cpu + price_pccase + price_psu + price_cpuCooler + price_mobo + price_gpu + price_ram;
    END calc_price;
END pkg_build;