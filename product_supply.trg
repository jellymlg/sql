CREATE OR REPLACE TRIGGER product_supply_trg
BEFORE INSERT OR UPDATE ON Supply
FOR EACH ROW
DECLARE
    product_exists NUMBER;
BEGIN
    IF :new.productTypeId = 1 THEN
        SELECT COUNT(*) INTO product_exists FROM CPU WHERE CPUId = :new.productId;
    ELSIF :new.productTypeId = 2 THEN
        SELECT COUNT(*) INTO product_exists FROM RAM WHERE RAMId = :new.productId;
    ELSIF :new.productTypeId = 3 THEN
        SELECT COUNT(*) INTO product_exists FROM Mobo WHERE MoboId = :new.productId;
    ELSIF :new.productTypeId = 4 THEN
        SELECT COUNT(*) INTO product_exists FROM CPUCooler WHERE CPUCoolerId = :new.productId;
    ELSIF :new.productTypeId = 5 THEN
        SELECT COUNT(*) INTO product_exists FROM GPU WHERE GPUId = :new.productId;
    ELSIF :new.productTypeId = 6 THEN
        SELECT COUNT(*) INTO product_exists FROM PCCase WHERE CaseId = :new.productId;
    ELSIF :new.productTypeId = 7 THEN
        SELECT COUNT(*) INTO product_exists FROM PSU WHERE PSUId = :new.productId;
    ELSE
        product_exists := 0;
    END IF;

    IF product_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Invalid productTypeId or productId does not exist.');
    END IF;
END;