CREATE OR REPLACE TRIGGER product_supply_trg
  BEFORE INSERT OR UPDATE ON supply
  FOR EACH ROW
DECLARE
  product_exists  NUMBER;
  producttypename VARCHAR2(50);
BEGIN
  SELECT productname
    INTO producttypename
    FROM producttype
   WHERE producttypeid = :new.producttypeid;

  IF producttypename = 'CPU'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM cpu
     WHERE cpuid = :new.productid;
  ELSIF producttypename = 'RAM'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM ram
     WHERE ramid = :new.productid;
  ELSIF producttypename = 'MOBO'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM mobo
     WHERE moboid = :new.productid;
  ELSIF producttypename = 'COOLER'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM cpucooler
     WHERE cpucoolerid = :new.productid;
  ELSIF producttypename = 'GPU'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM gpu
     WHERE gpuid = :new.productid;
  ELSIF producttypename = 'CASE'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM pccase
     WHERE caseid = :new.productid;
  ELSIF producttypename = 'PSU'
  THEN
    SELECT COUNT(*)
      INTO product_exists
      FROM psu
     WHERE psuid = :new.productid;
  ELSE
    product_exists := 0;
  END IF;

  IF product_exists = 0
  THEN
    raise_application_error(-20000,
                            'Invalid productTypeId or productId does not exist.');
  END IF;
END;
/
