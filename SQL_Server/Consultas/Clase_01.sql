

-- PRÁCTICA 01
USE AdventureWorks2025;
-- Con la base de datos 
------------------------------------------------------    EJERCICIO 01   ------------------------------------------------------------------------------
--- Usando la tabla Production.Product, mostrar eUsando la tabla Production.Product, mostrar el nombre y el precio de lista de los primeros 10 productos cuyo precio sea mayor a 1000.
-- Pista: antes de filtrar, observa qué columnas describen el producto y su precio.

-- 1. Visualizar la tabla inicial
SELECT * FROM Production.Product;

-- 2. Consulta
SELECT TOP 10 Name, ListPrice
FROM Production.Product
WHERE ListPrice > 1000
-- ORDER BY ListPrice DESC; -- Corroboro el maximo


------------------------------------------------------    EJERCICIO 02.   ------------------------------------------------------------------------------
-- Usando la tabla Production.Product, listar el nombre, color y precio de lista de los productos cuyo precio sea mayor a 2000 y que tengan color 'Red' o 'Black'.
-- Pista: revisa qué valores aparecen en la columna de color y prueba combinaciones con OR.

-- 1. Visualizar la tabla inicial
SELECT * FROM Production.Product;


-- 2. Consulta
SELECT Name, Color, ListPrice FROM Production.Product
WHERE ListPrice > 2000
AND (Color = 'Red' OR Color = 'Black')



------------------------------------------------------    EJERCICIO 03   ------------------------------------------------------------------------------

-- Usando la tabla Production.Product, mostrar el nombre del producto y su color. En caso de que el color sea NULL, reemplazarlo
-- por el texto 'Sin color'.
-- Pista: algunos productos no tienen color definido, observa cómo aparecen en la consulta.

-- 1. Visualizar la tabla inicial
SELECT * FROM Production.Product;


-- 2. Consulta
SELECT Name,  ISNULL(Color, 'Sin color') AS Color
FROM Production.Product;

------------------------------------------------------    EJERCICIO 04   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, mostrar el ID de la orden, la fecha de la orden y el total de las órdenes realizadas
-- entre el 1 de enero de 2025 y el 31 de marzo de 2025. Mostrar órdenes realizadas en el primer trimestre de 2025
-- Pista: explora cómo se muestran las fechas en OrderDate y prueba distintos formatos hasta que el filtro funcione.

-- 1. Visualizar la tabla inicial
SELECT *  FROM Sales.SalesOrderHeader;

-- 2. Consulta para ver todos los pedidos con el ID, Fecha 
SELECT SalesOrderID, OrderDate -- , COUNT(SelesOrderID) AS cantidad_ordenes_realizadas  
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2025-01-01'-- '2025-01-01 00:00:00.000' --  -- 
                    AND '2025-03-31'; -- '2025-03-31 23:59:59.000' -- 
-- ORDER BY OrderDate DESC; -- Prueba para ver la fecha


-- 2. Consulta para ver la cantidad total
SELECT COUNT(SalesOrderID) AS cantidad_ordenes_realizadas --
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2025-01-01'-- '2025-01-01 00:00:00.000' --  -- 
                    AND '2025-03-31'; -- '2025-03-31 23:59:59.000' -- 

------------------------------------------------------    EJERCICIO 05   ------------------------------------------------------------------------------
-- Usando la tabla Production.Product, mostrar el nombre del producto (o 'N/D' si es NULL) y calcular el margen dividiendo el
-- precio de lista entre el costo estándar. Si el costo estándar es 0, evitar el error usando NULLIF.
-- Pista: observa qué sucede cuando StandardCost es cero o NULL.

-- 1. Visualizar la tabla inicial
SELECT * FROM Production.Product;


-- 2. Consulta. Se agregan las distintas alternativas segun el valor de StandardCost o ListPrice
SELECT ISNULL(Name, 'N/D') AS Name, ListPrice, StandardCost, 
(ListPrice / NULLIF(StandardCost, 0)) AS Margen
FROM Production.Product
-- Alternativas de resultados
-- WHERE StandardCost = 0 --  Margen = 0
-- WHERE ListPrice = 0 --  Margen = 0
-- WHERE StandardCost IS NULL --  No hay ninguno NULL
-- WHERE ListPrice IS NULL --  No hay ninguno NULL
-- ORDER BY Margen DESC -- Veo si da el calculo en algunos momentos
; 



------------------------------------------------------    EJERCICIO 06   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, calcular el total de ventas y el promedio de ventas por cada año. Si algún registro
-- tuviera TotalDue en NULL, reemplázalo por 0 usando COALESCE para que se considere en el cálculo. Mostrar únicamente los años
 --cuyo total de ventas sea mayor a 1,000,000.
-- Pista: explora la columna OrderDate para identificar cómo agrupar por año.Observa también TotalDue y prueba COALESCE para evitar que los NULL queden fuera del cálculo.

-- 1. Visualizar la tabla inicial
SELECT *FROM Sales.SalesOrderHeader;
-- Prueba
SELECT OrderDate, TotalDue FROM Sales.SalesOrderHeader;


-- 2. Consulta final con el COALESCE
SELECT YEAR(OrderDate) AS anio, SUM(COALESCE(TotalDue, 0)) AS Total_Ventas, AVG(COALESCE(TotalDue, 0)) AS Promedio_Ventas
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
HAVING SUM(COALESCE(TotalDue, 0)) > 1000000
ORDER BY Anio;