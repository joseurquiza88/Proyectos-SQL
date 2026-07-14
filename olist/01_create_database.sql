CREATE DATABASE olist;

-- Tabla customers 
-- Esta relacionada con los clientes
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Se suben los registros desde los csv que estan en el path local
COPY customers
FROM '../data/olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

-- ---------------------------------------------------
-- Tabla sellers
-- Esta relacionada con los vendedores
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Se suben los registros desde los csv que estan en el path local
COPY sellers
FROM '../data/olist_sellers_dataset.csv'
DELIMITER ','
CSV HEADER;



-- ---------------------------------------------------
-- Tabla productos
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Se suben los registros desde los csv que estan en el path local
COPY products
FROM '../data/olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

-- ---------------------------------------------------
-- Tabla ordenes
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Se suben los registros desde los csv que estan en el path local
COPY orders
FROM '../data/olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;


-- ---------------------------------------------------
-- Tabla de los items de cada orden
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10,2),
    freight_value NUMERIC(10,2)
);

-- Se suben los registros desde los csv que estan en el path local
COPY order_items
FROM '..data/olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;



-- ---------------------------------------------------
-- Tabla con las caracteristicas de pago de cada orden
CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10,2)
);

-- Se suben los registros desde los csv que estan en el path local
COPY order_payments
FROM '../data/olist_order_payments_dataset.csv'
DELIMITER ','
CSV HEADER;

-- ---------------------------------------------------
-- Tabla con las caracteristicas de las ordenes
CREATE TABLE order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- Se suben los registros desde los csv que estan en el path local
COPY order_reviews
FROM '../data/olist_order_reviews_dataset.csv'
DELIMITER ','
CSV HEADER;


-- ---------------------------------------------------
-- Tabla con la geolocalizacion de las ordenes
CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat NUMERIC(10,7),
    geolocation_lng NUMERIC(10,7),
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(10)
);

-- Se suben los registros desde los csv que estan en el path local
COPY geolocation
FROM '../data/olist_geolocation_dataset.csv'
DELIMITER ','
CSV HEADER;



-- ------------------------------------
-- Probamos que funcionen
-- Se hacen algunas queries simples
SELECT table_name
FROM information_schema.tables
WHERE table_schema='public';

SELECT COUNT(*) FROM customers;

SELECT COUNT(*) FROM orders;

SELECT COUNT(*) FROM order_items;