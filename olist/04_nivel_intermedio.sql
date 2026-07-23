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
SELECT * FROM products;
SELECT * FROM order_items;


SELECT product_id, price 
FROM order_items
WHERE price > (
    SELECT AVG(price) AS promedio_total
    FROM order_items
)

;
-- ###################################################################
-- Mostrar los pedidos cuyo tiempo de entrega fue mayor al promedio.
SELECT * FROM orders;

SELECT order_id,(order_delivered_customer_date::date - order_purchase_timestamp::date) AS tiempo_entrega
FROM orders
WHERE (order_delivered_customer_date::date - order_purchase_timestamp::date) > (
   SELECT AVG(order_delivered_customer_date::date - order_purchase_timestamp::date) AS tiempo_entrega_promedio
   FROM orders
);


-- ###################################################################
-- Mostrar los clientes que realizaron pedidos con un valor de pago mayor al pago promedio de todos los pedidos.
SELECT * FROM customers; -- customer_id, customer_unique_id
SELECT * FROM orders; -- order_id, customer_id,
SELECT * FROM order_payments; -- order_id, payment_value

SELECT DISTINCT c.customer_unique_id, op.payment_value

FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
WHERE op.payment_value > (
    SELECT AVG(payment_value) AS promedio
    FROM order_payments
)


-- ###################################################################
-- Mostrar los pedidos cuyo costo de envío (freight_value) sea mayor al costo de envío promedio de todos los pedidos.
SELECT * FROM order_items;

SELECT DISTINCT order_id, freight_value
 FROM order_items
 WHERE freight_value > (
    SELECT AVG(freight_value)
    FROM order_items
 )
 ;
-- ###################################################################
-- Mostrar los pagos que fueron superiores al pago promedio esperado (promedio de todos los pagos).
SELECT * FROM order_payments;

SELECT payment_value 
FROM order_payments
WHERE payment_value > (
    SELECT AVG(payment_value)
    FROM order_payments);

-- ###################################################################
-- Mostrar los productos cuyo peso sea mayor al peso promedio de todos los productos.
SELECT * FROM products;

SELECT product_id, product_category_name ,product_weight_g 
FROM products
WHERE product_weight_g > (
    SELECT AVG (product_weight_g)
    FROM products
)
;
-- ###################################################################
-- Mostrar los vendedores que realizaron ventas de productos cuyo precio sea mayor al precio promedio de todos los productos.
SELECT * FROM sellers; -- seller_id
SELECT * FROM order_items; -- seller_id, price

SELECT DISTINCT seller_id
FROM order_items
WHERE price > (
    SELECT AVG (price)
    FROM order_items
)
;

-- ###################################################################
-- Productos que nunca fueron vendidos (no aparecen en order_items).
-- IN
SELECT * FROM order_items; -- product_id
SELECT * FROM products; -- product_id

SELECT DISTINCT product_id 
FROM products
WHERE product_id NOT IN (
    SELECT product_id 
    FROM order_items
)
;

-- ###################################################################
--  Pedidos cuyo monto total pagado (sumando todos sus pagos) es mayor al monto pagado en el pedido 
-- "9ef432eb6251297304e76186b10a928d" (o cualquier order_id que quieras usar de referencia).
SELECT * FROM order_payments;

SELECT
    order_id,
    SUM(payment_value) AS total_pagado
FROM order_payments
GROUP BY order_id
HAVING SUM(payment_value) > (
    SELECT SUM(payment_value)
    FROM order_payments
    WHERE order_id = '9ef432eb6251297304e76186b10a928d'
);


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
SELECT seller_id, COUNT(DISTINCT order_id) AS cantidad_ventas
 FROM order_items
 GROUP BY seller_id
 HAVING COUNT(*) > 10
 ;

-- ###################################################################
-- Vendedores cuya cantidad de ventas es mayor al promedio de ventas por vendedor.
SELECT * FROM order_items;

SELECT seller_id, COUNT(DISTINCT order_id) AS cantidad_ventas
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) > (
    SELECT AVG(cantidad_ventas) FROM (
        SELECT COUNT(DISTINCT order_id) AS cantidad_ventas
        FROM order_items
        GROUP BY seller_id
    ) AS subconsulta
)
;


-- ###################################################################
-- Mostrar los clientes con más pedidos que el promedio.

SELECT * FROM orders; -- order_id, customer_id

SELECT c.customer_unique_id, COUNT(o.order_id) AS cantidad_pedidos 
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(order_id) > (
    SELECT AVG(cantidad_pedidos) 
    FROM (
        SELECT COUNT(order_id) AS cantidad_pedidos 
        FROM orders
        GROUP BY customer_id
    ) AS subconsulta
)
;
-- # El join en la subconsulta tambien es neesario
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS cantidad_pedidos
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > (
    SELECT AVG(cantidad_pedidos)
    FROM (
        SELECT
            c2.customer_unique_id,
            COUNT(o2.order_id) AS cantidad_pedidos
        FROM orders o2
        JOIN customers c2
            ON o2.customer_id = c2.customer_id
        GROUP BY c2.customer_unique_id
    ) AS subconsulta
);

-- ###################################################################
-- Mostrar las categorías cuyo promedio de precio sea mayor al promedio general.
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id, price

SELECT p.product_category_name, AVG (oi.price) AS precio_categoria
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
HAVING AVG (oi.price) > (
    SELECT AVG (oi2.price) AS total_promedio 
    FROM products p2
    JOIN order_items oi2
    ON p2.product_id = oi2.product_id

);

-- ###################################################################
-- Mostrar los vendedores cuyo promedio de review sea mayor al promedio general.
SELECT * FROM order_reviews; -- order_id, review_score
SELECT * FROM order_items; -- order_id, seller_id

SELECT seller_id, ROUND(AVG (review_score),2) promedio_reviews
FROM order_reviews r
JOIN order_items oi
ON r.order_id = oi.order_id
GROUP BY seller_id
HAVING AVG (review_score) > (
    SELECT AVG (review_score) promedio_reviews
    FROM order_reviews r2
    JOIN order_items oi2
    ON r2.order_id = oi2.order_id
);


-- ###################################################################
-- Mostrar los estados con más clientes que el promedio.
SELECT * FROM customers;

SELECT customer_state, COUNT (*) AS cantidad_clientes 
FROM customers
GROUP BY customer_state
HAVING COUNT (*) > (
    SELECT AVG (cantidad_clientes) FROM (
        SELECT COUNT (*) AS cantidad_clientes
        FROM customers
        GROUP BY customer_state
    ) AS subconsulta
);
-- ###################################################################
-- Mostrar las ciudades cuyo gasto total sea mayor al promedio.
SELECT * FROM customers; -- customer_id, customer_city
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM orders; -- order_id, customer_id

SELECT c.customer_city,  SUM(op.payment_value) AS gasto_total
FROM customers c

JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_city 
HAVING SUM(op.payment_value) > (
    SELECT AVG(gasto_total) FROM (
    SELECT SUM (op2.payment_value) AS gasto_total
    FROM customers c2
    JOIN orders o2
    ON c2.customer_id = o2.customer_id
    JOIN order_payments op2
    ON o2.order_id = op2.order_id
    GROUP BY c2.customer_city 
) AS subconsulta
)

-- ###################################################################
-- Mostrar los vendedores cuyo ingreso total supere el ingreso promedio por vendedor.
SELECT * FROM order_items; -- order_id, seller_id
SELECT * FROM order_payments; -- order_id, payment_value

SELECT oi.seller_id, SUM (op.payment_value) AS ingreso 
FROM order_items oi

JOIN order_payments op
ON oi.order_id = op.order_id
GROUP BY oi.seller_id
HAVING  SUM (op.payment_value) > (
    SELECT  AVG(ingreso) FROM (
    SELECT SUM(op2.payment_value) AS ingreso
    FROM order_items oi2
    JOIN order_payments op2
    ON oi2.order_id = op2.order_id
    GROUP BY oi2.seller_id
    ) AS subconsulta 
);


-- ###################################################################
-- Mostrar las categorías cuyo peso promedio sea mayor al promedio general.
SELECT * FROM products; 

SELECT product_category_name, AVG(product_weight_g) AS peso_promedio 
FROM products
GROUP BY product_category_name
HAVING AVG(product_weight_g)  > (
    SELECT AVG(product_weight_g) 
    FROM products

)
; 

-- ###################################################################
-- Mostrar los clientes cuya cantidad de categorías compradas sea mayor al promedio.
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- order_id product_id, order_items_id
SELECT * FROM orders; -- customer_id, order_id
SELECT * FROM customers; -- customer_id, customer_unique_id 

SELECT c.customer_unique_id, COUNT(DISTINCT p.product_category_name) AS cantidad
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON oi.product_id = p.product_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT p.product_category_name) > (
    SELECT AVG (cantidad_categorias) FROM (
        SELECT COUNT(DISTINCT p2.product_category_name) AS cantidad_categorias
        FROM customers c2
        JOIN orders o2
        ON c2.customer_id = o2.customer_id
        JOIN order_items oi2
        ON o2.order_id = oi2.order_id

        JOIN products p2
        ON oi2.product_id = p2.product_id
        GROUP BY c2.customer_unique_id
    ) AS subconsulta
)
;

-- ###################################################################
-- Mostrar los meses cuya cantidad de pedidos sea mayor al promedio mensual.
SELECT * FROM orders; -- order_id, order_purchase_timestamp
--  esto agrupa los meses de todos los años
SELECT  EXTRACT(MONTH FROM order_purchase_timestamp) AS mes, COUNT(*) AS cantidad_pedidos
FROM orders
GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp) 
HAVING COUNT(*) > (
    SELECT AVG(cantidad) FROM (
        SELECT COUNT(*) AS cantidad
        FROM orders
        GROUP BY EXTRACT(MONTH FROM order_purchase_timestamp) 
    ) AS subconsulta
    )
;


-- Si queremos mes-año
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS mes,
    COUNT(*) AS cantidad_pedidos
FROM orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
HAVING COUNT(*) > (
    SELECT AVG(cantidad)
    FROM (
        SELECT
            COUNT(*) AS cantidad
        FROM orders
        GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
    ) AS subconsulta
);


-- ###################################################################
-- Mostrar los clientes cuyo gasto total sea superior al gasto promedio de su estado.
SELECT * FROM customers; -- customer_id, customer_state, customer_unique_id
SELECT * FROM orders; -- customer_id, order_id
SELECT * FROM order_payments; -- order_id, payment_value

-- Es incorrecta!!
SELECT c.customer_unique_id, c.customer_state AS estado, SUM(op.payment_value) AS gastos 
FROM customers c

JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_unique_id, c.customer_state

HAVING  SUM(op.payment_value) > (
    SELECT AVG (gastos) FROM (
      SELECT  SUM(op2.payment_value) AS gastos
      FROM customers c2
      JOIN orders o2
      ON c2.customer_id = o2.customer_id
      JOIN order_payments op2
      ON o2.order_id = op2.order_id
      GROUP BY c2.customer_unique_id, c2.customer_state
    )

)

;


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

SELECT * FROM order_payments;

SELECT AVG(total_pedido) AS promedio_total_pedidos
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS total_pedido
    FROM order_payments
    GROUP BY order_id
) AS pedidos
;

-- ###################################################################
-- Contar cuántos pedidos superan el promedio.

SELECT * FROM order_payments;

SELECT COUNT(*) 
FROM ( SELECT
    SUM(payment_value) AS total_pedido
    FROM order_payments
    GROUP BY order_id
    HAVING SUM(payment_value) > (
        SELECT AVG(total_pedido) FROM 
        ( SELECT 
        SUM(payment_value) AS total_pedido
        FROM order_payments
        GROUP BY order_id        
        ) AS subconsulta

    ) 
) AS pedidos_superiores;

-- ###################################################################
-- Calcular el ticket promedio por cliente.
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM orders: -- order_id, customer_id,
SELECT * FROM customers; -- customer_id, customer_unique_id

SELECT c.customer_unique_id, AVG(total_pedido) AS ticket_promedio
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS total_pedido
    FROM order_payments
    GROUP BY order_id
) AS pagos
    ON o.order_id = pagos.order_id
GROUP BY c.customer_unique_id;


-- ###################################################################
-- Encontrar el cliente con mayor gasto.
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM orders: -- order_id, customer_id,
SELECT * FROM customers; -- customer_id, customer_unique_id

SELECT c.customer_unique_id, SUM(total_gastos) AS total
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS total_gastos
    FROM order_payments
    GROUP BY order_id
) AS pagos
    ON o.order_id = pagos.order_id
GROUP BY c.customer_unique_id
ORDER BY total DESC
LIMIT 1
; 

-- ###################################################################
-- Encontrar la categoría con mayor facturación.
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id, order_id
SELECT * FROM order_payments; -- order_id, payment_value


SELECT
    p.product_category_name,
    SUM(oi.price) AS facturacion
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY facturacion DESC
LIMIT 1;

-- ###################################################################
-- Contar cuántos clientes realizaron más de cinco pedidos.
SELECT * FROM customers; -- customer_id, customer_unique_id
SELECT * FROM orders; -- customer_id, order_id


SELECT COUNT(*) AS cantidad_clientes FROM (
    SELECT c.customer_unique_id, COUNT(o.order_id) AS cantidad_pedidos
    FROM customers c 
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS clientes 
WHERE cantidad_pedidos > 5
;

-- ###################################################################
-- Mostrar el promedio de pedidos por estado.
SELECT * FROM customers; -- customer_id, customer_state
SELECT * orders;  -- customer_id, order_id

SELECT customer_state, AVG(cantidad_pedidos) AS promedio_pedidos 
FROM (
    SELECT
    c.customer_state,
    c.customer_unique_id,
    COUNT(o.order_id) AS cantidad_pedidos
    FROM customers c
    JOIN orders o
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_state, c.customer_unique_id) 
    AS pedidos_cliente
GROUP BY customer_state;  

-- ###################################################################
-- Mostrar el promedio mensual de ventas.
SELECT * FROM orders; -- order_id, order_purchase_timestamp
SELECT * FROM order_payments; -- order_id, payment_value
-- Esta mal
SELECT
    mes,
    AVG(ventas) AS promedio_ventas
FROM (
    SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
    SUM(op.payment_value) AS ventas
    FROM orders o
    JOIN order_payments op
    ON o.order_id = op.order_id
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)) 
    AS ventas_mensuales
GROUP BY  mes
ORDER BY mes ASC
;

SELECT AVG(ventas) AS promedio_mensual_ventas
FROM (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS mes,
        SUM(op.payment_value) AS ventas
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
) AS ventas_mensuales;


-- ###################################################################
-- Mostrar cuántos vendedores superan el ingreso promedio.
SELECT * order_payments -- order_id, payment_value
SELECT * order_items; -- order_id, seller_id
SELECT COUNT(*) AS cantidad_vendedores FROM (
SELECT oi.seller_id, SUM(op.payment_value) AS ingresos_vendedores
FROM order_items oi
JOIN order_payments op
ON oi.order_id = op.order_id
GROUP BY oi.seller_id
HAVING SUM(op.payment_value) > (
    SELECT AVG(cantidad)
    FROM (SELECT oi2.seller_id,  SUM(op2.payment_value) AS cantidad
        FROM order_items oi2
        JOIN order_payments op2
        ON oi2.order_id = op2.order_id
        GROUP BY oi2.seller_id
        ) AS ingresos_vendedores
    )
) AS vendedores_superiores;


-- ###################################################################
-- Mostrar el promedio de productos vendidos por pedido.
SELECT * FROM order_items; -- order_id, product_id

SELECT AVG(cantidad) AS promedio_productos_por_pedido
FROM (
    SELECT 
        order_id,
        COUNT(product_id) AS cantidad
    FROM order_items
    GROUP BY order_id
) AS productos_por_pedido;

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
SELECT * FROM customers; -- customers_id
SELECT * FROM orders; -- customers_id, order_id

SELECT c.customer_id
FROM customers c
WHERE EXISTS (
    SELECT c.customer_id -- 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- ###################################################################
-- Productos vendidos al menos una vez.
SELECT * FROM products; -- products_id
SELECT * FROM order_items; -- order_id,  products_id

SELECT p.product_id 
FROM products p
WHERE EXISTS (
    SELECT 1 -- oi.product_id 
    FROM order_items oi
    WHERE oi.product_id = p.product_id 
)
;


-- ###################################################################
-- Vendedores con al menos un pedido entregado.
SELECT * FROM sellers; -- seller_id
SELECT * FROM order_items; -- seller_id, order_id
SELECT * FROM orders; -- order_id, order_status = 'delivered'

SELECT s.seller_id
FROM sellers s
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    JOIN orders o
    ON oi.order_id = o.order_id
    WHERE oi.seller_id = s.seller_id
    AND 
    o.order_status = 'delivered'
)

-- ###################################################################
-- Clientes que realizaron pedidos cancelados.
SELECT * FROM customers; -- customer_id, customer_unique_id
SELECT * FROM orders; -- order_id, order_status = 'canceled', customer_id

SELECT c.customer_unique_id
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND
    order_status = 'canceled'
);


-- ###################################################################
-- Productos que recibieron alguna review.
SELECT * FROM products; -- product_id
SELECT * FROM order_reviews; -- order_id, order_review_id
SELECT * FROM order_items; -- order_id, id_products

SELECT product_id 
FROM 
products p
WHERE EXISTS(
    SELECT 1
    FROM order_reviews rv
    JOIN order_items oi
    ON rv.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
);

-- NOT EXISTS
-- ###################################################################
-- Productos nunca vendidos.
SELECT * FROM products; -- product_id
SELECT * FROM order_items; -- product_id

SELECT  p.product_id 
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi

    WHERE oi.product_id = p.product_id 
);
SELECT COUNT(*)
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
);
-- No hay

-- ###################################################################
-- Clientes sin pedidos.
SELECT * FROM customers; -- customer_id, customer_unique_id
SELECT * FROM orders; -- customer_id, order_id

SELECT c.customer_unique_id 
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
;

-- ###################################################################
-- Productos sin reviews.
SELECT * FROM order_reviews; -- order_id, review_id
SELECT * FROM order_items; -- order_id, product_id
SELECT * FROM products; -- product_id


SELECT p.product_id 
FROM products p
WHERE NOT EXISTS(
    SELECT 1
    FROM order_reviews rv
    JOIN order_items oi
    ON rv.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
);


-- ###################################################################
-- Vendedores sin pedidos entregados.
SELECT * FROM sellers; -- seller_id
SELECT * FROM orders; -- order_id, order_status = 'delivered' 
SELECT DISTINCT order_status FROM orders;
SELECT * FROM order_items; -- order_id, seller_id

SELECT s.seller_id 
FROM sellers s
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_items oi
    ON o.order_id = oi.order_id
    WHERE oi.seller_id = s.seller_id AND 
    o.order_status = 'delivered' 
); 


-- ###################################################################
-- Categorías que nunca tuvieron ventas.
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id, 

SELECT DISTINCT p.product_category_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1
    FROM products p2
    JOIN order_items oi
        ON oi.product_id = p2.product_id
    WHERE p2.product_category_name = p.product_category_name
);
-- ----------------------------------------------------------------------------
-- Módulo 5 - Subconsultas correlacionadas (10 ejercicios)
-- Responde a la pregunta ¿Cómo se compara esta fila con otras filas relacionadas con ella?
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
-- No es la mejor forma de hacerlo!!
SELECT * FROM customers; -- customer_id
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM orders; -- order_id, customer_id


SELECT o.order_id, o.customer_id, SUM(op.payment_value) AS pago_total
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY o.order_id, o.customer_id
HAVING SUM(op.payment_value) = (
    SELECT MAX(pago_pedido) FROM (
        SELECT o2.order_id, o2.customer_id, SUM(op2.payment_value) AS pago_pedido
        FROM orders o2
        JOIN order_payments op2
        ON o2.order_id = op2.order_id
        
        WHERE o2.customer_id = o.customer_id
        GROUP BY o2.order_id, o2.customer_id

    ) AS pedido_cliente
);




-- ###################################################################
-- Mostrar el producto más caro de cada categoría.
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- product_id, price

SELECT p.product_id, p.product_category_name, oi.price
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
WHERE oi.price = (
    SELECT MAX(oi2.price)
    FROM products p2
    JOIN order_items oi2
        ON p2.product_id = oi2.product_id
    WHERE p2.product_category_name = p.product_category_name
);

-- ###################################################################
-- Mostrar el cliente que más gastó dentro de cada estado.
SELECT * FROM customers; -- customer_id, customer_unique_id, customer_state
SELECT * FROM order_payments; -- order_id, payment_value
SELECT * FROM orders; -- order_id, customer_id

SELECT c.customer_id, c.customer_state, SUM(op.payment_value) AS gasto_total
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY c.customer_id, c.customer_state
HAVING SUM(op.payment_value) = (
    SELECT MAX(gasto_cliente) FROM (
        SELECT c2.customer_id, c2.customer_state, SUM(op2.payment_value) AS gasto_cliente
        FROM customers c2
        JOIN orders o2
            ON c2.customer_id = o2.customer_id
        JOIN order_payments op2
            ON o2.order_id = op2.order_id
        WHERE c2.customer_state = c.customer_state
        GROUP BY c2.customer_id, c2.customer_state
    ) AS gastos_estado
);

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