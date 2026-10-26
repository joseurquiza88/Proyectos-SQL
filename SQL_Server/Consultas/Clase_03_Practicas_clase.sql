
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



-- Muestra cada compra (id) con el nombre del cliente, su distrito, el nombre del producto y el monto (cantidad x precio),
-- Pista los datos estan en 3 tablas. Une compras con clientes y con productos usando sus id. 
-- Porque no  aparece la compra 5
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias

SELECT * FROM dbo.Compras
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos

SELECT com.id, cli.nombre, cli.distrito, p.producto, 
(com.cantidad * p.precio) AS monto
FROM dbo.Compras AS com
-- LEFT JOIN dbo.Clientes AS cli
INNER JOIN dbo.Clientes AS cli
ON com.cliente_id = cli.cliente_id
-- LEFT JOIN dbo.Productos p
INNER JOIN dbo.Productos p
ON com.producto_id = p.producto_id;

SELECT com.id, cli.nombre, cli.distrito, p.producto, 
(com.cantidad * p.precio) AS monto
FROM dbo.Compras AS com
LEFT JOIN dbo.Clientes AS cli
-- INNER JOIN dbo.Clientes AS cli
ON com.cliente_id = cli.cliente_id
LEFT JOIN dbo.Productos p
-- INNER JOIN dbo.Productos p
ON com.producto_id = p.producto_id;


-- Muestra el monto total vendido por distrito de mayor a menor

SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias

-- Distrito: Clientes 
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras

SELECT cli.distrito,  
		SUM(com.cantidad * p.precio) AS monto
FROM dbo.Clientes AS cli
INNER JOIN dbo.Compras AS com
ON cli.cliente_id = com.cliente_id
INNER JOIN dbo.Productos p
ON com.producto_id = p.producto_id
GROUP BY cli.distrito
ORDER BY monto DESC;


-- 3.3 Muestra los clientes (sin repetir) que compraron algun producto de la categoria Abarrotes
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias

SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras

SELECT DISTINCT cli.nombre
FROM dbo.Clientes AS cli
INNER JOIN dbo.Compras AS com
ON cli.cliente_id = com.cliente_id
INNER JOIN dbo.Productos AS p
ON com.producto_id = p.producto_id
WHERE p.categoria = 'Abarrotes'


--
-- 4.1 Junta en una solal ista las compras de la tienda y los pedidos de delivery:
-- canal ('tienda' o delivery, fecha, cliente_id y cantidad
-- Pista: compras y delivert tienen columnas parecidas. Agrega una columna fija con el nombre del
-- canal y pon un select debajo del otro. Hace falta quitar repetidos?

SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias
-- Compras
SELECT * FROM dbo.Compras
-- Delivery
SELECT * FROM dbo.Delivery

SELECT 'tienda' AS canal, fecha, cliente_id, cantidad  FROM dbo.Compras
UNION ALL
SELECT 'delivery',  fecha, cliente_id, cantidad FROM dbo.Delivery
ORDER BY canal;


-- 4.2 Muestra los clientes(cliente_id) que compraron en la tienda o por delivery,
-- sin repetir y sin las compras sin cliente.
-- Pista un mismo cliente puede estar en las dos tablas. Elige entre union y union all segun quieras o no repetidos
-- y filtra los nulls

SELECT cliente_id FROM dbo.Compras WHERE cliente_id IS NOT NULL
UNION
SELECT cliente_id FROM dbo.Delivery WHERE cliente_id IS NOT NULL



-- 4.3 Muestra en una sola tabla el monto toal vendido por canal: 
-- Una sola fola para 'Tienda0 y otra para delivery
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias

SELECT 'Tienda' AS canal, SUM(c.cantidad * p.precio) AS monto
FROM dbo.Compras AS c
INNER JOIN dbo.Productos AS p
ON c.producto_id = p.producto_id

UNION ALL

SELECT 'Delivery' AS canal, SUM(d.cantidad * p.precio) AS monto
FROM dbo.Delivery AS d
INNER JOIN dbo.Productos AS p
ON d.producto_id = p.producto_id
