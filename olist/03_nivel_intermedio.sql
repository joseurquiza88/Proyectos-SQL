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
-- Pregunta 11. ¿Cuál es la calificación promedio (review_score) por categoría 
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
-- Pregunta 12. ¿Cuántos pedidos entregados hubo por mes y año?
-- REVISAR/RETOMAR TEMA!!
SELECT DATE_TRUNC('month', order_purchase_timestamp) AS mes, COUNT(*) AS pedidos
FROM orders
WHERE order_status = 'delivered'
GROUP BY mes
ORDER BY mes;


-- ###################################################################
-- Pregunta 13. ¿Cuáles son los 10 vendedores 
-- con mayor facturación total (suma de price)?
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
--  Pregunta 14. ¿Cuál es el costo de envío (freight_value) promedio, 
-- agrupado por estado del cliente?

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










