------------------------------------------------------------
--      SESIÓN 2: AGREGACIONES Y ANÁLISIS DE NEGOCIO      --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*|------------------------------> USE <------------------------------|*/
USE AdventureWorks2025
GO

/*|=================> 0. CONOCIENDO LAS TABLAS <=================|*/

-- 0.1 Ver los pedidos.
SELECT * FROM Sales.SalesOrderHeader

-- 0.2 Ver el detalle de los pedidos (qué productos tiene cada pedido).
SELECT * FROM Sales.SalesOrderDetail

-- 0.3 Ver los productos.
SELECT * FROM Production.Product

-- 0.4 Ver qué significa cada TerritoryID (zona de venta).
SELECT TerritoryID, Name, CountryRegionCode, [Group]
FROM Sales.SalesTerritory

-- 0.5 ¿Desde y hasta qué fecha hay pedidos?
SELECT MIN(OrderDate) AS primer_pedido,
       MAX(OrderDate) AS ultimo_pedido
FROM Sales.SalesOrderHeader


/*|=================> 1. FUNCIONES DE AGREGACIÓN <=================|*/
-- Resumen muchas filas en UN solo valor:
-- COUNT = contar | SUM = sumar | AVG = promedio | MIN = mínimo | MAX = máximo

-- 1.1 Cantidad de pedidos, ventas totales, monto promedio por pedido, pedido mínimo y pedido máximo.
SELECT COUNT(*)      AS total_pedidos,
       SUM(TotalDue) AS ventas_totales,
       AVG(TotalDue) AS monto_promedio,
       MIN(TotalDue) AS pedido_minimo,
       MAX(TotalDue) AS pedido_maximo
FROM Sales.SalesOrderHeader

-- 1.2 Lo mismo, redondeado a 2 decimales (ROUND y CAST).
SELECT COUNT(*)                             AS total_pedidos,
       CAST(SUM(TotalDue) AS DECIMAL(18,2)) AS ventas_totales,
       ROUND(AVG(TotalDue), 2)              AS monto_promedio
FROM Sales.SalesOrderHeader

-- 1.3 MIN y MAX también funcionan con fechas y textos.
SELECT MIN(OrderDate) AS primera_venta,
       MAX(OrderDate) AS ultima_venta
FROM Sales.SalesOrderHeader

SELECT MIN(Name) AS primer_nombre_az,
       MAX(Name) AS ultimo_nombre_az
FROM Production.Product

-- 1.4 Tres formas de contar: COUNT(*) cuenta filas, COUNT(columna) cuenta solo las celdas con dato y COUNT(DISTINCT columna) cuenta valores sin repetir.
SELECT COUNT(*)                      AS total_pedidos,
       COUNT(SalesPersonID)          AS pedidos_con_vendedor,
       COUNT(DISTINCT CustomerID)    AS clientes_distintos,
       COUNT(DISTINCT SalesPersonID) AS vendedores_distintos
FROM Sales.SalesOrderHeader

-- 1.5 AVG tampoco cuenta las celdas vacías (NULL).
-- ISNULL(Weight, 0) = si el peso está vacío, ponle 0.
SELECT COUNT(*)               AS productos,
       COUNT(Weight)          AS productos_con_peso,
       AVG(Weight)            AS peso_prom_sin_nulos,
       AVG(ISNULL(Weight, 0)) AS peso_prom_nulo_cero
FROM Production.Product

-- 1.6 Ojo: el promedio de una columna de números ENTEROS sale sin decimales. Multiplicar por 1.0 lo arregla.
SELECT AVG(OrderQty)       AS promedio_entero,
       AVG(OrderQty * 1.0) AS promedio_decimal
FROM Sales.SalesOrderDetail


/*|=================> 2. GROUP BY <=================|*/
-- Agrupa las filas y calcula la agregación para CADA grupo.
-- "Por cada ___ quiero saber ___"  →  lo que va después de "por cada" va en el GROUP BY.

-- 2.1 Por cada territorio: cantidad de pedidos y ventas, de mayor a menor venta.
SELECT TerritoryID,
       COUNT(*)                AS pedidos,
       SUM(TotalDue)           AS ventas,
       ROUND(AVG(TotalDue), 2) AS monto_promedio
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY ventas DESC

-- 2.2 Por cada canal (1 = online, 0 = vendedor): cantidad de pedidos y ventas.
SELECT OnlineOrderFlag,
       COUNT(*)                AS pedidos,
       SUM(TotalDue)           AS ventas,
       ROUND(AVG(TotalDue), 2) AS monto_promedio
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag

-- 2.3 Regla de oro: toda columna del SELECT debe estar en el GROUP BY o dentro de una función (SUM, COUNT...). Esta consulta rompe la regla.
-- (Quita los -- y ejecútalo para ver el error)
-- SELECT TerritoryID, CustomerID, SUM(TotalDue)
-- FROM Sales.SalesOrderHeader
-- GROUP BY TerritoryID

-- 2.4 Si agrupas por una fórmula, escríbela completa en el GROUP BY: cantidad de pedidos y ventas por año.
SELECT YEAR(OrderDate) AS anio,
       COUNT(*)        AS pedidos,
       SUM(TotalDue)   AS ventas
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY anio

-- 2.5 Agrupar por dos columnas: sale un grupo por cada combinación de año y canal.
SELECT YEAR(OrderDate) AS anio,
       OnlineOrderFlag,
       COUNT(*)        AS pedidos,
       SUM(TotalDue)   AS ventas
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), OnlineOrderFlag
ORDER BY anio, OnlineOrderFlag

-- 2.6 Las celdas vacías (NULL) forman su propio grupo: cantidad de productos y precio promedio por color.
SELECT Color,
       COUNT(*)                 AS productos,
       ROUND(AVG(ListPrice), 2) AS precio_promedio
FROM Production.Product
GROUP BY Color
ORDER BY productos DESC

-- 2.7 Productos más vendidos (en unidades), de mayor a menor.
SELECT ProductID,
       SUM(OrderQty)                         AS unidades_vendidas,
       CAST(SUM(LineTotal) AS DECIMAL(18,2)) AS ingresos
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY unidades_vendidas DESC

-- 2.8 Clientes que más compran con vendedor, de mayor a menor.
SELECT CustomerID,
       COUNT(*)      AS pedidos,
       SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0
GROUP BY CustomerID
ORDER BY ventas DESC


/*|=================> 3. WHERE vs HAVING <=================|*/
-- WHERE  filtra FILAS  (antes de agrupar)
-- HAVING filtra GRUPOS (después de agrupar, usa SUM/COUNT/AVG...)
-- Orden en que SQL ejecuta: FROM > WHERE > GROUP BY > HAVING > SELECT > ORDER BY

-- 3.1 El orden en que SQL lee la consulta (mira el número de paso al lado de cada línea).
SELECT TerritoryID, SUM(TotalDue) AS ventas_online   -- 5. SELECT: columnas y alias
FROM Sales.SalesOrderHeader                          -- 1. FROM: de qué tabla
WHERE OnlineOrderFlag = 1                            -- 2. WHERE: quita filas (solo online)
GROUP BY TerritoryID                                 -- 3. GROUP BY: arma grupos
HAVING SUM(TotalDue) > 5000000                       -- 4. HAVING: quita grupos
ORDER BY ventas_online DESC                          -- 6. ORDER BY: ordena (aquí SÍ sirve el alias)

-- 3.2 WHERE: ventas por territorio, solo de pedidos online.
SELECT TerritoryID, SUM(TotalDue) AS ventas_online
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 1
GROUP BY TerritoryID
ORDER BY ventas_online DESC

-- 3.3 HAVING: territorios con ventas mayores a 10 millones.
SELECT TerritoryID, SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
HAVING SUM(TotalDue) > 10000000
ORDER BY ventas DESC

-- 3.4 WHERE + HAVING: clientes con vendedor que hicieron 10 pedidos o más.
SELECT CustomerID, COUNT(*) AS pedidos, SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader
WHERE OnlineOrderFlag = 0          -- filtra filas
GROUP BY CustomerID
HAVING COUNT(*) >= 10              -- filtra grupos
ORDER BY ventas DESC

-- 3.5 ERROR: SUM dentro del WHERE (quita los -- para probar).
-- SELECT TerritoryID, SUM(TotalDue) AS ventas
-- FROM Sales.SalesOrderHeader
-- WHERE SUM(TotalDue) > 10000000
-- GROUP BY TerritoryID

-- 3.6 ERROR: usar el alias en el HAVING (quita los -- para probar).
-- SELECT TerritoryID, SUM(TotalDue) AS ventas
-- FROM Sales.SalesOrderHeader
-- GROUP BY TerritoryID
-- HAVING ventas > 10000000

-- 3.7 Parecidas pero distintas:
-- A) Cantidad de pedidos mayores a 5,000 por territorio (WHERE: mira cada pedido).
SELECT TerritoryID, COUNT(*) AS pedidos_mayores_5000
FROM Sales.SalesOrderHeader
WHERE TotalDue > 5000
GROUP BY TerritoryID

-- B) Territorios con monto promedio por pedido mayor a 5,000 (HAVING: mira el promedio del grupo).
SELECT TerritoryID, ROUND(AVG(TotalDue), 2) AS monto_promedio
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
HAVING AVG(TotalDue) > 5000

-- 3.8 Si la condición no usa SUM/COUNT/AVG, va en WHERE.
SELECT TerritoryID, COUNT(*) AS pedidos     -- funciona, pero no es lo ideal
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
HAVING TerritoryID IN (7, 8, 10)

SELECT TerritoryID, COUNT(*) AS pedidos     -- forma correcta
FROM Sales.SalesOrderHeader
WHERE TerritoryID IN (7, 8, 10)
GROUP BY TerritoryID


/*|=================> 4. CASE WHEN <=================|*/
-- Es el SI de Excel: CASE WHEN condición THEN valor ... ELSE valor END

-- 4.1 Clasificar cada pedido: 10,000 o más 'GRANDE', 1,000 o más 'MEDIANO', si no 'PEQUEÑO'.
SELECT SalesOrderID, TotalDue,
       CASE
           WHEN TotalDue >= 10000 THEN 'GRANDE'
           WHEN TotalDue >= 1000  THEN 'MEDIANO'
           ELSE 'PEQUEÑO'
       END AS tipo_pedido
FROM Sales.SalesOrderHeader

-- 4.2 Regla: gana el primer WHEN que se cumple. ¿Qué pasa si las condiciones están en otro orden?
SELECT TotalDue,
       CASE
           WHEN TotalDue >= 1000  THEN 'MEDIANO'
           WHEN TotalDue >= 10000 THEN 'GRANDE'
           ELSE 'PEQUEÑO'
       END AS tipo_mal_ordenado
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC

-- 4.3 Regla: si no pones ELSE, lo que no cumple ninguna condición queda vacío (NULL).
SELECT Color,
       CASE Color WHEN 'Black' THEN 'Negro' WHEN 'Red' THEN 'Rojo' END AS color_es
FROM Production.Product
WHERE Color IS NOT NULL

-- 4.4 Segmentar: cantidad de pedidos y ventas por tipo de pedido.
SELECT CASE
           WHEN TotalDue >= 10000 THEN '1. GRANDE'
           WHEN TotalDue >= 1000  THEN '2. MEDIANO'
           ELSE '3. PEQUEÑO'
       END AS tipo_pedido,
       COUNT(*)      AS pedidos,
       SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader
GROUP BY CASE
             WHEN TotalDue >= 10000 THEN '1. GRANDE'
             WHEN TotalDue >= 1000  THEN '2. MEDIANO'
             ELSE '3. PEQUEÑO'
         END
ORDER BY tipo_pedido

-- 4.5 Traducir códigos: mostrar el canal y el país con palabras.
SELECT SalesOrderID,
       CASE OnlineOrderFlag
           WHEN 1 THEN 'Online'
           WHEN 0 THEN 'Vendedor'
       END AS canal,
       CASE TerritoryID
           WHEN 6  THEN 'Canadá'
           WHEN 7  THEN 'Francia'
           WHEN 8  THEN 'Alemania'
           WHEN 9  THEN 'Australia'
           WHEN 10 THEN 'Reino Unido'
           ELSE 'Estados Unidos'
       END AS pais,
       TotalDue
FROM Sales.SalesOrderHeader

-- 4.6 Contar con condición: por año, cuántos pedidos fueron online y cuántos con vendedor.
-- SUM(CASE ... THEN 1 ELSE 0 END) = contar solo los que cumplen (como CONTAR.SI).
SELECT YEAR(OrderDate) AS anio,
       COUNT(*)                                             AS total_pedidos,
       SUM(CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 0 END) AS pedidos_online,
       SUM(CASE WHEN OnlineOrderFlag = 0 THEN 1 ELSE 0 END) AS pedidos_vendedor
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY anio

-- 4.7 Agrupar por un CASE: cantidad de productos por rango de precio (económico, medio, premium).
SELECT CASE
           WHEN ListPrice = 0    THEN '0. SIN PRECIO'
           WHEN ListPrice < 100  THEN '1. ECONÓMICO'
           WHEN ListPrice < 1000 THEN '2. MEDIO'
           ELSE '3. PREMIUM'
       END AS rango_precio,
       COUNT(*) AS productos
FROM Production.Product
GROUP BY CASE
             WHEN ListPrice = 0    THEN '0. SIN PRECIO'
             WHEN ListPrice < 100  THEN '1. ECONÓMICO'
             WHEN ListPrice < 1000 THEN '2. MEDIO'
             ELSE '3. PREMIUM'
         END
ORDER BY rango_precio


/*|=================> 5. MANEJO DE FECHAS <=================|*/
-- Sirven para EXTRAER partes de una fecha (año, mes, día), FORMATEARLA (mostrarla como texto)
-- y CALCULAR con fechas (sumar días, contar meses entre dos fechas).

-- 5.1 La fecha y hora de hoy. GETDATE y SYSDATETIME dan el mismo momento; SYSDATETIME muestra más decimales en los segundos.
SELECT GETDATE()     AS ahora_getdate,
       SYSDATETIME() AS ahora_sysdatetime

-- 5.2 Funciones de fecha con un ejemplo: 31/05/2024 a las 2:30 p. m.
-- YEAR / MONTH: sacan una parte · DATEADD: suma tiempo · DATEDIFF: cuenta el tiempo entre dos fechas · EOMONTH: último día del mes
SELECT YEAR('20240531 14:30')                      AS anio,
       MONTH('20240531 14:30')                     AS mes,
       DATEPART(QUARTER, '20240531 14:30')         AS trimestre,
       DATENAME(MONTH, '20240531 14:30')           AS nombre_mes,
       CAST('20240531 14:30' AS DATE)              AS solo_fecha,
       DATEADD(DAY, 30, '20240531 14:30')          AS mas_30_dias,
       DATEDIFF(DAY, '20240501', '20240531 14:30') AS dias_pasados,
       EOMONTH('20240531 14:30')                   AS fin_de_mes,
       DATEFROMPARTS(2024, 5, 1)                   AS armada

-- Formatos (FORMAT y CONVERT necesitan que la fecha sea de tipo fecha: por eso el CAST).
SELECT CONVERT(VARCHAR(10), CAST('20240531 14:30' AS DATETIME), 103) AS fecha_peru,
       FORMAT(CAST('20240531 14:30' AS DATETIME), 'yyyy-MM')         AS anio_mes,
       FORMAT(CAST('20240531 14:30' AS DATETIME), 'MMMM', 'es-PE')   AS mes_espanol

-- 5.3 Extraer: año, mes, día, trimestre y nombre del mes de cada pedido.
SELECT OrderDate,
       YEAR(OrderDate)              AS anio,
       MONTH(OrderDate)             AS mes,
       DAY(OrderDate)               AS dia,
       DATEPART(QUARTER, OrderDate) AS trimestre,
       DATENAME(MONTH, OrderDate)   AS nombre_mes,
       DATENAME(WEEKDAY, OrderDate) AS nombre_dia
FROM Sales.SalesOrderHeader

-- 5.4 Formatear: mostrar la fecha con otro formato (el resultado es TEXTO).
-- 103 = dd/mm/yyyy | 'es-PE' = en español
SELECT OrderDate,
       CAST(OrderDate AS DATE)                 AS solo_fecha,
       CONVERT(VARCHAR(10), OrderDate, 103)    AS fecha_dd_mm_yyyy,
       FORMAT(OrderDate, 'yyyy-MM')            AS anio_mes,
       FORMAT(OrderDate, 'MMMM yyyy', 'es-PE') AS mes_espanol,
       FORMAT(OrderDate, 'dddd', 'es-PE')      AS dia_espanol
FROM Sales.SalesOrderHeader

-- 5.5 Manipular: calcular con fechas.
-- DATEDIFF ( unidad , fecha_inicio , fecha_fin ) | DATEADD ( unidad , cantidad , fecha )
SELECT OrderDate, ShipDate,
       DATEDIFF(DAY, OrderDate, ShipDate)                  AS dias_hasta_envio,
       DATEADD(DAY, 30, OrderDate)                         AS fecha_mas_30_dias,
       DATEADD(MONTH, -1, OrderDate)                       AS un_mes_antes,
       DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS primer_dia_mes,
       EOMONTH(OrderDate)                                  AS ultimo_dia_mes
FROM Sales.SalesOrderHeader

-- 5.6 Trampa: DATEDIFF con años solo resta los años del calendario. Prueba con el 31/12/2025 y el 01/01/2026.
SELECT DATEDIFF(YEAR, '20251231', '20260101') AS resultado

-- Años en la empresa y edad de cada empleado (aproximados, por la trampa de arriba).
SELECT JobTitle, HireDate, BirthDate,
       DATEDIFF(YEAR, HireDate, GETDATE())  AS anios_en_empresa,
       DATEDIFF(YEAR, BirthDate, GETDATE()) AS edad
FROM HumanResources.Employee
ORDER BY HireDate

-- 5.7 Escribe las fechas como 'AAAAMMDD' (sin guiones) para evitar confusiones entre día y mes.
SELECT CAST('20240601' AS DATETIME) AS uno_de_junio

-- 5.8 Para filtrar un año: con YEAR o con un rango de fechas. Dan lo mismo, pero el rango es más rápido en tablas grandes.
SELECT COUNT(*) AS pedidos_2024
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2024

SELECT COUNT(*) AS pedidos_2024
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '20240101' AND OrderDate < '20250101'

-- 5.9 Antes de filtrar, explora: la fecha más antigua y la más reciente.
SELECT MIN(OrderDate) AS primera_fecha, MAX(OrderDate) AS ultima_fecha
FROM Sales.SalesOrderHeader

-- 5.10 Cantidad de pedidos y ventas por año y mes.
SELECT YEAR(OrderDate)  AS anio,
       MONTH(OrderDate) AS mes,
       COUNT(*)         AS pedidos,
       SUM(TotalDue)    AS ventas
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY anio, mes

-- 5.11 Cantidad de pedidos por día de la semana (DATENAME da el nombre del día).
SELECT DATENAME(WEEKDAY, OrderDate) AS dia,
       COUNT(*)                     AS pedidos
FROM Sales.SalesOrderHeader
GROUP BY DATENAME(WEEKDAY, OrderDate)
ORDER BY pedidos DESC

-- 5.12 Ventas de los últimos 3 meses de la base.
-- La última fecha de la base es 2025-06-29 (la vimos en 5.9). Tres meses antes es 2025-03-29.
SELECT COUNT(*)      AS pedidos,
       SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader
WHERE OrderDate > '20250329'