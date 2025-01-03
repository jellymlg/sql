CREATE OR REPLACE PACKAGE pkg_user AS
  PROCEDURE create_user(p_username IN VARCHAR2
                       ,p_password IN VARCHAR2);
  PROCEDURE update_password(p_userid       IN NUMBER
                           ,p_new_password IN VARCHAR2);
  PROCEDURE check_login(p_username IN VARCHAR2
                       ,p_password IN VARCHAR2
                       ,p_is_valid OUT BOOLEAN);
  PROCEDURE get_name(p_userid   IN NUMBER
                    ,p_username OUT VARCHAR2);
  PROCEDURE delete_user(p_userid IN NUMBER);
END pkg_user;
/
CREATE OR REPLACE PACKAGE BODY pkg_user AS
  PROCEDURE create_user(p_username IN VARCHAR2
                       ,p_password IN VARCHAR2) IS
    hashed_password VARCHAR2(255);
  BEGIN
    hashed_password := dbms_crypto.hash(utl_i18n.string_to_raw(p_password,
                                                               'AL32UTF8'),
                                        4);
    INSERT INTO users
      (userid
      ,username
      ,password
      ,regdate)
    VALUES
      (user_id_seq.nextval
      ,p_username
      ,hashed_password
      ,SYSDATE);
  EXCEPTION
    WHEN dup_val_on_index THEN
      raise_application_error(-20001,
                              'User ID or User Name already exists.');
    WHEN OTHERS THEN
      raise_application_error(-20002, 'An unexpected error occurred.');
  END create_user;

  PROCEDURE update_password(p_userid       IN NUMBER
                           ,p_new_password IN VARCHAR2) IS
    hashed_password VARCHAR2(255);
  BEGIN
    hashed_password := dbms_crypto.hash(utl_i18n.string_to_raw(p_new_password,
                                                               'AL32UTF8'),
                                        4);
    UPDATE users SET password = hashed_password WHERE userid = p_userid;
    IF SQL%ROWCOUNT = 0
    THEN
      raise_application_error(-20003, 'User ID not found.');
    END IF;
  END update_password;

  PROCEDURE check_login(p_username IN VARCHAR2
                       ,p_password IN VARCHAR2
                       ,p_is_valid OUT BOOLEAN) IS
    stored_password VARCHAR2(255);
    hashed_password VARCHAR2(255);
  BEGIN
    SELECT password
      INTO stored_password
      FROM users
     WHERE username = p_username;
  
    hashed_password := dbms_crypto.hash(utl_i18n.string_to_raw(p_password,
                                                               'AL32UTF8'),
                                        4);
  
    IF stored_password = hashed_password
    THEN
      p_is_valid := TRUE;
    ELSE
      p_is_valid := FALSE;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      p_is_valid := FALSE;
    WHEN OTHERS THEN
      raise_application_error(-20006,
                              'An error occurred during login check.');
  END check_login;

  PROCEDURE get_name(p_userid   IN NUMBER
                    ,p_username OUT VARCHAR2) IS
  BEGIN
    SELECT username INTO p_username FROM users WHERE userid = p_userid;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20004, 'User ID not found.');
  END get_name;

  PROCEDURE delete_user(p_userid IN NUMBER) IS
  BEGIN
    DELETE FROM users WHERE userid = p_userid;
    IF SQL%ROWCOUNT = 0
    THEN
      raise_application_error(-20005, 'User ID not found.');
    END IF;
  END delete_user;
END pkg_user;
/
