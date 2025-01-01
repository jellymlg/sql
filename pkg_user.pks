CREATE SEQUENCE user_id_seq START WITH 2365;

CREATE OR REPLACE PACKAGE pkg_user AS
    PROCEDURE create_user(
        p_userName IN VARCHAR2,
        p_password IN VARCHAR2
    );
    PROCEDURE update_password(
        p_userId IN NUMBER,
        p_new_password IN VARCHAR2
    );
    PROCEDURE check_login(
        p_userName IN VARCHAR2,
        p_password IN VARCHAR2,
        p_is_valid OUT BOOLEAN
    );
    PROCEDURE get_name(
        p_userId IN NUMBER,
        p_userName OUT VARCHAR2
    );
    PROCEDURE delete_user(
        p_userId IN NUMBER
    );
END pkg_user;
/
CREATE OR REPLACE PACKAGE BODY pkg_user AS
    PROCEDURE create_user(
        p_userName IN VARCHAR2,
        p_password IN VARCHAR2
    ) IS
        hashed_password VARCHAR2(255);
    BEGIN
        hashed_password := DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'), 4);
        INSERT INTO Users (userId, userName, password, regDate)
        VALUES (user_id_seq.NEXTVAL, p_userName, hashed_password, SYSDATE);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20001, 'User ID or User Name already exists.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred.');
    END create_user;

    PROCEDURE update_password(
        p_userId IN NUMBER,
        p_new_password IN VARCHAR2
    ) IS
        hashed_password VARCHAR2(255);
    BEGIN
        hashed_password := DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_new_password, 'AL32UTF8'), 4);
        UPDATE Users
        SET password = hashed_password
        WHERE userId = p_userId;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'User ID not found.');
        END IF;
    END update_password;

    PROCEDURE check_login(
        p_userName IN VARCHAR2,
        p_password IN VARCHAR2,
        p_is_valid OUT BOOLEAN
    ) IS
        stored_password VARCHAR2(255);
        hashed_password VARCHAR2(255);
    BEGIN
        SELECT password
        INTO stored_password
        FROM Users
        WHERE userName = p_userName;

        hashed_password := DBMS_CRYPTO.HASH(UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'), 4);

        IF stored_password = hashed_password THEN
            p_is_valid := TRUE;
        ELSE
            p_is_valid := FALSE;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_is_valid := FALSE;
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20006, 'An error occurred during login check.');
    END check_login;

    PROCEDURE get_name(
        p_userId IN NUMBER,
        p_userName OUT VARCHAR2
    ) IS
    BEGIN
        SELECT userName
        INTO p_userName
        FROM Users
        WHERE userId = p_userId;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'User ID not found.');
    END get_name;

    PROCEDURE delete_user(
        p_userId IN NUMBER
    ) IS
    BEGIN
        DELETE FROM Users
        WHERE userId = p_userId;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20005, 'User ID not found.');
        END IF;
    END delete_user;
END pkg_user;