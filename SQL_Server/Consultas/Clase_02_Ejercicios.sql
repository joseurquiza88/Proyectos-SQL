
-- Practica 02
-- Conexion base de datos
USE AdventureWorks2025
GO


------------------------------------------------------    EJERCICIO 01   ------------------------------------------------------------------------------

--Usando la tabla Production.Product, mostrar cuántos productos hay en total, cuántos tienen color
-- registrado (Color) y cuál es el precio de lista (ListPrice) más alto.
-- Pista: COUNT(*) cuenta todas las filas; COUNT(Color) no cuenta los productos con color vacío (NULL).

-- Veo la tabla
SELECT * 
FROM Production.Product
-- Hago la consulta
SELECT COUNT(*) AS cantidad_productos,
	  COUNT(color) AS cantidad_color,
	  MAX(ListPrice) AS precio_mas_alto
FROM Production.Product


------------------------------------------------------    EJERCICIO 02   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, mostrar por cada territorio (TerritoryID) la cantidad de
-- pedidos y el total de ventas (TotalDue), ordenado de mayor a menor venta.
-- Pista: lo que va después de «por cada» va en el GROUP BY; para ordenar de mayor a menor usa ORDER
-- BY ... DESC.

-- Veo la tabla
SELECT * FROM Sales.SalesOrderHeader;

-- Hago la consulta
SELECT TerritoryID,
		COUNT(*) AS cantidad_pedidos,
		SUM(TotalDue) AS total_ventas
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
ORDER BY total_ventas DESC;





------------------------------------------------------    EJERCICIO 03   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, mostrar por cada año la cantidad de pedidos y el total de
-- ventas (TotalDue), ordenado por año.
-- Pista: YEAR(OrderDate) saca el año de la fecha; escríbelo igual en el SELECT y en el GROUP BY.

-- Veo la tabla
SELECT * FROM Sales.SalesOrderHeader;

-- Hago la consulta
SELECT YEAR(OrderDate) AS anio,
		COUNT(*) AS cantidad_pedidos,
		SUM(TotalDue) AS total_ventas
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);


------------------------------------------------------    EJERCICIO 04   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, mostrar los territorios (TerritoryID) cuyo total de ventas
--(TotalDue) sea mayor a 10 millones.
-- Pista: la condición usa SUM, así que no va en WHERE sino en HAVING, después del GROUP BY.

-- Veo la tabla
SELECT * FROM Sales.SalesOrderHeader;

-- Hago la consulta
SELECT TerritoryID,
	   SUM(totalDue) AS monto_total
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID
HAVING SUM(totalDue) > 10000000;




------------------------------------------------------    EJERCICIO 05   ------------------------------------------------------------------------------
-- Usando la tabla Sales.SalesOrderHeader, mostrar los primeros 20 pedidos con su ID (SalesOrderID), su
--total (TotalDue) y una columna tamano: 'GRANDE' si el total es 10,000 o más y 'NORMAL' si no.
-- Pista: CASE WHEN condición THEN 'GRANDE' ELSE 'NORMAL' END AS tamano. TOP 20 trae solo las primeras 20
-- filas.
-- Veo la tabla
SELECT * FROM Sales.SalesOrderHeader;

-- Hago la consulta
SELECT TOP 20 SalesOrderID,
		TotalDue,
		CASE
			WHEN TotalDue >= 10000 THEN 'GRANDE'
			ELSE 'NORMAL'
		END AS tamano
FROM Sales.SalesOrderHeader
-- ORDER BY TotalDue; -- se ordena por esa columna




------------------------------------------------------    EJERCICIO 06   ------------------------------------------------------------------------------
-- Usando la tabla HumanResources.Employee, mostrar el cargo (JobTitle), la fecha de ingreso (HireDate) y
--los años que lleva en la empresa, del más antiguo al más nuevo.
-- Pista: DATEDIFF(YEAR, HireDate, GETDATE()) da los años entre la fecha de ingreso y hoy.

-- Veo la tabla
SELECT * FROM HumanResources.Employee;

-- Hago la consulta
SELECT JobTitle, HireDate,
	DATEDIFF(YEAR, HireDate, GETDATE()) AS cantidad_anios -- No son las cantidad de años completos
FROM HumanResources.Employee
ORDER BY DATEDIFF(YEAR, HireDate, GETDATE()) DESC
