

-- Consultas de SQL nivel básico

-- 1 Cuántos pedidos hay en total en la tabla de pedidos?
SELECT  COUNT (*) FROM orders;

-- Comentario: creo que hay pedidos que no son validos, lo revisamos
SELECT DISTINCT order_status FROM orders;
-- Vemos solo los aprobados y listos
SELECT  COUNT (*) FROM orders WHERE order_status = 'approved';

-- Los agrupamos todos
SELECT
    order_status,
    COUNT(*) AS cantidad
FROM orders
GROUP BY order_status
ORDER BY cantidad DESC;

-- ###################################################################
-- 2. Listar los primeros 10 pedidos con su estado y fecha de compra, ordenados por fecha de compra de forma descendente.
SELECT order_status AS estado,
 order_purchase_timestamp AS fecha_compra
 from orders
 ORDER BY fecha_compra DESC
 LIMIT 10;


 -- ###################################################################
 -- 3. ¿Cuáles son los distintos valores posibles de order_status?
 SELECT DISTINCT order_status AS estatus
 FROM orders;


-- ###################################################################
 -- 4. Mostrar todos los pedidos que fueron cancelados.
SELECT * FROM orders WHERE order_status = 'canceled';
SELECT COUNT(*) FROM orders WHERE order_status = 'canceled';

-- ###################################################################
 --  5. ¿Cuántos clientes distintos (personas reales, no pedidos) hay registrados?
 SELECT * FROM customers LIMIT 10; -- Vemos primero todas las columnas
 SELECT  COUNT(DISTINCT customer_unique_id) FROM customers;

-- ###################################################################
 -- 6. Listar las combinaciones distintas de ciudad y estado donde hay vendedores registrados, ordenadas alfabéticamente.
 SELECT * FROM sellers;
 SELECT DISTINCT seller_city, seller_state FROM sellers ORDER BY seller_city, seller_state;


-- ###################################################################
-- 7. Cuántos pedidos fueron entregados?.
SELECT DISTINCT order_status  FROM orders; -- Que caracteriticas unicas tiene esta columnas
SELECT  COUNT(order_status) AS pedidos_entregados
FROM orders 
WHERE order_status = 'delivered' ;


-- ###################################################################
-- 8.	Cuántos tipos distintos de pago existen?
SELECT * FROM order_payments;
SELECT DISTINCT payment_type FROM order_payments; -- Dice que tipos de pago unico existen
SELECT COUNT(DISTINCT payment_type) AS TipoPago -- Dice Cuantos tipos de pago unico existen
 FROM order_payments;


-- ###################################################################
-- 9.	Listar 20 productos con mayor precio

SELECT * FROM order_items; -- Esta el precio del producto y el id
SELECT product_id, price AS precio
 FROM order_items
 ORDER BY precio DESC
 LIMIT 20;

-- ###################################################################
-- 10.	¿Cuántos productos distintos (product_id) aparecen en la tabla de order_items?
SELECT COUNT(DISTINCT product_id) AS cantidadProductos FROM order_items;


-- ###################################################################
-- 11.	Listar los vendedores por estado
SELECT * FROM sellers;
SELECT seller_state, COUNT(*) AS cantidad FROM sellers
GROUP BY seller_state
ORDER BY cantidad DESC
;

-- ###################################################################
-- 12.	12.	Listar las categorías en inglés
SELECT DISTINCT product_category_name_english 
FROM product_category_name_translation;


-- ###################################################################
-- 13.	Listar los 10 estados (customer_state) con más pedidos registrados.
SELECT * FROM customers; -- customer_id customer_state
SELECT * FROM orders; -- customer_id order

SELECT cu.customer_state AS estado, COUNT(o.order_id) AS cantidad
FROM customers cu
JOIN orders o
ON cu.customer_id = o.customer_id
GROUP BY estado
ORDER BY cantidad DESC
LIMIT 10
;

-- ###################################################################
-- 14.	Pedidos con entrega estimada antes del 2018-01-01
SELECT * FROM orders;
SELECT *
 FROM orders
WHERE order_estimated_delivery_date < '2018-01-01'
;


-- ###################################################################
-- 15.	Precio mínimo y máximo
SELECT MIN(price) AS minimo, MAX(price) AS maximo 
FROM order_items;

-- ###################################################################
-- 16.	Cantidad de pedidos con review 5
SELECT * FROM order_reviews;
SELECT COUNT(*) cantidad 
FROM order_reviews
WHERE review_score = 5;
;

-- ###################################################################
-- 17.	Precio promedio por vendedor
SELECT * FROM sellers; -- seller_id
SELECT * FROM order_items; -- seller_id price
-- No es necesario hacer un join porque en la tabla de order_items esta el id y el precio
SELECT s.seller_id as vendedor, ROUND(AVG(oi.price),2) as promedio
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY vendedor
ORDER BY promedio DESC
;

-- Esta seria la forma realmente adecuada
SELECT seller_id AS vendedores, ROUND(AVG(price),2) AS promedio
 FROM order_items
 GROUP BY vendedores
 ORDER BY promedio DESC
 ;


-- ###################################################################
-- 18.	¿Cuántos pedidos NO fueron entregados (status distinto de 'delivered')?
SELECT * FROM orders;

SELECT COUNT(*) AS cantidad 
FROM orders
-- WHERE order_status != 'delivered'
WHERE order_status <> 'delivered';
;


-- ###################################################################
-- 19.	¿Cuál es la fecha de compra más antigua y la más reciente registradas?
SELECT MIN(order_purchase_timestamp) AS antigua, MAX(order_purchase_timestamp) AS reciente
 FROM orders;

-- ###################################################################
-- 20.	Listar los 15 productos con mayor peso (product_weight_g).
SELECT * FROM products;
SELECT product_id AS producto, product_weight_g AS peso 
FROM products
WHERE product_weight_g IS NOT NULL
ORDER BY peso DESC
LIMIT 15
;
-- Ojo que hay nulls como lo elimino?


-- ###################################################################
-- 21.	¿Cuántas reviews tienen un comentario escrito (review_comment_message no es NULL)?
SELECT * FROM order_reviews;
SELECT COUNT(*) AS cantidad
 FROM order_reviews
 WHERE review_comment_message IS NOT NULL
 ;



-- ###################################################################
-- 22.	Listar los pedidos cuyo estado sea 'shipped' o 'processing'.
SELECT * FROM orders;

SELECT * 
FROM orders
WHERE order_status = 'shipped' or order_status ='processing'
;

-- ###################################################################
-- 23.	¿Cuántos pagos se hicieron con más de 1 cuota (payment_installments > 1)?
SELECT * FROM order_payments;
SELECT COUNT(*) AS cantidad
FROM order_payments
WHERE payment_installments > 1
;

-- ###################################################################
-- 24.	Listar las 10 ciudades de vendedores con más registros, junto con la cantidad.
SELECT *  FROM sellers; --  seller_id, seller_cty
SELECT *  FROM order_items; -- order_id, seller_id

SELECT seller_city AS ciudad, COUNT(*) AS cantidad
FROM sellers
GROUP BY ciudad
ORDER BY cantidad DESC
LIMIT 10;



-- ###################################################################
-- 25.	¿Cuál es el valor de flete (freight_value) promedio y máximo de todos los items vendidos?
SELECT round(AVG(freight_value),2) AS Flete_promedio, max(freight_value) AS Flete_maximo
FROM order_items;