-----------------------------------------------------------
--      SESIÓN 2: TABLA DE PRÁCTICA "Ventas" (bodega)      --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*
QUÉ ES: una tabla pequeña con 10 ventas de una bodega.
Son los mismos datos de las prácticas de la presentación.

CÓMO USARLA:
  1. Ejecuta TODO este archivo UNA sola vez (Ctrl + A y luego F5).
  2. Abre una consulta nueva y escribe tus propias consultas sobre la tabla Ventas.
  Si lo vuelves a ejecutar, la tabla se borra y se crea de nuevo con los mismos datos.

COLUMNAS
  id         número de la venta
  producto   qué se vendió
  categoria  Bebidas, Abarrotes o Snacks
  cantidad   cuántas unidades se vendieron
  precio     precio de UNA unidad (en soles)
  pago       Efectivo, Tarjeta o Yape
  fecha      día de la venta

TIP: el monto de cada venta es cantidad * precio.
*/

USE AdventureWorks2025
GO

-- 1. Borrar la tabla si ya existía (para poder ejecutar el archivo otra vez).
DROP TABLE IF EXISTS dbo.Ventas
GO

-- 2. Crear la tabla.
CREATE TABLE dbo.Ventas (
    id        INT,
    producto  VARCHAR(20),
    categoria VARCHAR(20),
    cantidad  INT,
    precio    DECIMAL(6,2),
    pago      VARCHAR(10),
    fecha     DATE
)
GO

-- 3. Cargar las 10 ventas.
INSERT INTO dbo.Ventas (id, producto, categoria, cantidad, precio, pago, fecha) VALUES
(1,  'Gaseosa',  'Bebidas',   2,  3.00, 'Efectivo', '20261001'),
(2,  'Arroz',    'Abarrotes', 3,  4.00, 'Tarjeta',  '20261001'),
(3,  'Agua',     'Bebidas',   4,  1.50, 'Efectivo', '20261002'),
(4,  'Aceite',   'Abarrotes', 1, 15.00, 'Tarjeta',  '20261002'),
(5,  'Jugo',     'Bebidas',   3,  2.00, 'Yape',     '20261003'),
(6,  'Galletas', 'Snacks',    5,  1.00, 'Efectivo', '20261003'),
(7,  'Leche',    'Abarrotes', 2,  5.00, 'Yape',     '20261005'),
(8,  'Papitas',  'Snacks',    4,  2.50, 'Tarjeta',  '20261005'),
(9,  'Gaseosa',  'Bebidas',   6,  3.00, 'Tarjeta',  '20261010'),
(10, 'Arroz',    'Abarrotes', 5,  4.00, 'Efectivo', '20261012')
GO

-- 4. Comprobar: deben salir 10 filas.
SELECT * FROM dbo.Ventas


/*|=================> PRÁCTICAS CON LA TABLA Ventas <=================|*/
-- Escribe tu consulta debajo de cada pregunta. Recuerda: monto = cantidad * precio.

/*|=================> 1. FUNCIONES DE AGREGACIÓN <=================|*/

-- 1.1 Contar cuántas ventas hay en total y cuántos productos distintos se vendieron (sin repetir).

SELECT COUNT(*) AS cantidad_ventas,
       COUNT(DISTINCT producto) AS productos_distintos

FROM dbo.Ventas


-- 1.2 Calcular el total de unidades vendidas y el dinero total recaudado (monto = cantidad × precio).
SELECT SUM(cantidad) AS cantidades_vendidas,
       SUM(cantidad * precio) AS monto_recaudado

FROM dbo.Ventas


-- 1.3 Mostrar el monto de la venta más grande y el monto promedio por venta.
SELECT MAX(cantidad * precio) AS mayor_venta,
       AVG(cantidad * precio) AS monto_promedio

FROM dbo.Ventas


/*|=================> 2. GROUP BY <=================|*/
SELECT * FROM dbo.Ventas
-- 2.1 Por cada categoría, mostrar la cantidad de ventas y el monto total, ordenado de mayor a menor monto.
SELECT categoria,
       COUNT(*) AS cantidad_ventas,
       SUM(cantidad * precio) AS monto_total
FROM dbo.Ventas
GROUP BY categoria
ORDER BY monto_total DESC


-- 2.2 Por cada forma de pago, mostrar la cantidad de ventas y el monto promedio por venta.
SELECT pago,
       COUNT(*) AS cantidad_ventas,
       AVG(cantidad *  precio) AS promedio

FROM dbo.Ventas
GROUP BY pago


-- 2.3 Por cada categoría, mostrar el total de unidades vendidas y el precio promedio de sus productos.
SELECT categoria,
       SUM(cantidad) AS cantidad_unidades,
       AVG(precio) AS promedio_productos

FROM dbo.Ventas
GROUP BY categoria


/*|=================> 3. WHERE vs HAVING <=================|*/
SELECT * FROM dbo.Ventas
-- 3.1 Mostrar el monto total vendido por categoría, considerando solo las ventas pagadas con Tarjeta.

SELECT categoria, pago,
       SUM(cantidad * precio) AS monto_total
FROM dbo.Ventas
WHERE pago = 'Tarjeta'
GROUP BY categoria, pago

-- 3.2 Mostrar los productos que se vendieron más de una vez, con cuántas veces se vendieron y sus unidades totales.
SELECT producto,
       COUNT(*) AS cantidad,
       SUM(cantidad) AS unidades_totales
FROM dbo.Ventas
GROUP BY producto
HAVING COUNT(*) > 1;


-- 3.3 Considerando solo las ventas en Efectivo, mostrar las categorías cuyo monto total sea mayor a S/ 10.
SELECT categoria,
       SUM(cantidad * precio) AS monto
FROM dbo.Ventas
WHERE pago = 'Efectivo'
GROUP BY categoria
HAVING SUM(cantidad * precio) > 10;


/*|=================> 4. CASE WHEN <=================|*/
SELECT * FROM dbo.Ventas
-- 4.1 Mostrar cada venta con su monto y una columna tipo: 'ALTA' si el monto es S/ 15 o más, 'MEDIA' si es S/ 8 o más y 'BAJA' en otro caso.
SELECT id, producto,
       cantidad * precio AS monto,
       CASE 
            WHEN cantidad * precio >= 15 THEN 'ALTA'
            WHEN cantidad * precio >= 8 THEN 'MEDIA'
            ELSE 'BAJA'
        END AS tipo
FROM dbo.Ventas

-- 4.2 Clasificar las ventas en 'GRANDE' (monto de S/ 10 o más) o 'CHICA', y mostrar cuántas ventas y cuánto dinero hay en cada grupo.
SELECT CASE 
       WHEN cantidad * precio >= 10 THEN 'GRANDE'
       ELSE 'CHICA'
       END AS tamaño,
       COUNT(*) AS cantidad_ventas,
       SUM(cantidad * precio) AS monto
       
FROM dbo.Ventas
GROUP BY CASE 
            WHEN cantidad * precio >= 10 THEN 'GRANDE'
       ELSE 'CHICA' END


-- 4.3 Por cada categoría, contar cuántas ventas se pagaron con medios digitales (todo pago que no sea Efectivo).
SELECT categoria,
       COUNT(*) AS cantidad_ventas
FROM dbo.Ventas
WHERE pago != 'Efectivo'
GROUP BY categoria


SELECT categoria,
       SUM (CASE WHEN pago <> 'Efectivo' THEN 1 ELSE 0 END) AS digitales
FROM dbo.Ventas
GROUP BY categoria

/*|=================> 5. MANEJO DE FECHAS <=================|*/
SELECT * FROM dbo.Ventas
-- 5.1 Mostrar el id de cada venta, su fecha en formato dd/mm/aaaa y el nombre del día de la semana en español.
SELECT id, 
       CONVERT(VARCHAR(10),fecha,103) AS fecha_formato,
       FORMAT(fecha,'dddd','es-AR') AS dia
FROM dbo.Ventas


-- 5.2 Por cada día de la semana (nombre en español), mostrar la cantidad de ventas y el monto total.

SELECT 
       FORMAT(fecha,'dddd','es-AR') AS dia,
       COUNT (*) AS cantidad_ventas,
       SUM(cantidad * precio) AS monto_total
FROM dbo.Ventas
GROUP BY FORMAT(fecha,'dddd','es-AR')

-- 5.3 Si cada venta se cobra el último día del mes, mostrar la fecha de cobro y cuántos días faltan desde la venta.
SELECT  id, fecha,
        EOMONTH(fecha) AS cobro,
        DATEDIFF(DAY, fecha, EOMONTH(fecha)) AS dia_cobro

FROM ventas