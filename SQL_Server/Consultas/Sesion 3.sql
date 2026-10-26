------------------------------------------------------------
--   SESIÓN 3: JOINs, UNION Y MODELAMIENTO DIMENSIONAL   --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*


LA EMPRESA: AdventureWorks vende bicicletas, ropa y accesorios.
En la Sesión 2 trabajamos casi siempre con UNA tabla. El problema: la información
está repartida. El pedido dice TerritoryID = 4, pero el nombre "Southwest" vive en otra tabla.
Hoy aprendemos a JUNTAR tablas.

TABLAS QUE USAREMOS (y la columna que las conecta, su "llave")
  Sales.SalesOrderHeader       pedidos, 1 fila = 1 pedido               (SalesOrderID)
  Sales.SalesOrderDetail       detalle, 1 fila = 1 producto en un pedido (SalesOrderID, ProductID)
  Sales.SalesTerritory         zonas de venta: nombre y país            (TerritoryID)
  Sales.Customer               clientes                                 (CustomerID, PersonID, StoreID)
  Sales.Store                  tiendas (clientes que son negocios)      (BusinessEntityID)
  Person.Person                personas: nombre y apellido              (BusinessEntityID)
  Production.Product           productos                                (ProductID, ProductSubcategoryID)
  Production.ProductSubcategory subcategorías (37)                      (ProductSubcategoryID, ProductCategoryID)
  Production.ProductCategory   categorías (4): Bikes, Components, Clothing, Accessories (ProductCategoryID)

LLAVES
  Llave primaria (PK): identifica cada fila, no se repite. Ej.: TerritoryID en Sales.SalesTerritory.
  Llave foránea  (FK): la misma columna dentro de otra tabla, "apunta" a la PK. Ej.: TerritoryID en Sales.SalesOrderHeader.
  El JOIN une las dos tablas donde PK = FK.
*/

/*|------------------------------> USE <------------------------------|*/
USE AdventureWorks2025
GO

/*|=================> 0. CONOCIENDO LAS TABLAS <=================|*/

-- 0.1 Los pedidos solo tienen el NÚMERO del territorio.
SELECT TOP 5 SalesOrderID, OrderDate, CustomerID, TerritoryID, TotalDue
FROM Sales.SalesOrderHeader

-- 0.2 El nombre del territorio está en otra tabla.
SELECT TerritoryID, Name, CountryRegionCode, [Group]
FROM Sales.SalesTerritory

-- 0.3 Productos, subcategorías y categorías: tres tablas en cadena.
SELECT TOP 5 ProductID, Name, ProductSubcategoryID FROM Production.Product WHERE ProductSubcategoryID IS NOT NULL
SELECT TOP 5 ProductSubcategoryID, ProductCategoryID, Name FROM Production.ProductSubcategory
SELECT ProductCategoryID, Name FROM Production.ProductCategory

-- 0.4 ¿Cuántas filas tiene cada tabla? Sirve para comprobar después si un JOIN "pierde" o "duplica" filas.
SELECT 'Pedidos'   AS tabla, COUNT(*) AS filas FROM Sales.SalesOrderHeader
SELECT 'Detalle'   AS tabla, COUNT(*) AS filas FROM Sales.SalesOrderDetail
SELECT 'Clientes'  AS tabla, COUNT(*) AS filas FROM Sales.Customer
SELECT 'Productos' AS tabla, COUNT(*) AS filas FROM Production.Product


/*|=================> 1. INNER JOIN <=================|*/
-- Une dos tablas y deja SOLO las filas que tienen pareja en las dos.
-- SELECT ... FROM tabla_A INNER JOIN tabla_B ON tabla_A.llave = tabla_B.llave
-- La palabra INNER es opcional: JOIN a secas es un INNER JOIN.

-- 1.1 Cada pedido con el nombre de su territorio.
SELECT Sales.SalesOrderHeader.SalesOrderID,
       Sales.SalesOrderHeader.TotalDue,
       Sales.SalesTerritory.Name
FROM Sales.SalesOrderHeader
INNER JOIN Sales.SalesTerritory
        ON Sales.SalesOrderHeader.TerritoryID = Sales.SalesTerritory.TerritoryID

-- 1.2 Lo mismo, más corto: un alias para cada tabla (h = header, t = territorio).
SELECT h.SalesOrderID,
       h.OrderDate,
       h.TotalDue,
       t.Name AS territorio,
       t.CountryRegionCode AS pais
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesTerritory AS t
        ON h.TerritoryID = t.TerritoryID

-- 1.3 ERROR: columna ambigua. TerritoryID existe en las dos tablas y SQL no sabe cuál usar (quita los -- para probar).
-- SELECT SalesOrderID, TerritoryID, Name
-- FROM Sales.SalesOrderHeader AS h
-- INNER JOIN Sales.SalesTerritory AS t ON h.TerritoryID = t.TerritoryID

-- 1.4 JOIN + GROUP BY: ventas por NOMBRE de territorio (en la Sesión 2 solo teníamos el número).

-- Ventas por territorio:KPI
SELECT t.Name        AS territorio,
       COUNT(*)      AS pedidos,
       SUM(h.TotalDue) AS ventas
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesTerritory AS t ON h.TerritoryID = t.TerritoryID
GROUP BY t.Name
ORDER BY ventas DESC

-- 1.5 Los 10 productos más vendidos, ahora con su nombre.
-- El CAST cambia el tipo de dato en este caso a decimal
SELECT TOP 10
       p.Name                                  AS producto,
       SUM(d.OrderQty)                         AS unidades, -- Cantidad Pedida
       CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ingresos -- Toal linea: precio x cantidad - el descuento en formato decimal
FROM Sales.SalesOrderDetail AS d                    
INNER JOIN Production.Product AS p ON d.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY unidades DESC

-- 1.6 Ojo: INNER JOIN BORRA lo que no tiene pareja. Hay 504 productos, pero solo 295 tienen subcategoría.
-- solo algunos tienen subcategoria entonces se pueden perder en la otra subconsoulta
SELECT COUNT(*) AS productos FROM Production.Product

SELECT COUNT(*) AS productos_con_subcategoria
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID

-- Ver diapo con nombres y el ranking se enteiende
-- En las lineas con el OVER: Porque el primero calcula el monto de cada grupo y el segundo suma esos resultados para obtener el total general.
-- Hay distintas variantes:
-- OVER()	Calcula sobre todas las filas del conjunto.
-- OVER(PARTITION BY columna)	Calcula por separado para cada partición.
-- OVER(ORDER BY columna)	Define un orden para los cálculos, por ejemplo, un acumulado.

SELECT
    CASE WHEN t.CountryRegionCode = 'US' THEN 'EE.UU' ELSE 'Resto' END AS grupo,
    COUNT(h.SalesOrderId) AS N_Ventas,
    ROUND(SUM(h.TotalDue),2)   AS Monto,
    CAST(
        100.0* SUM(h.TotalDue) / SUM(SUM(h.TotalDue)) OVER () AS DECIMAL (5,2)) AS Pct_Monto,
    CAST(
        100.0* COUNT(h.SalesOrderID) / SUM(COUNT(h.SalesOrderID)) OVER () AS DECIMAL (5,2)) AS Pct_Pedidos
    FROM Sales.SalesOrderHeader AS h
    INNER JOIN Sales.SalesTerritory AS t
        ON h.TerritoryID = t.TerritoryID
    GROUP BY CASE WHEN t.CountryRegionCode = 'US' THEN 'EE.UU' ELSE 'Resto' END;

        



/*|=================> 2. TIPOS DE JOIN: LEFT, RIGHT Y FULL <=================|*/
-- LEFT JOIN  deja TODAS las filas de la tabla de la IZQUIERDA (la del FROM), tengan o no pareja.
-- RIGHT JOIN deja TODAS las filas de la tabla de la DERECHA (la del JOIN).
-- FULL JOIN  deja TODO de los dos lados.
-- Si una fila no tiene pareja, las columnas de la otra tabla salen vacías (NULL).
-- Sirven para encontrar lo que FALTA: clientes sin compras, productos sin ventas.

-- 2.1 Todos los productos con su subcategoría: los 504 salen, los que no tienen subcategoría muestran NULL.
-- hacer prueba entre inner vs right  vs left
SELECT p.ProductID, 
       p.Name AS producto, 
       s.Name AS subcategoria
FROM Production.Product AS p
-- LEFT JOIN Production.ProductSubcategory AS s 
INNER JOIN Production.ProductSubcategory AS s 
ON p.ProductSubcategoryID = s.ProductSubcategoryID
-- WHERE s.Name IS NULL -- 209 -- IS NOT NULL -- 295
ORDER BY s.Name

-- Total s

-- 2.2 Productos que NUNCA se vendieron: LEFT JOIN + WHERE la tabla de la derecha IS NULL.
SELECT p.ProductID, p.Name AS producto, p.ListPrice
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS d 
ON p.ProductID = d.ProductID
WHERE d.ProductID IS NULL

-- 2.3 Clientes que nunca hicieron un pedido.
SELECT c.CustomerID, c.PersonID, c.StoreID
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS h ON c.CustomerID = h.CustomerID
WHERE h.SalesOrderID IS NULL

-- 2.4 Después de un LEFT JOIN, cuenta con COUNT(columna de la derecha): COUNT(*) le daría 1 pedido a quien tiene 0.
SELECT TOP 10
       c.CustomerID,
       COUNT(*)              AS con_count_asterisco,
       COUNT(h.SalesOrderID) AS pedidos_reales
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS h 
ON c.CustomerID = h.CustomerID
GROUP BY c.CustomerID
ORDER BY pedidos_reales, c.CustomerID

-- 2.5 Trampa: un filtro sobre la tabla de la derecha en el WHERE convierte el LEFT JOIN en INNER JOIN.
-- A) Filtro en el WHERE: solo quedan los clientes que compraron en 2025.
SELECT COUNT(DISTINCT c.CustomerID) AS clientes
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS h ON c.CustomerID = h.CustomerID
WHERE YEAR(h.OrderDate) = 2025

-- B) Filtro en el ON: salen TODOS los clientes; los que no compraron en 2025 tienen 0 pedidos.
SELECT COUNT(DISTINCT c.CustomerID) AS clientes,
       COUNT(h.SalesOrderID)        AS pedidos_2025
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader AS h
       ON c.CustomerID = h.CustomerID
      AND YEAR(h.OrderDate) = 2025

-- 2.6 RIGHT JOIN es un LEFT JOIN al revés: deja todas las filas de la tabla de la DERECHA. Estas dos dan lo mismo.
SELECT p.Name AS producto, s.Name AS subcategoria
FROM Production.ProductSubcategory AS s
RIGHT JOIN Production.Product AS p ON p.ProductSubcategoryID = s.ProductSubcategoryID

SELECT p.Name AS producto, s.Name AS subcategoria
FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID

-- 2.7 FULL JOIN deja todo de los dos lados: vendedores con su territorio, también los vendedores sin territorio.
SELECT sp.BusinessEntityID AS vendedor, t.Name AS territorio
FROM Sales.SalesPerson AS sp
FULL JOIN Sales.SalesTerritory AS t ON sp.TerritoryID = t.TerritoryID
ORDER BY t.Name


/*|=================> 3. JOIN DE VARIAS TABLAS <=================|*/
-- Se encadenan: cada JOIN nuevo se une con alguna tabla que ya está en la consulta.
-- Truco: dibuja el camino antes de escribir. Detalle → Producto → Subcategoría → Categoría.

-- 3.1 Cada producto con su subcategoría y su categoría (3 tablas).
SELECT p.Name AS producto,
       s.Name AS subcategoria,
       c.Name AS categoria
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory    AS c ON s.ProductCategoryID   = c.ProductCategoryID

-- 3.2 Ventas por categoría (4 tablas): ¿de qué vive AdventureWorks?
SELECT c.Name                                  AS categoria,
       SUM(d.OrderQty)                         AS unidades,
       CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ingresos
FROM Sales.SalesOrderDetail AS d
INNER JOIN Production.Product            AS p ON d.ProductID            = p.ProductID
INNER JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory    AS c ON s.ProductCategoryID    = c.ProductCategoryID
GROUP BY c.Name
ORDER BY ingresos DESC

-- 3.3 Los 5 mejores vendedores con su nombre: el vendedor es una persona (Person.Person).
SELECT TOP 5
       pe.FirstName + ' ' + pe.LastName AS vendedor,
       COUNT(*)                         AS pedidos,
       SUM(h.TotalDue)                  AS ventas
FROM Sales.SalesOrderHeader AS h
INNER JOIN Person.Person AS pe ON h.SalesPersonID = pe.BusinessEntityID
GROUP BY pe.FirstName + ' ' + pe.LastName
ORDER BY ventas DESC

-- 3.4 Ventas por categoría y año: se suma la tabla de pedidos para tener la fecha (5 tablas).
SELECT YEAR(h.OrderDate)                       AS anio,
       c.Name                                  AS categoria,
       CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ingresos
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail        AS d ON h.SalesOrderID         = d.SalesOrderID
INNER JOIN Production.Product            AS p ON d.ProductID            = p.ProductID
INNER JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory    AS c ON s.ProductCategoryID    = c.ProductCategoryID
GROUP BY YEAR(h.OrderDate), c.Name
ORDER BY anio, ingresos DESC

-- 3.5 Trampa: el JOIN repite filas. Un pedido con 3 productos sale 3 veces al unirlo con el detalle.
-- Si sumas TotalDue (que es del PEDIDO) después de unir con el DETALLE, lo sumas 3 veces.
SELECT SUM(TotalDue) AS ventas_correctas
FROM Sales.SalesOrderHeader

SELECT SUM(h.TotalDue) AS ventas_infladas
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID

-- Regla: suma cada número en SU tabla. Si unes con el detalle, suma LineTotal (que es de la línea).
-- Da 109.8 millones y no 123.2: LineTotal no incluye impuestos ni envío (es igual a la suma de SubTotal).
SELECT CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ventas_de_las_lineas
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.SalesOrderDetail AS d ON h.SalesOrderID = d.SalesOrderID

-- 3.6 Un cliente puede ser una persona o una tienda: dos LEFT JOIN y nos quedamos con el nombre que exista.
-- COALESCE(a, b) = si a está vacío, usa b.
SELECT TOP 10
       h.CustomerID,
       COALESCE(st.Name, pe.FirstName + ' ' + pe.LastName) AS cliente,
       CASE WHEN c.StoreID IS NOT NULL THEN 'Tienda' ELSE 'Persona' END AS tipo,
       SUM(h.TotalDue) AS ventas
FROM Sales.SalesOrderHeader AS h
INNER JOIN Sales.Customer AS c  ON h.CustomerID = c.CustomerID
LEFT  JOIN Sales.Store    AS st ON c.StoreID    = st.BusinessEntityID
LEFT  JOIN Person.Person  AS pe ON c.PersonID   = pe.BusinessEntityID
GROUP BY h.CustomerID, COALESCE(st.Name, pe.FirstName + ' ' + pe.LastName),
         CASE WHEN c.StoreID IS NOT NULL THEN 'Tienda' ELSE 'Persona' END
ORDER BY ventas DESC


/*|=================> 4. UNION Y UNION ALL <=================|*/
-- JOIN junta tablas de COSTADO (agrega columnas). UNION las junta HACIA ABAJO (agrega filas).
-- UNION ALL pega todo, con repetidos. UNION pega y quita los repetidos.
-- Reglas: mismo número de columnas, tipos compatibles, los nombres salen de la PRIMERA consulta, ORDER BY solo al final.

-- 4.1 Clientes que compraron en 2024 y clientes que compraron en 2025, en una sola lista.
-- Mira cuántas filas salen abajo a la derecha: UNION ALL = 21,448 · UNION = 18,666 (2,782 clientes compraron los dos años).
SELECT CustomerID 
FROM Sales.SalesOrderHeader 
WHERE YEAR(OrderDate) = 2024 
GROUP BY CustomerID
--
UNION ALL
--
SELECT CustomerID 
FROM Sales.SalesOrderHeader 
WHERE YEAR(OrderDate) = 2025 
GROUP BY CustomerID

-----------------------------
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2024
UNION
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2025

-- 4.2 Armar un reporte por partes: una fila por canal y una fila de TOTAL al final.
-- Arma una tabla digamos, mientra sean los valores

-- Tipo de valores se instancia en la primera tabla
SELECT 'Online' AS canal, COUNT(*) AS pedidos, SUM(TotalDue) AS ventas
FROM Sales.SalesOrderHeader WHERE OnlineOrderFlag = 1
UNION ALL
SELECT 'Vendedor', COUNT(*), SUM(TotalDue)
FROM Sales.SalesOrderHeader WHERE OnlineOrderFlag = 0
UNION ALL
SELECT 'TOTAL', COUNT(*), SUM(TotalDue)
FROM Sales.SalesOrderHeader

-- 4.3 Una sola lista con categorías y subcategorías, con una columna que diga de dónde viene cada fila.
-- Las primeras 4 filas son las categorias y depues estan las subcategorias

SELECT 'Categoría' AS tipo, Name AS nombre FROM Production.ProductCategory
UNION ALL
SELECT 'Subcategoría', Name FROM Production.ProductSubcategory
ORDER BY tipo, nombre

-- 4.4 ERROR: distinto número de columnas (quita los -- para probar).
-- SELECT Name, ProductCategoryID FROM Production.ProductCategory
-- UNION ALL
-- SELECT Name FROM Production.ProductSubcategory

-- 4.5 ERROR: tipos que no se pueden mezclar. Texto en una columna que en la primera consulta es número (quita los -- para probar).
-- SELECT ProductCategoryID FROM Production.ProductCategory
-- UNION ALL
-- SELECT Name FROM Production.ProductSubcategory

-- 4.6 Primos del UNION: INTERSECT = lo que está en las dos · EXCEPT = lo que está en la primera y no en la segunda.
-- Clientes que compraron en 2024 Y en 2025 (2,782).
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2024
INTERSECT
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2025

-- Clientes que compraron en 2024 y NO volvieron en 2025 (8,363). Ojo: 2025 solo llega hasta junio.
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2024
EXCEPT
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2025


/*|=================> 5. MODELAMIENTO DIMENSIONAL: ESTRELLA Y COPO DE NIEVE <=================|*/
-- DATA WAREHOUSE (DW): almacén central que junta los datos de TODAS las áreas, con historia, para analizar.
-- DATA MART: un pedazo del DW enfocado en UN área o proceso (ventas, finanzas). Lo que armamos aquí (dw) es un data mart de ventas.
-- KIMBALL (bottom-up): empieza por data marts en estrella, uno por proceso de negocio, unidos por dimensiones compartidas (bus).
-- INMON (top-down): primero un DW empresarial normalizado (3NF) y de él salen los data marts.
-- HÍBRIDO: una capa central integrada (estilo Inmon) y encima estrellas para el análisis (estilo Kimball).
--
-- MODELO ESTRELLA: es la forma de ordenar las tablas para analizar (la que usa Power BI).
-- TABLA DE HECHOS: lo que pasó, con números para sumar (cantidad, monto) y llaves. Muchas filas.
-- DIMENSIONES: el contexto para filtrar y agrupar (quién, qué, dónde, cuándo). Pocas filas, muchos textos.
-- Grano: qué representa UNA fila de la tabla de hechos. Aquí: 1 fila = 1 producto dentro de un pedido.
-- Vamos a armar la estrella con VISTAS (una vista es una consulta guardada con nombre) en un esquema dw.

-- 5.1 Crear el esquema dw (data warehouse) si no existe.
IF SCHEMA_ID('dw') IS NULL EXEC('CREATE SCHEMA dw')
GO

-- 5.2 Dimensión producto: "aplanamos" producto + subcategoría + categoría en una sola tabla.
CREATE OR ALTER VIEW dw.Dim_Producto AS
SELECT p.ProductID,
       p.Name                            AS producto,
       ISNULL(p.Color, 'Sin color')      AS color,
       ISNULL(s.Name, 'Sin subcategoría') AS subcategoria,
       ISNULL(c.Name, 'Sin categoría')   AS categoria
FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
LEFT JOIN Production.ProductCategory    AS c ON s.ProductCategoryID    = c.ProductCategoryID
GO

-- 5.3 Dimensión territorio: nombre de la zona, país y continente.
CREATE OR ALTER VIEW dw.Dim_Territorio AS
SELECT t.TerritoryID,
       t.Name    AS territorio,
       cr.Name   AS pais,
       t.[Group] AS grupo
FROM Sales.SalesTerritory AS t
INNER JOIN Person.CountryRegion AS cr ON t.CountryRegionCode = cr.CountryRegionCode
GO

-- 5.4 Dimensión cliente: nombre (de la tienda o de la persona) y tipo.
CREATE OR ALTER VIEW dw.Dim_Cliente AS
SELECT c.CustomerID,
       COALESCE(st.Name, pe.FirstName + ' ' + pe.LastName, 'Sin nombre') AS cliente,
       CASE WHEN c.StoreID IS NOT NULL THEN 'Tienda' ELSE 'Persona' END AS tipo
FROM Sales.Customer AS c
LEFT JOIN Sales.Store   AS st ON c.StoreID  = st.BusinessEntityID
LEFT JOIN Person.Person AS pe ON c.PersonID = pe.BusinessEntityID
GO

-- 5.5 Dimensión fecha: una fila por cada día con pedidos, con sus partes ya calculadas.
CREATE OR ALTER VIEW dw.Dim_Fecha AS
SELECT DISTINCT
       CAST(OrderDate AS DATE)          AS fecha,
       YEAR(OrderDate)                  AS anio,
       MONTH(OrderDate)                 AS mes,
       FORMAT(OrderDate, 'MMMM', 'es-PE') AS nombre_mes,
       DATEPART(QUARTER, OrderDate)     AS trimestre
FROM Sales.SalesOrderHeader
GO

-- 5.6 Tabla de hechos: una fila por línea de pedido, con las llaves de cada dimensión y las medidas.
CREATE OR ALTER VIEW dw.Fact_Ventas AS
SELECT d.SalesOrderDetailID,
       d.SalesOrderID,
       CAST(h.OrderDate AS DATE) AS fecha,        -- llave a Dim_Fecha
       h.CustomerID,                              -- llave a Dim_Cliente
       d.ProductID,                               -- llave a Dim_Producto
       h.TerritoryID,                             -- llave a Dim_Territorio
       CASE WHEN h.OnlineOrderFlag = 1 THEN 'Online' ELSE 'Vendedor' END AS canal,
       d.OrderQty                AS cantidad,     -- medida
       d.LineTotal               AS monto         -- medida
FROM Sales.SalesOrderDetail AS d
INNER JOIN Sales.SalesOrderHeader AS h ON d.SalesOrderID = h.SalesOrderID
GO

-- 5.7 Comprobar el grano: la tabla de hechos debe tener las mismas filas que el detalle (121,317).
SELECT COUNT(*) AS filas_fact FROM dw.Fact_Ventas
SELECT COUNT(*) AS filas_detalle FROM Sales.SalesOrderDetail

-- 5.8 Consulta estrella: la tabla de hechos al centro y cada dimensión con un JOIN directo.
-- Ventas de 2024 por país y categoría. Compárala con la 3.4: ya no hay cadenas de JOIN.
SELECT t.pais,
       p.categoria,
       SUM(f.cantidad)                     AS unidades,
       CAST(SUM(f.monto) AS DECIMAL(18,2)) AS ventas
FROM dw.Fact_Ventas AS f
INNER JOIN dw.Dim_Producto   AS p  ON f.ProductID   = p.ProductID
INNER JOIN dw.Dim_Territorio AS t  ON f.TerritoryID = t.TerritoryID
INNER JOIN dw.Dim_Fecha      AS fe ON f.fecha       = fe.fecha
WHERE fe.anio = 2024
GROUP BY t.pais, p.categoria
ORDER BY t.pais, ventas DESC

-- 5.9 Otra pregunta, mismas piezas: ventas por mes y canal en 2024.
SELECT fe.mes,
       fe.nombre_mes,
       f.canal,
       CAST(SUM(f.monto) AS DECIMAL(18,2)) AS ventas
FROM dw.Fact_Ventas AS f
INNER JOIN dw.Dim_Fecha AS fe ON f.fecha = fe.fecha
WHERE fe.anio = 2024
GROUP BY fe.mes, fe.nombre_mes, f.canal
ORDER BY fe.mes, f.canal

-- 5.10 La MISMA pregunta de la 5.8, pero en COPO DE NIEVE: las tablas originales, normalizadas.
-- La dimensión producto está partida en 3 tablas (producto → subcategoría → categoría) y el territorio en 2.
-- Mismo resultado, pero 6 JOIN en vez de 3.
SELECT cr.Name                                 AS pais,
       c.Name                                  AS categoria,
       SUM(d.OrderQty)                         AS unidades,
       CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ventas
FROM Sales.SalesOrderDetail AS d
INNER JOIN Sales.SalesOrderHeader        AS h  ON d.SalesOrderID         = h.SalesOrderID
INNER JOIN Production.Product            AS p  ON d.ProductID            = p.ProductID
INNER JOIN Production.ProductSubcategory AS s  ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory    AS c  ON s.ProductCategoryID    = c.ProductCategoryID
INNER JOIN Sales.SalesTerritory          AS t  ON h.TerritoryID          = t.TerritoryID
INNER JOIN Person.CountryRegion          AS cr ON t.CountryRegionCode    = cr.CountryRegionCode
WHERE YEAR(h.OrderDate) = 2024
GROUP BY cr.Name, c.Name
ORDER BY pais, ventas DESC

-- 5.11 El precio de la estrella: repite textos. En la estrella, 'Bikes' se escribe una vez por cada bicicleta (97 veces);
-- en el copo de nieve se escribe una sola vez en ProductCategory.
SELECT categoria, COUNT(*) AS veces_que_se_repite
FROM dw.Dim_Producto
GROUP BY categoria
ORDER BY veces_que_se_repite DESC

SELECT ProductCategoryID, Name FROM Production.ProductCategory

-- 5.12 Para borrar la estrella al terminar la clase (quita los -- para probar).
-- DROP VIEW IF EXISTS dw.Fact_Ventas, dw.Dim_Producto, dw.Dim_Territorio, dw.Dim_Cliente, dw.Dim_Fecha
-- DROP SCHEMA IF EXISTS dw


/*|=================> 6. CASO INTEGRADOR Y PRÁCTICA (SOLUCIONES) <=================|*/

-- 6.1 Caso integrador: «Por país y categoría, quiero ver cuánto vendimos en 2024, cuántas unidades
-- y cuántos clientes distintos compraron. Solo las combinaciones con más de 1 millón.»
SELECT t.pais,
       p.categoria,
       CAST(SUM(f.monto) AS DECIMAL(18,2)) AS ventas,
       SUM(f.cantidad)                     AS unidades,
       COUNT(DISTINCT f.CustomerID)        AS clientes
FROM dw.Fact_Ventas AS f                                            -- hechos
INNER JOIN dw.Dim_Producto   AS p  ON f.ProductID   = p.ProductID   -- qué
INNER JOIN dw.Dim_Territorio AS t  ON f.TerritoryID = t.TerritoryID -- dónde
INNER JOIN dw.Dim_Fecha      AS fe ON f.fecha       = fe.fecha      -- cuándo
WHERE fe.anio = 2024                                                -- filtra filas
GROUP BY t.pais, p.categoria                                        -- por cada país y categoría
HAVING SUM(f.monto) > 1000000                                       -- filtra grupos
ORDER BY ventas DESC

-- 6.2 Práctica 1: cada producto con el nombre de su subcategoría. ¿Cuántas filas salen? (295)
SELECT p.Name AS producto, s.Name AS subcategoria
FROM Production.Product AS p
INNER JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID

-- 6.3 Práctica 2: por cada territorio (con su nombre), la cantidad de clientes.
SELECT t.Name AS territorio, COUNT(*) AS clientes
FROM Sales.Customer AS c
INNER JOIN Sales.SalesTerritory AS t ON c.TerritoryID = t.TerritoryID
GROUP BY t.Name
ORDER BY clientes DESC

-- 6.4 Práctica 3: los productos que nunca se vendieron (238).
SELECT p.ProductID, p.Name AS producto
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS d ON p.ProductID = d.ProductID
WHERE d.ProductID IS NULL

-- 6.5 Práctica 4: ingresos (LineTotal) por subcategoría de la categoría Bikes.
SELECT s.Name AS subcategoria, CAST(SUM(d.LineTotal) AS DECIMAL(18,2)) AS ingresos
FROM Sales.SalesOrderDetail AS d
INNER JOIN Production.Product            AS p ON d.ProductID            = p.ProductID
INNER JOIN Production.ProductSubcategory AS s ON p.ProductSubcategoryID = s.ProductSubcategoryID
INNER JOIN Production.ProductCategory    AS c ON s.ProductCategoryID    = c.ProductCategoryID
WHERE c.Name = 'Bikes'
GROUP BY s.Name
ORDER BY ingresos DESC

-- 6.6 Práctica 5: una sola lista con el nombre de cada territorio y de cada país, sin repetir.
SELECT Name FROM Sales.SalesTerritory
UNION
SELECT cr.Name
FROM Sales.SalesTerritory AS t
INNER JOIN Person.CountryRegion AS cr ON t.CountryRegionCode = cr.CountryRegionCode

-- 6.7 Práctica 6: clientes que compraron en 2023 y no volvieron a comprar en 2024 (1,349).
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2023
EXCEPT
SELECT CustomerID FROM Sales.SalesOrderHeader WHERE YEAR(OrderDate) = 2024
