CREATE OR REPLACE TRIGGER user_log_trg
  AFTER INSERT OR UPDATE OR DELETE ON users
  FOR EACH ROW
BEGIN
  IF inserting
  THEN
    INSERT INTO userlog
      (logId
      ,action
      ,newusername
      ,newpassword)
    VALUES
      (userlog_id_seq.NEXTVAL
      ,'INSERT'
      ,:new.username
      ,:new.password);
  END IF;

  IF updating
  THEN
    INSERT INTO userlog
      (logId
      ,action
      ,newusername
      ,newpassword
      ,oldusername
      ,oldpassword)
    VALUES
      (userlog_id_seq.NEXTVAL
      ,'UPDATE'
      ,:new.username
      ,:new.password
      ,:old.username
      ,:old.password);
  END IF;

  IF deleting
  THEN
    INSERT INTO userlog
      (logId
      ,action
      ,oldusername
      ,oldpassword)
    VALUES
      (userlog_id_seq.NEXTVAL
      ,'DELETE'
      ,:old.username
      ,:old.password);
  END IF;
END;
/
