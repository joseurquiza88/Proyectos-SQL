-- Consultas de SQL nivel intermedio-avanzado

-- ---------------------------------------------------------------------------------------
-- Subconsultas (8 ejercicios)

-- ###################################################################
-- 1. Mostrar los pedidos cuyo monto total sea mayor que el promedio de todos los pedidos.
SELECT * FROM order_items;

SELECT order_id, SUM(price) AS total_pedido
FROM order_items
GROUP BY order_id
-- Agrupo la suma total y lo compraro (mayor) que el promedio de todos los pedidos
HAVING SUM(price) > (
  SELECT AVG(total_pedido)
  FROM ( -- de donde?
    SELECT order_id, SUM(price) AS total_pedido
    FROM order_items
    GROUP BY order_id
  ) t
);



;

-- ###################################################################
-- 2. Mostrar los clientes que realizaron más pedidos que el promedio de pedidos por cliente.

-- ###################################################################
-- 3. Mostrar las categorías cuyo precio promedio sea mayor que el precio promedio de todas las categorías.

-- ###################################################################
-- 4. ¿Cuántos clientes realizaron más compras que el promedio? (Acá aparece una subconsulta en el FROM.)

-- ###################################################################
-- 5. Mostrar los vendedores cuyo ingreso total sea superior al ingreso promedio de todos los vendedores.

-- ###################################################################
-- 6. Mostrar los pedidos cuyo tiempo de entrega fue mayor al promedio de días de entrega.

-- ###################################################################
-- 7. Mostrar los productos cuyo precio promedio es mayor que el promedio del precio de todos los productos vendidos.

-- ###################################################################
-- 8. Mostrar los estados donde la cantidad de pedidos supera el promedio de pedidos por estado.

-- ---------------------------------------------------------------------------------------
-- Módulo 2 - CTE (6 ejercicios)

-- ###################################################################
-- 9. Usando una CTE, calcular el total gastado por cliente y mostrar los 10 clientes con mayor gasto.

-- ###################################################################
-- 10. Usando una CTE, calcular la cantidad de pedidos por mes y mostrar el mes con más pedidos.

-- ###################################################################
-- 11. Usando una CTE, calcular el promedio de entrega por vendedor.

-- ###################################################################
-- 12. Usando una CTE, calcular el total vendido por categoría y mostrar solo las categorías cuyo total supera el promedio.

-- ###################################################################
-- 13. Usando una CTE, calcular la cantidad de productos vendidos por vendedor y mostrar el Top 5.

-- ###################################################################
-- 14. Usando dos CTE, calcular los pedidos por mes y luego el crecimiento respecto al mes anterior (sin usar LAG, solo para entender cómo dividir el problema).

-- ---------------------------------------------------------------------------------------
-- Módulo 3 - EXISTS / NOT EXISTS (5 ejercicios)

-- Acá la pregunta mental cambia a: "¿Existe o no existe?"

-- ###################################################################
-- 15. Mostrar los clientes que realizaron al menos un pedido.

-- ###################################################################
-- 16. Mostrar los clientes que nunca realizaron pedidos.

-- ###################################################################
-- 17. Mostrar los productos que fueron vendidos al menos una vez.

-- ###################################################################
-- 18. Mostrar los productos que nunca fueron vendidos.

-- ###################################################################
-- 19. Mostrar los vendedores que nunca participaron en un pedido entregado.

-- ---------------------------------------------------------------------------------------
-- Módulo 4 - Window Functions (6 ejercicios) Acá recién aparecen las funciones de ventana.

-- ###################################################################
-- 20. Mostrar cada pedido junto con la fecha del pedido anterior (LAG).

-- ###################################################################
-- 21. Mostrar la cantidad de pedidos por mes y la cantidad del mes anterior (LAG).

-- ###################################################################
-- 22. Calcular la diferencia de pedidos respecto al mes anterior.

-- ###################################################################
-- 23. Calcular el porcentaje de variación respecto al mes anterior.

-- ###################################################################
-- 24. Numerar todos los pedidos de cada cliente según la fecha (ROW_NUMBER).

-- ###################################################################
-- 25. Mostrar el primer pedido realizado por cada cliente (ROW_NUMBER + CTE).