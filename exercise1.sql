CREATE USER john;
ALTER USER john WITH PASSWORD 'passw0rd';
GRANT CREATE on DATABASE testdb to john;
CREATE SCHEMA sales;
GRANT USAGE on SCHEMA sales to john;
CREATE TABLE customers ();
GRANT SELECT, INSERT on TABLE customers to john;
SET SEARCH_PATH to sales;
CREATE TABLE orders();
GRANT SELECT on TABLE orders to john;
CREATE ROLE sales_manager;
GRANT CREATE on DATABASE testdb to sales_manager;
SET SEARCH_PATH to public;
GRANT SELECT, INSERT, UPDATE, DELETE on TABLE customers to sales_manager;
REVOKE SELECT on TABLE customers from john;

