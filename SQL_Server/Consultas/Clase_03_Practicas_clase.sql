
-- Mostrar cada comprea (ID) con el nombre del producto, la cantidad y el monto.
--Compras solo guarda el producto_id, el nombre y el rprecio esta en productos
-- Une las dos  tblas y calcula el monto como cantidad por precio
USE AdventureWorks2025
GO
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias


-- Mostrar ID, nombre producto, cantidad y monto
SELECT c.id,p.producto, c.cantidad,
c.cantidad * p.precio AS monto

FROM compras AS c 
INNER JOIN productos AS p
ON p.producto_id = c.producto_id


--Mostrar cada copra (id, con el nombr del cliente.  Cuantas filas salen y porque?. 
-- El nombre del cliente esta en clientes y se enlaza con compras por cliente_id
-- Compras tiene 8 filas:compara ese numero con las filas que devuelve la consulta y revisa la columna cliente_id
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Compras
-- la compra 5 no tiene id entonces el inner join la deja afuera
SELECT com.id, cli.nombre 

FROM dbo.Compras com
INNER JOIN clientes cli
ON com.cliente_id = cli.cliente_id

-- Mostrar le monto total vendido por categoria de mayor a menor.
-- La categoria esta en productos. Une compras con productos, suma cantidad x precio de
-- todas las compras de cada cateogria y oderna del total mas altoal mas bajo

SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras

SELECT p.categoria, 
SUM(p.precio * c.cantidad) AS monto
FROM Productos p
INNER JOIN Compras c
ON p.producto_id = c.producto_id
GROUP BY p.categoria
ORDER BY SUM(p.precio * c.cantidad) DESC;


-- Muestra todos los clientes con su cantidad de compras, incluidos los que no compraron.
-- Pista from clientes. No se puede perder ningun cliente
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Compras

SELECT cli.nombre, COUNT(com.id) AS compras
FROM dbo.Clientes cli
LEFT JOIN dbo.Compras com
ON cli.cliente_id = com.cliente_id
GROUP BY cli.nombre

-- Muestra todos los productos con sus unidades vendidas (0 sino se vendio)
-- Pista FROM compras. La tabla que debe salir completa en segundo lugar

SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras

SELECT p.producto, ISNULL(SUM(c.cantidad),0) AS unidades 
FROM dbo.Compras c
RIGHT JOIN Productos p
ON c.producto_id = p.producto_id
GROUP BY p.producto
ORDER BY ISNULL(SUM(c.cantidad),0) DESC;

-- Junda en una sola lista todas las compras(id) y todos los clientes(nombre. 
-- Que filas tienne nukk
-- Pista: ninguna tabla puede perder filas
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Clientes

SELECT com.id, cli.nombre 
FROM dbo.Compras com
FULL JOIN dbo.Clientes cli
ON com.cliente_id = cli.cliente_id