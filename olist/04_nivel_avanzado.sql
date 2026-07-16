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


-- ###################################################################
-- 4. Encontrar los productos que nunca recibieron una reseña.


-- ###################################################################
-- 5. ¿Cuál es la categoría de producto con mayor cantidad de reseñas de 1 estrella?


-- ###################################################################
-- 6. Calcular, por mes, la cantidad de pedidos y el porcentaje de variación respecto al mes anterior.

-- ###################################################################
-- 7. ¿Qué clientes compraron productos de más de una categoría distinta?


-- ###################################################################
-- 8. Usando una subconsulta correlacionada, mostrar el pedido de mayor monto total de cada cliente.


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
