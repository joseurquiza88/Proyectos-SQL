------------------------------------------------------------
--   SESIÓN 3: TABLAS DE PRÁCTICA DE LA BODEGA (JOINs, UNION y modelo)   --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*
QUÉ ES: la misma bodega de la Sesión 2, pero ahora los datos están repartidos en 5 tablas pequeñas.
Son los mismos datos de las prácticas de la presentación.

CÓMO USARLA:
  1. Ejecuta TODO este archivo UNA sola vez (Ctrl + A y luego F5).
  2. Abre una consulta nueva y escribe tus propias consultas sobre estas tablas.
  Si lo vuelves a ejecutar, las tablas se borran y se crean de nuevo con los mismos datos.

TABLAS Y COLUMNAS
  Clientes    (5 filas)  cliente_id, nombre, distrito
  Productos   (6 filas)  producto_id, producto, categoria, precio (de UNA unidad, en soles)
  Compras     (8 filas)  ventas en la tienda: id, fecha, cliente_id, producto_id, cantidad, pago
  Delivery    (3 filas)  pedidos por WhatsApp: id, fecha, cliente_id, producto_id, cantidad
  Categorias  (3 filas)  categoria, encargado (quién se encarga de cada categoría)

CÓMO SE CONECTAN
  Compras.cliente_id  = Clientes.cliente_id    (la compra 5 no tiene cliente: fue alguien "al paso")
  Compras.producto_id = Productos.producto_id
  Delivery usa las mismas llaves.
  Productos.categoria = Categorias.categoria   (la usamos en el tema 5, copo de nieve)

TIP: el monto de cada compra es cantidad * precio, y el precio está en la tabla Productos.
*/

USE AdventureWorks2025
GO

-- 1. Borrar las tablas si ya existían (para poder ejecutar el archivo otra vez).
DROP VIEW  IF EXISTS dbo.vw_Compras
DROP TABLE IF EXISTS dbo.Compras, dbo.Delivery, dbo.Clientes, dbo.Productos, dbo.Categorias
GO

-- 2. Crear las tablas.
CREATE TABLE dbo.Clientes (
    cliente_id INT,
    nombre     VARCHAR(20),
    distrito   VARCHAR(20)
)

CREATE TABLE dbo.Productos (
    producto_id INT,
    producto    VARCHAR(20),
    categoria   VARCHAR(20),
    precio      DECIMAL(6,2)
)

CREATE TABLE dbo.Compras (
    id          INT,
    fecha       DATE,
    cliente_id  INT,
    producto_id INT,
    cantidad    INT,
    pago        VARCHAR(10)
)

CREATE TABLE dbo.Categorias (
    categoria VARCHAR(20),
    encargado VARCHAR(20)
)

CREATE TABLE dbo.Delivery (
    id          INT,
    fecha       DATE,
    cliente_id  INT,
    producto_id INT,
    cantidad    INT
)
GO

-- 3. Cargar los datos.
INSERT INTO dbo.Clientes (cliente_id, nombre, distrito) VALUES
(1, 'Ana',   'Miraflores'),
(2, 'Luis',  'Surco'),
(3, 'Carla', 'Miraflores'),
(4, 'Pedro', 'San Borja'),
(5, 'Rosa',  'Surco')

INSERT INTO dbo.Productos (producto_id, producto, categoria, precio) VALUES
(1, 'Gaseosa',   'Bebidas',    3.00),
(2, 'Agua',      'Bebidas',    1.50),
(3, 'Arroz',     'Abarrotes',  4.00),
(4, 'Aceite',    'Abarrotes', 15.00),
(5, 'Galletas',  'Snacks',     1.00),
(6, 'Chocolate', 'Snacks',     2.50)

INSERT INTO dbo.Compras (id, fecha, cliente_id, producto_id, cantidad, pago) VALUES
(1, '20261001', 1,    1, 2, 'Efectivo'),
(2, '20261001', 2,    3, 3, 'Tarjeta'),
(3, '20261002', 1,    2, 4, 'Efectivo'),
(4, '20261002', 3,    4, 1, 'Tarjeta'),
(5, '20261003', NULL, 5, 5, 'Efectivo'),
(6, '20261005', 4,    1, 6, 'Yape'),
(7, '20261005', 2,    5, 3, 'Yape'),
(8, '20261010', 3,    3, 5, 'Efectivo')

INSERT INTO dbo.Categorias (categoria, encargado) VALUES
('Bebidas',   'Marta'),
('Abarrotes', 'Jorge'),
('Snacks',    'Marta')

INSERT INTO dbo.Delivery (id, fecha, cliente_id, producto_id, cantidad) VALUES
(1, '20261004', 2, 4, 1),
(2, '20261006', 5, 2, 6),
(3, '20261008', 1, 1, 3)
GO

-- 4. Comprobar: deben salir 5, 6, 8, 3 y 3 filas.
SELECT * FROM dbo.Clientes
SELECT * FROM dbo.Productos
SELECT * FROM dbo.Compras
SELECT * FROM dbo.Delivery
SELECT * FROM dbo.Categorias


/*|=================> PRÁCTICAS CON LAS TABLAS DE LA BODEGA <=================|*/
-- Escribe tu consulta debajo de cada pregunta. Recuerda: monto = cantidad * precio.

/*|=================> 1. INNER JOIN <=================|*/

-- 1.1 Mostrar cada compra (id) con el nombre del producto, la cantidad y el monto.



-- 1.2 Mostrar cada compra (id) con el nombre del cliente. ¿Cuántas filas salen y por qué?



-- 1.3 Mostrar el monto total vendido por categoría, de mayor a menor.



/*|=================> 2. TIPOS DE JOIN: LEFT, RIGHT Y FULL <=================|*/

-- 2.1 (LEFT JOIN) Mostrar TODOS los clientes con la cantidad de compras que hicieron en la tienda (también los que no compraron).



-- 2.2 (RIGHT JOIN) Con Compras a la izquierda y Productos a la derecha, mostrar TODOS los productos con las unidades vendidas en la tienda (0 si no se vendieron).



-- 2.3 (FULL JOIN) Mostrar en una sola lista todas las compras (id) y todos los clientes (nombre), aunque no tengan pareja. ¿Qué filas tienen NULL?



/*|=================> 3. JOIN DE VARIAS TABLAS <=================|*/

-- 3.1 Mostrar cada compra (id) con el nombre del cliente, su distrito, el nombre del producto y el monto.



-- 3.2 Mostrar el monto total vendido por distrito, de mayor a menor.



-- 3.3 Mostrar los clientes (sin repetir) que compraron algún producto de la categoría Abarrotes.



/*|=================> 4. UNION Y UNION ALL <=================|*/

-- 4.1 Juntar en una sola lista las compras de la tienda y los pedidos de delivery, con las columnas: canal ('Tienda' o 'Delivery'), fecha, cliente_id, producto_id y cantidad.



-- 4.2 Mostrar la lista de clientes (cliente_id) que compraron por la tienda o por delivery, sin repetir y sin las compras que no tienen cliente.



-- 4.3 Mostrar en una sola tabla el monto total vendido por canal: una fila para 'Tienda' y otra para 'Delivery'.



/*|=================> 5. MODELAMIENTO DIMENSIONAL: ESTRELLA Y COPO DE NIEVE <=================|*/
-- Compras es la TABLA DE HECHOS (lo que pasó, con cantidades). Clientes y Productos son las DIMENSIONES (quién y qué).
-- Si la categoría tiene su propia tabla (Categorias), la dimensión producto se "parte" en dos: eso es un COPO DE NIEVE.

-- 5.1 (Estrella) Mostrar el monto total por distrito y categoría (la tabla de hechos unida con sus dos dimensiones).



-- 5.2 (Copo de nieve) Mostrar el monto total vendido por encargado: Compras → Productos → Categorias.



-- 5.3 Crear la vista dbo.vw_Compras con una fila por compra (fecha, cliente, distrito, producto, categoría, pago y monto, incluyendo las compras sin cliente) y, desde la vista, mostrar el monto total por forma de pago.
