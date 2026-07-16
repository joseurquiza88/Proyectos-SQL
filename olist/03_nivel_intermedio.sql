-- Consultas de SQL nivel intermedio


-- ###################################################################
-- 01. ¿Cuál es el precio promedio de los productos vendidos, 
-- por categoría (en inglés)? Ordenar de mayor a menor.

SELECT * FROM order_payments;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM products;


SELECT op.order_id, oi.product_id,  op.payment_value, pr.product_category_name
 FROM order_payments op
 JOIN order_items oi
 ON op.order_id = oi.order_id

 JOIN products pr
 ON oi.product_id = pr.product_id
 ;

SELECT  pr.product_category_name, 
ROUND(AVG(op.payment_value),2) AS promedio
 FROM order_payments op
 JOIN order_items oi
 ON op.order_id = oi.order_id

 JOIN products pr
 ON oi.product_id = pr.product_id
 
 GROUP BY pr.product_category_name 
 ORDER BY promedio DESC
 ;

-- ###################################################################
-- 2. ¿Cuántos pedidos hizo cada cliente? 
-- Mostrar solo los clientes que hicieron más de un pedido.

SELECT * FROM customers;
SELECT * FROM orders;

SELECT cu.customer_unique_id, COUNT(DISTINCT ord.order_id) AS cantidad_pedidos
 FROM orders ord
JOIN customers cu
ON ord.customer_id = cu.customer_id
GROUP BY cu.customer_unique_id
HAVING COUNT(DISTINCT ord.order_id) > 1
ORDER BY cantidad_pedidos DESC;

-- ###################################################################
-- 3. ¿Cuál es el estado (customer_state) con más clientes únicos?
SELECT customer_state,COUNT(customer_unique_id) AS cantidad_clientes FROM customers
GROUP BY customer_state
ORDER BY cantidad_clientes DESC LIMIT 1;

-- ###################################################################
-- 4. ¿Cuál es el monto total pagado por tipo de método de pago?

SELECT payment_type AS tipo, sum(payment_value) AS total
FROM order_payments
GROUP BY tipo
ORDER BY total DESC;

-- ###################################################################
-- 5 ¿Cuál es la calificación promedio (review_score) por categoría 
-- de producto? Ordenar de la peor calificada a la mejor.
SELECT  o.order_id, o.review_score, oi.order_item_id, oi.product_id, p.product_category_name
FROM order_reviews o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id;

SELECT  p.product_category_name AS categorias, 
ROUND(AVG(o.review_score),2) AS promedio
FROM order_reviews o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY categorias
ORDER BY promedio ASC
LIMIT 1
;

SELECT * FROM order_items;
SELECT * FROM products;


-- ###################################################################
-- 6. ¿Cuántos pedidos entregados hubo por mes y año?
-- REVISAR/RETOMAR TEMA!!
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS mes, COUNT(*) AS pedidos
FROM orders
WHERE order_status = 'delivered'
GROUP BY mes
ORDER BY mes;


-- ###################################################################
-- 7. ¿Cuáles son los 10 vendedores con mayor facturación total (suma de price)?
SELECT * FROM sellers;
SELECT * FROM order_items;
SELECT * FROM orders;

SELECT s.seller_id as vendedores, sum(op.payment_value) as facturacion
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
JOIN order_payments op
ON oi.order_id = op.order_id
GROUP BY vendedores
ORDER BY facturacion DESC
LIMIT 10
;


-- ###################################################################
--  8. ¿Cuál es el costo de envío (freight_value) promedio, agrupado por estado del cliente?

-- Prueba
SELECT customer_id FROM customers;
SELECT order_id customer_id FROM orders;
SELECT order_id, AVG(freight_value) FROM orders_items;

SELECT cu.customer_state AS estado , AVG(oi.freight_value) AS costo_envio 
FROM customers cu
JOIN orders o
ON cu.customer_id = o.customer_id 

JOIN order_items oi
ON o.order_id = oi.order_id

GROUP BY estado
ORDER BY costo_envio DESC
;


-- ###################################################################
--  9.	 ¿Cuál es el costo de envío (freight_value) promedio, agrupado por estado del cliente?


-- ###################################################################
-- 10.	Listar los pedidos del año 2017
SELECT * FROM orders
WHERE EXTRACT(YEAR FROM order_purchase_timestamp)=2017;
;


-- ###################################################################
-- 11.	Mostrar los 10 clientes (customer_unique_id) que más dinero gastaron en total. Mostrar:
-- customer_unique_id, cantidad de pedidos, dinero gastado Ordenar de mayor a menor.

SELECT * FROM customers; -- customer_id customer_unique_id
SELECT * FROM orders; -- customer_id
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM order_items; -- order_id, price NO

SELECT c.customer_unique_id AS cliente, COUNT(DISTINCT o.order_id) AS cantidad_pedidos,
SUM(op.payment_value) AS cantidad_dinero 
FROM customers c

JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_payments op
ON o.order_id = op.order_id

GROUP BY cliente
ORDER BY cantidad_dinero DESC
LIMIT 10
;


-- ###################################################################
-- 12.	¿Cuál fue el ticket promedio (payment_value) por estado(geografico) del cliente? 
-- Mostrar: Estado, Cantidad de pedidos, Ticket promedio Ordenar por ticket promedio descendente.
SELECT * FROM customers; -- customer_id, customer_unique_id customer_state
SELECT * FROM order_payments; -- order_id payment_value
SELECT * FROM orders; -- order_id, customer_id

SELECT c.customer_state AS estado, ROUND(AVG(op.payment_value),2) AS ticket_promedio,
COUNT(DISTINCT o.order_id) AS cantidad_pedidos

FROM customers c

JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY estado
ORDER BY ticket_promedio
;


-- ###################################################################
-- 13.	Calcular cuánto tardó cada pedido en entregarse. Mostrar únicamente aquellos pedidos cuya entrega demoró más de 30 días.
SELECT * FROM orders;
-- order_purchase_timestamp: Es la fecha y hora en que el cliente realizó la compra.
-- order_delivered_customer_date: Es la fecha y hora en que el cliente recibió el pedido.

SELECT order_id, order_purchase_timestamp AS fecha_compra, order_delivered_customer_date AS fecha_entrega, 
(order_delivered_customer_date::date - order_purchase_timestamp::date) AS dias_entrega
FROM orders
WHERE (order_delivered_customer_date::date - order_purchase_timestamp::date) > 30
ORDER BY dias_entrega DESC
;

-- ###################################################################
-- 14.	¿Cuáles son las 5 categorías de productos más vendidas (en cantidad de items)?
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id,
SELECT * FROM product_category_name_translation; -- hay doble JOIN en la respuesta

SELECT p.product_category_name AS categoria_producto, COUNT (DISTINCT oi.order_id) AS cantidad_pedidos 
FROM order_items oi
JOIN products p 
ON oi.product_id = p.product_id

GROUP BY categoria_producto
ORDER BY cantidad_pedidos DESC
LIMIT 5
;

-- ###################################################################
-- 15.	¿Cuántos vendedores distintos vendieron cada categoría de producto? Ordenar de mayor a menor.
SELECT * FROM sellers; -- seller_id
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- seller_id, product_id,
SELECT * FROM product_category_name_translation; -- hay doble JOIN en la respuesta

SELECT product_category_name AS categoria, COUNT(DISTINCT s.seller_id) AS cantidad_vendedores 

FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY categoria
ORDER BY cantidad_vendedores DESC
;

-- ###################################################################
-- 16.	¿ Cuál es la cantidad de pedidos y el porcentaje de pedidos cancelados sobre el total, por año?
SELECT * FROM orders;
-- Pruebas
SELECT COUNT(*) AS cantidad_pedidos,  
FROM orders;

SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS anio,
COUNT(*) AS cantidad_pedidos_cancelados  
FROM orders
WHERE order_status = 'canceled'
GROUP BY anio
;

-- Consulta completa
SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS anio,
COUNT(*) AS cantidad_pedidos, 
SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) AS cantidad_pedidos_cancelados,
-- ((SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END)*100)/(COUNT(order_id))*100) AS porcentaje_cancelado
ROUND(100.0 * SUM(CASE WHEN order_status = 'canceled' THEN 1 ELSE 0 END) / COUNT(*),
2
) AS porcentaje_cancelados
FROM orders
GROUP BY anio
;


-- ###################################################################
-- 17.	Mostrar los vendedores que tuvieron una calificación promedio menor a 3 
-- (considerando las reviews de los pedidos en los que participaron), junto con la cantidad de reviews que tienen.
SELECT * FROM sellers; -- seller_id
SELECT * FROM order_items; -- seller_id, order_id
SELECT * FROM order_reviews; -- order_id, review_score

SELECT  s.seller_id AS vendedor, ROUND(AVG(ors.review_score),1) AS promedio_reviews,
COUNT(ors.review_id) AS cantidad_reviews
FROM sellers s

JOIN order_items oi
ON s.seller_id = oi.seller_id

JOIN order_reviews ors
ON oi.order_id = ors.order_id

GROUP BY vendedor
HAVING (ROUND(AVG(ors.review_score),1)) > 3
;


-- ###################################################################
-- 18.	¿Cuál es la cantidad de pedidos por método de pago y el promedio de cuotas (payment_installments) usado en cada uno?.
SELECT * FROM orders; -- order_id
SELECT * FROM order_payments; -- order_id

-- Se hizo asi pero en realidad no es necesario hacer el join
SELECT op.payment_type AS metodo_pago, 
COUNT(o.order_id) AS cantidad_pedidos,
ROUND(AVG(op.payment_installments),2) AS promedio_cuotas
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY metodo_pago 
ORDER BY cantidad_pedidos DESC
LIMIT 10
;
-- Esta seria la form de hacerlo sin JOIN
SELECT payment_type AS metodo_pago, 
COUNT(order_id) AS cantidad_pedidos,
ROUND(AVG(payment_installments),2) AS promedio_cuotas
FROM order_payments
GROUP BY metodo_pago 
ORDER BY cantidad_pedidos DESC
LIMIT 10
;

-- ###################################################################
-- 19.	Listar las 10 ciudades de clientes con mayor gasto total, mostrando también la cantidad de clientes únicos de esa ciudad.
SELECT * FROM customers; -- customer_id, customer_unique_id, customer_city
SELECT * FROM orders; -- customer_id, order_id
SELECT * FROM order_payments; -- order_id, payment_value

SELECT c.customer_city AS ciudad,  SUM(op.payment_value) AS gasto_total,
COUNT ( DISTINCT customer_unique_id) AS cantidad_clientes

FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY ciudad
ORDER BY gasto_total DESC
LIMIT 10
;


-- ###################################################################
-- 20.	¿Cuál es el peso promedio (product_weight_g) de los productos por categoría, 
-- solo para categorías con más de 100 productos vendidos?.
SELECT * FROM products; -- product_id, product_weight_g, product_category_name
SELECT * FROM order_items; -- order_id, product_id

SELECT  p.product_category_name AS categorias, ROUND(AVG(p.product_weight_g),2) AS peso_promedio,
COUNT(oi.product_id) AS cantidad_productos

FROM products p

JOIN order_items oi -- INNER JOIN

ON p.product_id = oi.product_id

GROUP BY categorias
HAVING COUNT(oi.product_id) > 100
ORDER BY cantidad_productos DESC
;


-- ###################################################################
-- 21.	¿Cuántos pedidos tuvieron más de un método de pago asociado (pagos combinados)?
SELECT * FROM order_payments;
-- Entonces para un mismo order_id, ¿cuántos payment_type distintos existen?
-- Con esto hago una lista de las ordenes que tienen mas de un metodo de pago asociado
SELECT order_id AS pedidos, COUNT(payment_type) AS cantidad_medio_pago
 FROM order_payments
 GROUP BY pedidos
 HAVING COUNT(DISTINCT payment_type) > 1
 ;

-- Pero no me pide eso me pide cuantos pedidos tienen mas de un metodo, entonces hay que hacer subconsultas
SELECT COUNT(*) AS cantidad_pedidos 
FROM (
SELECT order_id
 FROM order_payments
 GROUP BY order_id
 HAVING COUNT(DISTINCT payment_type) > 1
);


-- ###################################################################
-- 22.	¿Cuál es la diferencia promedio (en días) entre la fecha estimada de entrega y 
-- la fecha real de entrega, por estado del cliente? Ordenar mostrando primero los estados donde más se atrasan las entregas.
SELECT * FROM customers; -- customer_id, customer_state
SELECT * FROM orders; -- order_id, customer_id

SELECT  c.customer_state AS estado, 
ROUND(AVG (o.order_delivered_customer_date::date-o.order_estimated_delivery_date::date ),0) AS dias_entrega
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY estado
;

-- ###################################################################
-- 23.	¿Cuál es el vendedor con mayor cantidad de pedidos distintos entregados?
SELECT * FROM sellers; -- seller_id
SELECT * FROM order_items; -- seller_id, order_id
SELECT * FROM orders; -- order_id, order_status = 'delivered'

SELECT oi.seller_id, COUNT(DISTINCT o.order_id) AS pedidos_entregados
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id
ORDER BY pedidos_entregados DESC
LIMIT 1;

-- ###################################################################
-- 24.	¿Cuántas categorías de producto tienen un precio promedio mayor a 200?
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id, price

SELECT COUNT(*) AS numero_categorias FROM(
SELECT p.product_category_name AS categoria, ROUND(AVG(oi.price),2) AS precio_promedio 
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY categoria
HAVING  ROUND(AVG(oi.price),2) > 200
-- ORDER BY precio_promedio 
);

-- ###################################################################
-- 25.	Por año, ¿cuál es el porcentaje de pagos hechos con 'boleto' vs 'credit_card' del total
SELECT * FROM orders; -- order_id, order_purchase_timestamp
SELECT * FROM order_payments; -- order_id, payment_type

SELECT EXTRACT( YEAR FROM o.order_purchase_timestamp) AS anio,
ROUND(100.0 * SUM(CASE WHEN op.payment_type = 'boleto' THEN 1 ELSE 0 END)/COUNT(*),2) AS cantidad_boleto,
ROUND(100.0 * SUM(CASE WHEN op.payment_type = 'credit_card' THEN 1 ELSE 0 END)/COUNT(*),2) AS cantidad_credit_card
FROM orders o
JOIN order_payments op
ON o.order_id = op. ordcder_id
GROUP BY anio
ORDER BY anio ASC
;