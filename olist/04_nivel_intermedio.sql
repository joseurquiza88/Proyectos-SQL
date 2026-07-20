-- Consultas de SQL nivel intermedio 
-- Practicas de subconsultas

-- Módulo 1 - Subconsultas en WHERE (10 ejercicios)
-- Objetivo: Comparar un valor contra otro valor calculado.
'''
ESTRUCTURA:
SELECT columnas
FROM tabla
WHERE columna operador (
    SELECT ...
    FROM ...
); '''

-- ###################################################################
-- 01. Mostrar los productos cuyo precio sea mayor que el precio promedio.
SELECT * FROM order_items; -- price, product_id

SELECT product_id,
       price
FROM order_items
WHERE price >
(
    SELECT AVG(price)
    FROM order_items
);



-- ###################################################################
-- Mostrar los pedidos cuyo tiempo de entrega fue mayor al promedio.

SELECT order_id, (order_delivered_customer_date::date-order_purchase_timestamp::date) AS tiempo_entrega
 FROM orders
 WHERE (order_delivered_customer_date::date-order_purchase_timestamp::date) > (
    SELECT AVG(order_delivered_customer_date::date-order_purchase_timestamp::date) AS tiempo_promedio
    FROM orders
); 


-- ###################################################################
-- Mostrar los clientes que realizaron pedidos con un valor de pago mayor al pago promedio de todos los pedidos.

SELECT * FROM order_payments;-- payment value, order_id
SELECT * FROM orders; -- order_id, customer_id

SELECT DISTINCT o.customer_id, op.payment_value
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
WHERE op.payment_value > (
    SELECT AVG(op.payment_value)
    FROM order_payments op
); 



-- ###################################################################
-- Mostrar los pedidos cuyo costo de envío (freight_value) sea mayor al costo de envío promedio de todos los pedidos.
SELECT * FROM order_items; -- freight_value

SELECT *
FROM order_items
WHERE freight_value > (
    SELECT AVG(freight_value)
    FROM order_items
); 



-- ###################################################################
-- Mostrar los pagos que fueron superiores al pago máximo promedio esperado (promedio de todos los pagos).
SELECT * FROM order_payments
SELECT *
FROM order_payments
WHERE payment_value > (
    SELECT AVG(payment_value)
    FROM order_payments
); 
-- ###################################################################
-- Mostrar los productos cuyo peso sea mayor al peso promedio de todos los productos.
SELECT * FROM products;

SELECT *
FROM products
WHERE product_weight_g > (
    SELECT AVG(product_weight_g)
    FROM products
); 


-- ###################################################################
-- Mostrar los vendedores que realizaron ventas de productos cuyo precio sea mayor al precio promedio de todos los productos.
SELECT * FROM sellers; 
SELECT * FROM order_items; -- seller_id, price

SELECT DISTINCT seller_id
FROM order_items
WHERE price > (
    SELECT AVG(price)
    FROM order_items
); 

-- ###################################################################
-- Productos que nunca fueron vendidos (no aparecen en order_items).
SELECT * FROM products;
SELECT * FROM order_items;

SELECT * FROM products
WHERE product_id NOT IN (
    SELECT  product_id
    FROM order_items

)
;
-- ###################################################################
--  Pedidos cuyo monto total pagado (sumando todos sus pagos) es mayor al monto pagado en el pedido 
-- "9ef432eb6251297304e76186b10a928d" (o cualquier order_id que quieras usar de referencia).
SELECT * FROM orders;

SELECT order_id 
FROM order_payments
WHERE SUM(payment_value) > (
    SELECT payment_value
    FROM order_payments
WHERE order_id = '9ef432eb6251297304e76186b10a928d'
)
;

SELECT *
    FROM order_payments
WHERE order_id = 'b81ef226f3fe1789b1e8b2acac839d17';


-- ---------------------------------------------------------------------------
-- Subconsultas en HAVING (10 ejercicios): Objetivo: Comparar un agregado contra otro agregado.

''' ESTRUCTURA:
SELECT ...
FROM ...
GROUP BY ...
HAVING funcion_agregacion() operador (

    SELECT ...

);
'''
-- 1. Vendedores cuya cantidad de ventas (items vendidos) es mayor a 10. SIN SUBCONSULTA
SELECT * FROM order_items;
SELECT seller_id, COUNT(*) AS cantidad_items
 FROM order_items
 GROUP BY seller_id
 HAVING COUNT(*) > 10;
 ;

-- ###################################################################
-- Vendedores cuya cantidad de ventas es mayor al promedio de ventas por vendedor.

SELECT seller_id, COUNT(*) AS cantidad_items
 FROM order_items
 GROUP BY seller_id
 HAVING COUNT(*) >( --- 10;
 SELECT AVG(cantidad)FROM (
 SELECT COUNT(*) AS cantidad
 FROM order_items 
 GROUP BY seller_id)
 )
 ;



-- ###################################################################
-- Mostrar los clientes con más pedidos que el promedio.
''' ESTRUCTURA:
SELECT ...
FROM ...
GROUP BY ...
HAVING funcion_agregacion() operador (

    SELECT ...

);
'''
SELECT * FROM customers; -- customer_id
SELECT * FROM orders;

SELECT c.customer_unique_id, COUNT(c.customer_unique_id) AS cantidad_pedidos_clientes
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING AVG(COUNT(c.customer_unique_id)) > (

    SELECT ...

);

-- ###################################################################
-- Mostrar las categorías cuyo promedio de precio sea mayor al promedio general.
-- ###################################################################
-- Mostrar los vendedores cuyo promedio de review sea mayor al promedio general.
-- ###################################################################
-- Mostrar los estados con más clientes que el promedio.
-- ###################################################################
-- Mostrar las ciudades cuyo gasto total sea mayor al promedio.
-- ###################################################################
-- Mostrar los vendedores cuyo ingreso total supere el ingreso promedio.
-- ###################################################################
-- Mostrar las categorías cuyo peso promedio sea mayor al promedio general.
-- ###################################################################
-- Mostrar los clientes cuya cantidad de categorías compradas sea mayor al promedio.
-- ###################################################################
-- Mostrar los meses cuya cantidad de pedidos sea mayor al promedio mensual.
-- ###################################################################
-- Mostrar los clientes cuyo gasto total sea superior al gasto promedio de su estado.


-- -------------------------------------------------------------------------------
-- Módulo 3 - Subconsultas en FROM (Tablas derivadas) (10 ejercicios)
-- Objetivo: Aprender a crear tablas temporales.
'''ESTRUCTURA:
SELECT ...
FROM (

    SELECT ...

) alias;'''

-- ###################################################################
-- Calcular el promedio del total de los pedidos.
-- ###################################################################
-- Contar cuántos pedidos superan el promedio.
-- ###################################################################
-- Calcular el ticket promedio por cliente.
-- ###################################################################
-- Encontrar el cliente con mayor gasto.
-- ###################################################################
-- Encontrar la categoría con mayor facturación.
-- ###################################################################
-- Contar cuántos clientes realizaron más de cinco pedidos.
-- ###################################################################
-- Mostrar el promedio de pedidos por estado.
-- ###################################################################
-- Mostrar el promedio mensual de ventas.
-- ###################################################################
-- Mostrar cuántos vendedores superan el ingreso promedio.
-- ###################################################################
-- Mostrar el promedio de productos vendidos por pedido.

-- -----------------------------------------------------------------------------
-- Módulo 4 - EXISTS y NOT EXISTS (10 ejercicios)

''' ESTRUCTURA:
SELECT ...

FROM tabla1

WHERE EXISTS (

SELECT 1

FROM tabla2

WHERE ...

); '''


-- Objetivo: Pensar en términos de "¿Existe?".
-- EXISTS

-- ###################################################################
-- Clientes que realizaron al menos un pedido.
-- ###################################################################
-- Productos vendidos al menos una vez.
-- ###################################################################
-- Vendedores con al menos un pedido entregado.
-- ###################################################################
-- Clientes que realizaron pedidos cancelados.
-- ###################################################################
-- Productos que recibieron alguna review.


-- NOT EXISTS
-- ###################################################################
-- Productos nunca vendidos.
-- ###################################################################
-- Clientes sin pedidos.
-- ###################################################################
-- Productos sin reviews.
-- ###################################################################
-- Vendedores sin pedidos entregados.

-- ###################################################################
-- Categorías que nunca tuvieron ventas.

-- ----------------------------------------------------------------------------
-- Módulo 5 - Subconsultas correlacionadas (10 ejercicios)

'''
ESTRUCTURA
SELECT ...

FROM tabla t1

WHERE ...

(

SELECT ...

FROM tabla t2

WHERE t2.columna = t1.columna

);'''


-- ###################################################################
-- Mostrar el pedido más caro de cada cliente.

-- ###################################################################
-- Mostrar el producto más caro de cada categoría.
-- ###################################################################
-- Mostrar el cliente que más gastó dentro de cada estado.
-- ###################################################################
-- Mostrar el vendedor con más ventas por estado.
-- ###################################################################
-- Mostrar el pedido con mayor cantidad de productos de cada cliente.
-- ###################################################################
-- Mostrar la review más alta de cada vendedor.
-- ###################################################################
-- Mostrar el primer pedido de cada cliente (sin ROW_NUMBER).
-- ###################################################################
-- Mostrar el último pedido de cada cliente.
-- ###################################################################
-- Mostrar el producto más vendido de cada categoría.
-- ###################################################################
-- Mostrar la ciudad con mayor gasto dentro de cada estado.