CREATE OR REPLACE TRIGGER product_supply_trg
BEFORE INSERT OR UPDATE ON Supply
FOR EACH ROW
DECLARE
    product_exists NUMBER;
    productTypeName VARCHAR2(50);
BEGIN
    SELECT productName INTO productTypeName FROM ProductType WHERE productTypeId = :new.productTypeId;

    IF productTypeName = 'CPU' THEN
        SELECT COUNT(*) INTO product_exists FROM CPU WHERE CPUId = :new.productId;
    ELSIF productTypeName = 'RAM' THEN
        SELECT COUNT(*) INTO product_exists FROM RAM WHERE RAMId = :new.productId;
    ELSIF productTypeName = 'MOBO' THEN
        SELECT COUNT(*) INTO product_exists FROM Mobo WHERE MoboId = :new.productId;
    ELSIF productTypeName = 'COOLER' THEN
        SELECT COUNT(*) INTO product_exists FROM CPUCooler WHERE CPUCoolerId = :new.productId;
    ELSIF productTypeName = 'GPU' THEN
        SELECT COUNT(*) INTO product_exists FROM GPU WHERE GPUId = :new.productId;
    ELSIF productTypeName = 'CASE' THEN
        SELECT COUNT(*) INTO product_exists FROM PCCase WHERE CaseId = :new.productId;
    ELSIF productTypeName = 'PSU' THEN
        SELECT COUNT(*) INTO product_exists FROM PSU WHERE PSUId = :new.productId;
    ELSE
        product_exists := 0;
    END IF;

    IF product_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Invalid productTypeId or productId does not exist.');
    END IF;
END;