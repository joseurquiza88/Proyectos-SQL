

-- Consultas de SQL nivel básico

-- 01 Cuántos pedidos hay en total en la tabla de pedidos?
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
 -- Pregunta 3. ¿Cuáles son los distintos valores posibles de order_status?
 SELECT DISTINCT order_status AS estatus
 FROM orders;


-- ###################################################################
 -- Pregunta 4. Mostrar todos los pedidos que fueron cancelados.
SELECT * FROM orders WHERE order_status = 'canceled';
SELECT COUNT(*) FROM orders WHERE order_status = 'canceled';

-- ###################################################################
 -- Pregunta 5. ¿Cuántos clientes distintos (personas reales, no pedidos) hay registrados?
 SELECT * FROM customers LIMIT 10; -- Vemos primero todas las columnas
 SELECT  COUNT(DISTINCT customer_unique_id) FROM customers;

-- ###################################################################
 -- 6. Listar las combinaciones distintas de ciudad y estado donde hay vendedores registrados, ordenadas alfabéticamente.
 SELECT * FROM sellers;
 SELECT DISTINCT seller_city, seller_state FROM sellers ORDER BY seller_city, seller_state;

-- ###################################################################
-- 7. Cuántos pedidos fueron entregados?.


-- ###################################################################
-- 8.	Cuántos tipos distintos de pago existen?



-- ###################################################################
-- 9.	Listar 20 productos con mayor precio

-- ###################################################################
-- 10.	Listar 20 productos con mayor precio

-- ###################################################################
-- 11.	Listar los vendedores por estado


-- ###################################################################
-- 12.	Listar las categorías en inglés


-- ###################################################################
-- 13.	Listar las categorías en inglés

-- ###################################################################
-- 14.	Pedidos con entrega estimada antes del 2018-01-01

-- ###################################################################
-- 15.	Precio mínimo y máximo


-- ###################################################################
-- 16.	Pedidos con review 5


-- ###################################################################
-- 17.	Precio promedio por vendedor

