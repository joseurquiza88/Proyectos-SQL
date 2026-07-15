
-- Consultas de SQL nivel experto
-- ###################################################################
-- 1. Rankear a los vendedores dentro de cada estado según su facturación total, usando RANK().


-- ###################################################################
-- 2. Obtener el top 3 de productos más vendidos (por cantidad) dentro de cada categoría, usando ROW_NUMBER().


-- ###################################################################
-- 3. Hacer un análisis RFM simplificado: para cada cliente, calcular Recencia (días desde su última compra
-- hasta la fecha máxima del dataset), Frecuencia (cantidad de pedidos) y Valor Monetario (total gastado).


-- ###################################################################
-- 4. Armar un análisis de cohortes: agrupar a los clientes según el mes de su primera compra, y ver cuántos
-- siguieron comprando en los meses siguientes (mes 0, mes 1, mes 2, etc.). (Cohortes)


-- ###################################################################
-- 5. Usando LAG(), calcular la cantidad de días transcurridos entre pedidos consecutivos de un mismo cliente
-- (para medir su recurrencia de compra).


-- ###################################################################
-- 6. Calcular qué porcentaje representa cada categoría de producto sobre la facturación total, usando una
-- función de ventana (SUM() OVER()) en lugar de una subconsulta aparte.


-- ###################################################################
-- 7. Construir una tabla RFM por cliente. Mostrar: customer_unique_id, Recency, Frequency, Monetary


-- ###################################################################
-- 8. Percentil 90 del monto de pedidos, marcando outliers.


-- ###################################################################
-- 9. Media móvil de 3 meses de la facturación total (window frame).


-- ###################################################################
-- 10. Market basket: pares de categorías más compradas juntas (self-join)


-- ###################################################################
-- 11. Primer vs. último pedido de cada cliente (FIRST_VALUE / LAST_VALUE).


-- ###################################################################
-- 12. Tasa de retención mensual en % (cohortes llevadas a porcentaje)


-- ###################################################################
-- 13. Serie completa de meses (incluso sin ventas) con generate_series.


-- ###################################################################
-- 14. Detección de "rachas" de compra (pedidos con menos de 30 días entre sí).



-- ###################################################################
-- 15. CTE recursiva: generar una serie de fechas "a mano" (sin generate_series) para practicar WITH RECURSIVE.


-- ###################################################################
-- 16. Segmentar productos en deciles de precio (NTILE 10).



-- ###################################################################
-- 17. Análisis ABC/Pareto: % acumulado de facturación para identificar qué vendedores generan el 80% de las ventas



-- ###################################################################
-- 18. LEAD: detectar si el próximo pedido de un cliente cambia de categoría respecto al actual.



-- ###################################################################
-- 19. Vendedores que compiten en la(s) misma(s) categoría(s) que el vendedor top 1 en facturación (self-join analítico)



-- ###################################################################
-- 20. Evolución del gasto acumulado (lifetime value) de cada cliente, pedido a pedido.



-- ###################################################################
-- 21. Facturación mensual de cada vendedor comparada contra su propio promedio histórico.



-- ###################################################################
-- 22. Meses donde la facturación total cayó más de 20% respecto al mes anterior.



-- ###################################################################
-- 23. Categoría con mayor facturación por cada estado del cliente (una por estado).
 

-- ###################################################################
-- 24. Vendedores "de una sola vez" (solo vendieron en un mes) vs. recurrentes


-- ###################################################################
-- 25. Segmentación RFM completa con etiquetas de negocio (Champions, Leales, En riesgo, Perdidos).