CREATE OR REPLACE PACKAGE pkg_build AS
  TYPE t_cpu IS TABLE OF cpu%ROWTYPE;
  TYPE t_case IS TABLE OF pccase%ROWTYPE;
  TYPE t_psu IS TABLE OF psu%ROWTYPE;
  TYPE t_mobo IS TABLE OF mobo%ROWTYPE;
  TYPE t_gpu IS TABLE OF gpu%ROWTYPE;
  TYPE t_ram IS TABLE OF ram%ROWTYPE;
  FUNCTION avg_wattage(f_cpuid NUMBER
                      ,f_gpuid NUMBER) RETURN NUMBER;
  FUNCTION recomm_psu(f_wattage NUMBER
                     ,f_mineff  NUMBER DEFAULT 80) RETURN SYS_REFCURSOR;
  FUNCTION calc_price(f_buildid NUMBER) RETURN NUMBER;
  PROCEDURE recomm_missing(p_cpuid         IN NUMBER
                          ,p_caseid        IN NUMBER
                          ,p_psuid         IN NUMBER
                          ,p_moboid        IN NUMBER
                          ,p_gpuid         IN NUMBER
                          ,p_ramid         IN NUMBER
                          ,p_cpu_cursor    OUT SYS_REFCURSOR
                          ,p_case_cursor   OUT SYS_REFCURSOR
                          ,p_psu_cursor    OUT SYS_REFCURSOR
                          ,p_mobo_cursor   OUT SYS_REFCURSOR
                          ,p_gpu_cursor    OUT SYS_REFCURSOR
                          ,p_ram_cursor    OUT SYS_REFCURSOR);
END pkg_build;
/
CREATE OR REPLACE PACKAGE BODY pkg_build AS
  FUNCTION avg_wattage(f_cpuid NUMBER
                      ,f_gpuid NUMBER) RETURN NUMBER IS
    cpuwattage NUMBER;
    gpuwattage NUMBER;
  BEGIN
    SELECT wattage INTO cpuwattage FROM cpu WHERE cpuid = f_cpuid;
    SELECT wattage INTO gpuwattage FROM gpu WHERE gpuid = f_gpuid;
    RETURN 100 + cpuwattage + gpuwattage;
  END avg_wattage;

  FUNCTION recomm_psu(f_wattage NUMBER
                     ,f_mineff  NUMBER) RETURN SYS_REFCURSOR IS
    psu_table SYS_REFCURSOR;
  BEGIN
    OPEN psu_table FOR
      SELECT psu.*
        FROM psu
       INNER JOIN psuquality pq
          ON psu.quality = pq.psuqualityid
       WHERE wattage >= f_wattage
         AND efficiency >= f_mineff;
    RETURN psu_table;
  END recomm_psu;

  FUNCTION calc_price(f_buildid NUMBER) RETURN NUMBER IS
    build           builds%ROWTYPE;
    price_cpu       NUMBER;
    price_pccase    NUMBER;
    price_psu       NUMBER;
    price_mobo      NUMBER;
    price_gpu       NUMBER;
    price_ram       NUMBER;
  BEGIN
    SELECT * INTO build FROM builds WHERE buildid = f_buildid;
    SELECT MIN(price)
      INTO price_cpu
      FROM supply
     WHERE productid = build.cpu
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'CPU');
    SELECT MIN(price)
      INTO price_pccase
      FROM supply
     WHERE productid = build.pccase
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'CASE');
    SELECT MIN(price)
      INTO price_psu
      FROM supply
     WHERE productid = build.psu
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'PSU');
    SELECT MIN(price)
      INTO price_mobo
      FROM supply
     WHERE productid = build.mobo
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'MOBO');
    SELECT MIN(price)
      INTO price_gpu
      FROM supply
     WHERE productid = build.gpu
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'GPU');
    SELECT MIN(price)
      INTO price_ram
      FROM supply
     WHERE productid = build.ram
       AND producttypeid =
           (SELECT producttypeid FROM producttype WHERE productname = 'RAM');
    RETURN price_cpu + price_pccase + price_psu + price_mobo + price_gpu + price_ram;
  END calc_price;

  PROCEDURE recomm_missing(p_cpuid         IN NUMBER
                          ,p_caseid        IN NUMBER
                          ,p_psuid         IN NUMBER
                          ,p_moboid        IN NUMBER
                          ,p_gpuid         IN NUMBER
                          ,p_ramid         IN NUMBER
                          ,p_cpu_cursor    OUT SYS_REFCURSOR
                          ,p_case_cursor   OUT SYS_REFCURSOR
                          ,p_psu_cursor    OUT SYS_REFCURSOR
                          ,p_mobo_cursor   OUT SYS_REFCURSOR
                          ,p_gpu_cursor    OUT SYS_REFCURSOR
                          ,p_ram_cursor    OUT SYS_REFCURSOR) IS
    cpu_table         t_cpu;
    case_table        t_case;
    psu_table         t_psu;
    mobo_table        t_mobo;
    gpu_table         t_gpu;
    ram_table         t_ram;
    recomm_psu_cursor SYS_REFCURSOR;
  BEGIN
    SELECT * BULK COLLECT INTO cpu_table FROM cpu;
    SELECT * BULK COLLECT INTO case_table FROM pccase;
    SELECT * BULK COLLECT INTO psu_table FROM psu;
    SELECT * BULK COLLECT INTO mobo_table FROM mobo;
    SELECT * BULK COLLECT INTO gpu_table FROM gpu;
    SELECT * BULK COLLECT INTO ram_table FROM ram;
    IF p_cpuid IS NULL
    THEN
      IF p_moboid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO cpu_table
          FROM TABLE(cpu_table)
         WHERE socketid =
               (SELECT socketid FROM mobo WHERE moboid = p_moboid);
      END IF;
      IF p_ramid IS NOT NULL
      THEN
        SELECT cput.*
          BULK COLLECT
          INTO cpu_table
          FROM TABLE(cpu_table) cput
         INNER JOIN cpuramcomp
            ON cput.cpuid = cpuramcomp.cpuid
         WHERE speedmhz =
               (SELECT ramspeedmhz FROM ram WHERE ramid = p_ramid);
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO cpu_table
        FROM TABLE(cpu_table)
       WHERE cpuid = p_cpuid;
    END IF;
    IF p_caseid IS NULL
    THEN
      IF p_moboid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO case_table
          FROM TABLE(case_table)
         WHERE formid <= (SELECT formid FROM mobo WHERE moboid = p_moboid);
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO case_table
        FROM TABLE(case_table)
       WHERE caseid = p_caseid;
    END IF;
    IF p_psuid IS NULL
    THEN
      IF p_cpuid IS NOT NULL
         AND p_gpuid IS NOT NULL
      THEN
        recomm_psu_cursor := recomm_psu(avg_wattage(p_cpuid, p_gpuid));
        FETCH recomm_psu_cursor BULK COLLECT
          INTO psu_table;
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO psu_table
        FROM TABLE(psu_table)
       WHERE psuid = p_psuid;
    END IF;
    IF p_moboid IS NULL
    THEN
      IF p_cpuid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO mobo_table
          FROM TABLE(mobo_table)
         WHERE socketid = (SELECT socketid FROM cpu WHERE cpuid = p_cpuid);
      END IF;
      IF p_caseid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO mobo_table
          FROM TABLE(mobo_table)
         WHERE formid >=
               (SELECT formid FROM pccase WHERE caseid = p_caseid);
      END IF;
      IF p_ramid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO mobo_table
          FROM TABLE(mobo_table)
         WHERE supportedramtypeid =
               (SELECT ramtypeid FROM ram WHERE ramid = p_ramid)
           AND ramslotcount >=
               (SELECT stickcount FROM ram WHERE ramid = p_ramid);
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO mobo_table
        FROM TABLE(mobo_table)
       WHERE moboid = p_moboid;
    END IF;
    IF p_gpuid IS NULL
    THEN
      IF p_moboid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO gpu_table
          FROM TABLE(gpu_table)
         WHERE pciportid IN (SELECT pciid
                               FROM mobo
                              INNER JOIN mobopci
                                 ON mobo.moboid = mobopci.moboid
                              WHERE mobo.moboid = p_moboid);
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO gpu_table
        FROM TABLE(gpu_table)
       WHERE gpuid = p_gpuid;
    END IF;
    IF p_ramid IS NULL
    THEN
      IF p_moboid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO ram_table
          FROM TABLE(ram_table)
         WHERE ramtypeid =
               (SELECT supportedramtypeid FROM mobo WHERE moboid = p_moboid)
           AND stickcount <=
               (SELECT ramslotcount FROM mobo WHERE moboid = p_moboid);
      END IF;
      IF p_cpuid IS NOT NULL
      THEN
        SELECT *
          BULK COLLECT
          INTO ram_table
          FROM TABLE(ram_table)
         WHERE ramtypeid IN
               (SELECT ramtypeid FROM cpuramcomp WHERE cpuid = p_cpuid)
           AND ramspeedmhz IN
               (SELECT speedmhz FROM cpuramcomp WHERE cpuid = p_cpuid);
      END IF;
    ELSE
      SELECT *
        BULK COLLECT
        INTO ram_table
        FROM TABLE(ram_table)
       WHERE ramid = p_ramid;
    END IF;
  END recomm_missing;
END pkg_build;
/
