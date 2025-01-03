DROP USER ADMIN CASCADE;

EXECUTE DBMS_OUTPUT.PUT_LINE('Creating user ADMIN...');
@create_user.sql

EXECUTE DBMS_OUTPUT.PUT_LINE('Creating Tables...');
@create_tables.sql

EXECUTE DBMS_OUTPUT.PUT_LINE('Adding constraints...');
@add_constraints.sql

EXECUTE DBMS_OUTPUT.PUT_LINE('Creating package user...');
@pkg_user.pks

EXECUTE DBMS_OUTPUT.PUT_LINE('Creating package build...');
@pkg_build.pks

EXECUTE DBMS_OUTPUT.PUT_LINE('Adding trigger for product supply integrity...');
@product_supply.trg

EXECUTE DBMS_OUTPUT.PUT_LINE('Adding trigger for user logging...');
@user_log.trg

EXECUTE DBMS_OUTPUT.PUT_LINE('Loading tables...');
@load_tables.sql

EXECUTE DBMS_OUTPUT.PUT_LINE('Done.');