-- Consultas de SQL nivel avanzado


-- ###################################################################
-- 1 Calcular el tiempo promedio (en días) entre la fecha de compra y la fecha de entrega real, solo para pedidos entregados.
SELECT * FROM orders; -- order_purchase_timestamp, order_delivered_customer_date, order_status = 'delivered'

SELECT ROUND(AVG(order_delivered_customer_date::date - order_purchase_timestamp::date),2) AS tiempo_promedio_entrega_dias
 FROM orders
 WHERE order_status = 'delivered'
 ;

-- ###################################################################
-- 2. ¿Qué porcentaje de los pedidos entregados llegó después de la fecha estimada de entrega?
SELECT * FROM orders;
-- 100*((SUM(CASE WHEN ... THEN 1 ELSE 0 END)
SELECT 
    ROUND(
        100.0 * SUM(
            CASE 
                WHEN (order_delivered_customer_date::date - order_estimated_delivery_date::date) > 0 
                THEN 1 
                ELSE 0 
            END
        ) / COUNT(*),
        2
    ) AS porcentaje
FROM orders
WHERE order_status = 'delivered'
;



-- ###################################################################
-- 3. Usando una CTE (WITH), calcular el ticket promedio por pedido y mostrar los pedidos cuyo monto total supera ese promedio.
SELECT * FROM order_items;
WITH ticket_promedio AS (
    SELECT order_id, SUM(price) AS total_pedido
FROM order_items
GROUP BY order_id

)
SELECT *
FROM ticket_promedio
WHERE total_pedido > (SELECT AVG(total_pedido) FROM ticket_promedio)
;

SELECT *
FROM total_pedidos
WHERE total > -- columna de tabla total_pedidos
(SELECT AVG(total) FROM total_pedidos);



'''
Ejemplo
WITH nombre_cte AS (

    consulta
)
SELECT *
FROM nombre_cte;
'''

-- ###################################################################
-- 4. Encontrar los productos que nunca recibieron una reseña.
SELECT * FROM order_reviews; -- review_id, order_id, review_comment_message
SELECT * FROM order_items; -- product_id, order_id,
SELECT * FROM products; -- product_id;

SELECT product_id
FROM products p
WHERE NOT EXISTS (
SELECT 1
FROM order_items oi
JOIN order_reviews r
ON oi.order_id = r.order_id
WHERE oi.product_id = p.product_id
)


-- ###################################################################
-- 5. ¿Cuál es la categoría de producto con mayor cantidad de reseñas de 1 estrella?
SELECT * FROM order_reviews; -- review_id, order_id, review_comment_message
SELECT * FROM order_items; -- product_id, order_id,
SELECT * FROM products; -- product_id; product_category_name

SELECT p.product_category_name AS categoria, COUNT(r.review_score) AS cantidad  
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id

JOIN order_reviews r
ON oi.order_id = r.order_id 
WHERE r.review_score = 1
GROUP BY categoria
ORDER BY cantidad DESC
LIMIT 1
;

-- ###################################################################
-- 6. Calcular por mes, la cantidad de pedidos y el porcentaje de variación respecto al mes anterior.

WITH pedidos_mes AS (
    SELECT 
        DATE_TRUNC('month', order_purchase_timestamp) AS mes,
        COUNT(*) AS cantidad
    FROM orders
    GROUP BY mes
)

SELECT
    mes,
    cantidad,
    LAG(cantidad) OVER (ORDER BY mes) AS cantidad_mes_anterior,
    ROUND(((cantidad - LAG(cantidad) OVER (ORDER BY mes))
     /
     LAG(cantidad) OVER (ORDER BY mes)::numeric
    ) * 100,2) AS variacion_porcentaje
FROM pedidos_mes
ORDER BY mes;

-- OVER respesponde Respecto a qué filas tengo que mirar?"
--  LAG(cantidad) me dice que traiga la fila anterior de cantidad


-- ###################################################################
-- 7. ¿Qué clientes compraron productos de más de una categoría distinta?
SELECT * FROM customers; -- customer_id
SELECT * FROM products; -- product_id, product_category_name
SELECT * FROM order_items; -- order_id, product_id
SELECT * FROM orders; -- order_id, customer_id

SELECT c.customer_id AS cliente
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id

JOIN order_items oi
ON o.order_id = oi.order_id

JOIN products p
ON oi.product_id = p.product_id

GROUP BY c.customer_id
HAVING COUNT(DISTINCT p.product_category_name) > 1
;
-- resultado final ==> customer_id

-- ###################################################################
-- 8. Usando una subconsulta correlacionada, mostrar el pedido de mayor monto total de cada cliente.
SELECT * FROM orders; -- order_id, customer_id
SELECT * FROM order_items;-- monto = price



'''
Para cada pedido...

    Mirar quién es el cliente.

    Buscar cuál es el pedido más caro de ESE cliente.

    ¿Este pedido tiene ese monto?

        Sí → Mostrar.

        No → Ignorar. '''

SELECT
    o.customer_id,
    oi.order_id,
    SUM(oi.price) AS total_pedido
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.customer_id,
    oi.order_id
HAVING SUM(oi.price) = (

    SELECT MAX(total_pedido)
    FROM (

        SELECT
            o2.order_id,
            SUM(oi2.price) AS total_pedido
        FROM orders o2
        JOIN order_items oi2
            ON o2.order_id = oi2.order_id
        WHERE o2.customer_id = o.customer_id
        GROUP BY o2.order_id

    ) t

);
-- ###################################################################
-- 9. Obtener el ranking de vendedores según su facturación. Mostrar: seller_id, ventas, ranking Utilizar una función ventana (DENSE_RANK)


-- ###################################################################
-- 10. Encontrar la categoría de producto con mejor calificación promedio. Considerar solamente categorías con al menos 100 reviews.


-- ###################################################################
-- 11. Para cada estado del cliente obtener el vendedor que más facturó. Debe aparecer un solo vendedor por estado.


-- ###################################################################
-- 12. Mostrar la evolución mensual de las ventas junto con el acumulado histórico.


-- ###################################################################
-- 13. Mostrar el % de pedidos interestatales (vendedor y comprador en distinto estado).


-- ###################################################################
-- 14. Mostrar por mes, cantidad de pedidos de clientes nuevos vs. recurrentes (subconsulta).


-- ###################################################################
-- 15. Mostrar items cuyo flete (freight_value) es mayor al precio del producto.


-- ###################################################################
-- 16. Mostrar la cantidad y % de reviews por puntaje (CTE).



-- ###################################################################
-- 17. Mostrar los clientes con pedidos entregados que nunca dejaron review.



-- ###################################################################
-- 18. Mostrar el tiempo promedio entre aprobación del pago y entrega al transportista, por vendedor


-- ###################################################################
-- 19. Mostrar los pedidos con más de 3 productos distintos.


-- ###################################################################
-- 20. Pedidos con más de 3 productos distintos.

-- ###################################################################
-- 21. Cantidad de pedidos por día de la semana


-- ###################################################################
-- 22. Mostrar clientes cuyo primer pedido fue cancelado (subconsulta con MIN).


-- ###################################################################
-- 23. Mostrar la categoría más vendida (por cantidad) de cada vendedor.


-- ###################################################################
-- 24. Mostrar el % de reviews con comentario vacío vs con comentario, por review_score.


-- ###################################################################
-- 25. Mostrar el top 5 productos con mayor diferencia entre precio mínimo y máximo vendido
