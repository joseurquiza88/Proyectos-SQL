CREATE DATABASE olist;

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
drop table prueba;

COPY customers
FROM 'D:/Josefina/Proyectos/Datascience/SQL/olist/data/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

SELECT *
FROM customers
LIMIT 10;