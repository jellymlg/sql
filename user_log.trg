CREATE OR REPLACE TRIGGER user_log_trg
AFTER INSERT OR UPDATE OR DELETE ON Users
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO UserLog (action, newUserName, newPassword)
        VALUES ('INSERT', :new.userName, :new.password);
    END IF;

    IF UPDATING THEN
        INSERT INTO UserLog (action, newUserName, newPassword, oldUserName, oldPassWord)
        VALUES ('UPDATE', :new.userName, :new.password, :old.userName, :old.password);
    END IF;

    IF DELETING THEN
        INSERT INTO UserLog (action, oldUserName, oldPassword)
        VALUES ('DELETE', :old.userName, :old.password);
    END IF;
END;