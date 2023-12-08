-- Criando a base de dados:
CREATE DATABASE olist;
-- Criando as tabelas:

-- Geolocation:
CREATE TABLE temp_geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

COPY temp_geolocation (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_geolocation_dataset.csv' WITH CSV HEADER DELIMITER ',' ENCODING 'UTF-8';

SELECT
    COUNT(DISTINCT geolocation_zip_code_prefix) as distinct_values, 
    COUNT(geolocation_zip_code_prefix) as total_rows
FROM temp_geolocation;

/*
	
  | distinct_values    |  total_rows
  | bigint             |  bigint
1 |	19015       	   |  1001206

*/

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10) PRIMARY KEY,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city VARCHAR(50),
    geolocation_state VARCHAR(2)
);

INSERT INTO geolocation
    SELECT DISTINCT ON (geolocation_zip_code_prefix) *
    FROM temp_geolocation
;

/*
19015 rows inserted
*/

SELECT
    COUNT(DISTINCT geolocation_zip_code_prefix) as distinct_values, 
    COUNT(geolocation_zip_code_prefix) as total_rows
FROM geolocation;

DROP TABLE temp_geolocation

-- -- Apagando as linhas com geolocation_zip_code_prefix duplicados (muito tempo...)
-- -- it takes a long time... 
-- DELETE FROM geolocation
-- WHERE (geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state) NOT IN (
--     SELECT 
--         DISTINCT (geolocation_zip_code_prefix) geolocation_zip_code_prefix,
--         geolocation_lat,
--         geolocation_lng,
--         geolocation_city,
--         geolocation_state
--    FROM geolocation
-- );


-- WITH subresult as (
--     SELECT
--         *,
--         ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY (SELECT NULL)) AS RowNum
--     FROM geolocation
-- )
-- SELECT * FROM subresult
-- WHERE RowNum = 1
-- LIMIT 100
-- ;


-- Table customer
-- -- Primary Key: customer_id
CREATE TABLE customer (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix VARCHAR(10) REFERENCES geolocation(geolocation_zip_code_prefix),
    customer_city VARCHAR(50),
    customer_state VARCHAR(2)
);

COPY customer (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_customers_dataset.csv' WITH CSV HEADER DELIMITER ',' ENCODING 'UTF-8';

/*
ERROR: insert or update on table "customer" violates foreign key constraint "customer_customer_zip_code_prefix_fkey"
*/

SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'customer' AND constraint_type = 'FOREIGN KEY';

/*
1 row returned
constraint_name
name
1	customer_customer_zip_code_prefix_fkey
*/

ALTER TABLE customer
DROP CONSTRAINT customer_customer_zip_code_prefix_fkey;

COPY customer (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_customers_dataset.csv' WITH CSV HEADER DELIMITER ',' ENCODING 'UTF-8';

select * from customer
LIMIT 100

select 
    COUNT (DISTINCT customer_zip_code_prefix)
from customer

-- Adding zip_code_prefix from customer to geolocation
-- left outer JOIN

INSERT INTO geolocation (geolocation_zip_code_prefix, geolocation_city, geolocation_state)
SELECT
    DISTINCT ON (cus.customer_zip_code_prefix)
    cus.customer_zip_code_prefix as geolocation_zip_code_prefix,
    cus.customer_city as geolocation_city,
    cus.customer_state as geolocation_state
FROM customer as cus
    LEFT JOIN geolocation AS geo 
    ON cus.customer_zip_code_prefix = geo.geolocation_zip_code_prefix
WHERE geo.geolocation_zip_code_prefix IS NULL
;
/*
157 rows inserted
*/

select 
    COUNT (*)
from geolocation

/*
1 row returned
count
bigint
1	19172
*/

ALTER TABLE customer
ADD CONSTRAINT fk_customer_geolocation
FOREIGN KEY (customer_zip_code_prefix) REFERENCES geolocation(geolocation_zip_code_prefix);

-- Table  products
-- -- primary key:  product_id
CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(50),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

COPY products (product_id, product_category_name, product_name_length, product_description_length, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_products_dataset.csv' 
DELIMITER ',' CSV HEADER ;

SELECT COUNT(*) FROM products
;

/*
1 row returned
count
bigint
1	32951
*/

SELECT * FROM products
LIMIT 100;

-- Table sellers
-- -- primary key: seller_id
CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(50),
    seller_state VARCHAR(2)
);

COPY sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_sellers_dataset.csv' 
DELIMITER ',' CSV HEADER;

/*
ERROR: insert or update on table "olist_sellers_dataset" violates foreign key constraint "olist_sellers_dataset_seller_zip_code_prefix_fkey"
*/

-- I am looking to table geolocation. This table is incompleted and it does have any relevant information,despate the lat & long (worthless with doubt complete zip code...)

SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'customer' AND constraint_type = 'FOREIGN KEY';



ALTER TABLE customer
DROP CONSTRAINT fk_customer_geolocation
;

SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'customer' AND constraint_type = 'FOREIGN KEY';

drop table olist_sellers_dataset;


-- Table order (olist_orders_dataset)
-- -- Primary Key: order_id
CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32) REFERENCES customer(customer_id),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

COPY orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_orders_dataset.csv' 
DELIMITER ',' CSV HEADER;

SELECT COUNT(*) FROM orders;

-- Table order_payments
-- -- Primary Key: order_id

-- Table orders
-- -- Primary key: order_id

-- Table order_reviews (olist_order_reviews_dataset)
-- -- Primary key: review_id
CREATE TABLE order_reviews (
    review_id VARCHAR(32) PRIMARY KEY,
    order_id VARCHAR(32) REFERENCES orders(order_id),
    review_score INTEGER,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_order_reviews_dataset.csv' 
DELIMITER ',' CSV HEADER;

/*
ERROR: duplicate key value violates unique constraint "order_reviews_pkey"
*/

DROP TABLE order_reviews;

-- Table order_reviews (olist_order_reviews_dataset)
-- -- Primary key: new_id
CREATE TABLE order_reviews (
    new_id SERIAL PRIMARY KEY,
    review_id VARCHAR(32),
    order_id VARCHAR(32) REFERENCES orders(order_id),
    review_score INTEGER,
    review_comment_title VARCHAR(255),
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

COPY order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_order_reviews_dataset.csv' 
DELIMITER ',' CSV HEADER;

SELECT count(*) FROM order_reviews;

-- Table order_payments (olist_order_payments_dataset)
-- -- Primary key: payment_id
CREATE TABLE payments (
    paymente_id SERIAL PRIMARY KEY,
    order_id VARCHAR(32) REFERENCES orders(order_id),
    payment_sequential INTEGER,
    payment_type VARCHAR(20),
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2)
);

COPY payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_order_payments_dataset.csv' 
DELIMITER ',' CSV HEADER;

SELECT count(*) FROM payments;

-- Table items (olist_order_items_dataset)
-- -- Primary key: order_item_id
CREATE TABLE itens (
    order_item_id VARCHAR(32) PRIMARY KEY,
    order_id VARCHAR(32) REFERENCES orders(order_id),
    product_id VARCHAR(32) REFERENCES products(product_id),
    seller_id VARCHAR(32) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);

COPY itens (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_order_items_dataset.csv' 
DELIMITER ',' CSV HEADER;

/*
ERROR: duplicate key value violates unique constraint "itens_pkey"
*/
SELECT constraint_name
FROM information_schema.table_constraints
WHERE table_name = 'itens' AND constraint_type = 'PRIMARY KEY';
/*
1 row returned
constraint_name
name
1	itens_pkey
*/

DROP TABLE itens;

-- Table items (olist_order_items_dataset)
-- -- Primary key: item_id
CREATE TABLE itens (
    item_id SERIAL PRIMARY KEY,
    order_item_id VARCHAR(32),
    order_id VARCHAR(32) REFERENCES orders(order_id),
    product_id VARCHAR(32) REFERENCES products(product_id),
    seller_id VARCHAR(32) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2)
);

COPY itens (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
FROM 'C:/Users/andre/Documents/DataBase/olist_db/olist_order_items_dataset.csv' 
DELIMITER ',' CSV HEADER;

SELECT count(*) FROM itens;

/*
1 row returned
count
bigint
1	112650
*/


-- Adicionar chave estrangeira após a criação da tabela
ALTER TABLE employees
ADD CONSTRAINT fk_employees_departments
	FOREIGN KEY (department_id)	REFERENCES departments (department_id);


SELECT * FROM sellers;


DROP TABLE geolocation;