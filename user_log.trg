CREATE OR REPLACE TRIGGER user_log_trg
  AFTER INSERT OR UPDATE OR DELETE ON users
  FOR EACH ROW
BEGIN
  IF inserting
  THEN
    INSERT INTO userlog
      (action
      ,newusername
      ,newpassword)
    VALUES
      ('INSERT'
      ,:new.username
      ,:new.password);
  END IF;

  IF updating
  THEN
    INSERT INTO userlog
      (action
      ,newusername
      ,newpassword
      ,oldusername
      ,oldpassword)
    VALUES
      ('UPDATE'
      ,:new.username
      ,:new.password
      ,:old.username
      ,:old.password);
  END IF;

  IF deleting
  THEN
    INSERT INTO userlog
      (action
      ,oldusername
      ,oldpassword)
    VALUES
      ('DELETE'
      ,:old.username
      ,:old.password);
  END IF;
END;
/
