------------------------------------------------------------
--   SESIÓN 3: DISEÑO DEL MODELO DIMENSIONAL PASO A PASO   --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*
PARA QUÉ SIRVE ESTE SCRIPT
En el proyecto final les piden: "Diseño del modelo dimensional: construir un modelo tipo
estrella, definiendo la tabla de hechos, sus dimensiones, las claves y las relaciones entre ellas".
Aquí lo hacemos completo, de cero, en una base de datos NUEVA (no toca AdventureWorks).

LA EMPRESA: ZapaUrban vende zapatillas y accesorios en Lima.
  - 2 tiendas físicas (Jockey Plaza y Mega Plaza) y 1 tienda web.
  - Vende en soles. Los datos van de enero a marzo de 2026.

EL CAMINO (cada paso es una sección del script)
  0. Crear la base de datos
  1. Las tablas del sistema de ventas (de donde salen los datos)
  2. Paso 1: la pregunta del negocio
  3. Paso 2: el grano (qué es UNA fila de la tabla de hechos)
  4. Paso 3: las dimensiones
  5. Paso 4: la tabla de hechos
  6. Paso 5: claves y relaciones (PK y FK) + el diagrama en SSMS
  7. Paso 6: cargar las dimensiones
  8. Paso 7: cargar la tabla de hechos y validar
  9. Paso 8: consultas de análisis sobre la estrella
  10. Tarea: tu propio modelo estrella

CÓMO USARLO: ejecuta sección por sección (selecciona el bloque y F5).
Si lo ejecutas completo otra vez, la base se borra y se crea de nuevo con los mismos datos.
Al final de cada sección hay PREGUNTAS PARA LOS ALUMNOS (las respuestas están en el solucionario).
*/


/*|=================> 0. CREAR LA BASE DE DATOS <=================|*/

-- 0.1 Nos paramos en master para poder borrar y crear la base.
USE master
GO

-- 0.2 Si la base ya existe, la borramos (cierra las conexiones abiertas primero).
IF DB_ID('ZapaUrban') IS NOT NULL
BEGIN
    ALTER DATABASE ZapaUrban SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE ZapaUrban
END
GO

-- 0.3 Creamos la base nueva y nos pasamos a ella.
CREATE DATABASE ZapaUrban
GO
USE ZapaUrban
GO

-- 0.4 Dos esquemas (carpetas) para no mezclar:
--     ops = el sistema de ventas del día a día (de donde salen los datos)
--     dw  = el modelo estrella que vamos a construir (para analizar)
CREATE SCHEMA ops
GO
CREATE SCHEMA dw
GO


/*|=================> 1. LAS TABLAS DEL SISTEMA DE VENTAS <=================|*/
-- Así guarda los datos el sistema de la caja: muchas tablas pequeñas, sin repetir nada.
-- Es bueno para REGISTRAR ventas, pero incómodo para ANALIZAR.
-- Ojo: los datos vienen "sucios" a propósito, como pasa en la vida real.

-- 1.1 Clientes. Los distritos están escritos de varias formas y hay correos vacíos.
CREATE TABLE ops.Clientes (
    ClienteID      INT PRIMARY KEY,
    Nombre         VARCHAR(60),
    DNI            CHAR(8),
    Distrito       VARCHAR(40),
    Email          VARCHAR(60),
    FechaRegistro  DATE
)
INSERT INTO ops.Clientes VALUES
 (1, 'Ana Torres',     '70123456', 'Miraflores',             'ana@mail.com',   '2025-06-10'),
 (2, 'Luis Quispe',    '71234567', 'san juan de lurigancho', NULL,             '2025-08-02'),
 (3, 'Camila Rojas',   '72345678', 'SURCO',                  'cami@mail.com',  '2025-09-15'),
 (4, 'Diego Huamán',   '73456789', 'Los Olivos',             NULL,             '2025-11-20'),
 (5, 'Valeria Chávez', '74567890', ' miraflores',            'vale@mail.com',  '2025-12-01'),
 (6, 'Bruno Salazar',  '75678901', 'Callao',                 'bruno@mail.com', '2026-01-03'),
 (7, 'Sofía Mendoza',  '76789012', '  surco',                NULL,             '2026-01-28'),
 (8, 'Mateo Flores',   '77890123', NULL,                     'mateo@mail.com', '2026-02-20')

-- 1.2 Categorías de producto.
CREATE TABLE ops.Categorias (
    CategoriaID  INT PRIMARY KEY,
    Nombre       VARCHAR(30)
)
INSERT INTO ops.Categorias VALUES
 (1, 'Running'), (2, 'Urbanas'), (3, 'Básquet'), (4, 'Accesorios')

-- 1.3 Productos. El producto solo guarda el NÚMERO de su categoría.
CREATE TABLE ops.Productos (
    ProductoID   INT PRIMARY KEY,
    Nombre       VARCHAR(60),
    Marca        VARCHAR(30),
    CategoriaID  INT REFERENCES ops.Categorias(CategoriaID),
    PrecioLista  DECIMAL(10,2),
    Costo        DECIMAL(10,2)
)
INSERT INTO ops.Productos VALUES
 (1, 'Air Zoom Pegasus',  'Nike',     1, 459, 250),
 (2, 'Ultraboost Light',  'Adidas',   1, 649, 360),
 (3, 'Air Force 1',       'Nike',     2, 499, 270),
 (4, 'Old Skool',         'Vans',     2, 299, 150),
 (5, 'Chuck Taylor',      'Converse', 2, 249, 120),
 (6, 'LeBron XXI',        'Nike',     3, 799, 450),
 (7, 'Medias pack x3',    'Nike',     4,  59,  20),
 (8, 'Gorra Trucker',     'Vans',     4,  89,  35),
 (9, 'Mochila Classic',   'Adidas',   4, 149,  70)

-- 1.4 Tiendas.
CREATE TABLE ops.Tiendas (
    TiendaID  INT PRIMARY KEY,
    Nombre    VARCHAR(40),
    Tipo      VARCHAR(20),
    Distrito  VARCHAR(40)
)
INSERT INTO ops.Tiendas VALUES
 (1, 'Jockey Plaza', 'Física', 'Surco'),
 (2, 'Mega Plaza',   'Física', 'Independencia'),
 (3, 'Tienda Web',   'Online', 'Lima')

-- 1.5 Vendedores. La tienda web no tiene vendedores.
CREATE TABLE ops.Vendedores (
    VendedorID  INT PRIMARY KEY,
    Nombre      VARCHAR(60),
    TiendaID    INT REFERENCES ops.Tiendas(TiendaID)
)
INSERT INTO ops.Vendedores VALUES
 (1, 'Rosa Paredes', 1), (2, 'Kevin Ramos', 1), (3, 'Jhon Castillo', 2), (4, 'Andrea Vega', 2)

-- 1.6 Ventas (la cabecera de la boleta). Una fila = una boleta.
--     Las ventas web no tienen vendedor (NULL) y la boleta 13 no tiene cliente (compró "al paso").
CREATE TABLE ops.Ventas (
    VentaID       INT PRIMARY KEY,
    NumeroBoleta  VARCHAR(15),
    FechaHora     DATETIME,
    ClienteID     INT NULL,
    TiendaID      INT,
    VendedorID    INT NULL,
    MedioPago     VARCHAR(20)
)
INSERT INTO ops.Ventas VALUES
 ( 1, 'B001-0001', '2026-01-05 11:20', 1,    1, 1,    'Tarjeta'),
 ( 2, 'B001-0002', '2026-01-12 16:45', 2,    2, 3,    'Efectivo'),
 ( 3, 'B001-0003', '2026-01-18 21:10', 3,    3, NULL, 'Yape'),
 ( 4, 'B001-0004', '2026-01-25 13:05', 4,    1, 2,    'Tarjeta'),
 ( 5, 'B001-0005', '2026-02-02 09:30', 5,    3, NULL, 'Tarjeta'),
 ( 6, 'B001-0006', '2026-02-08 18:00', 1,    1, 1,    'Yape'),
 ( 7, 'B001-0007', '2026-02-14 12:15', 6,    2, 4,    'Efectivo'),
 ( 8, 'B001-0008', '2026-02-14 22:40', 7,    3, NULL, 'Yape'),
 ( 9, 'B001-0009', '2026-02-21 17:25', 3,    1, 2,    'Tarjeta'),
 (10, 'B001-0010', '2026-03-01 15:50', 8,    2, 3,    'Plin'),
 (11, 'B001-0011', '2026-03-07 20:05', 2,    3, NULL, 'Yape'),
 (12, 'B001-0012', '2026-03-14 19:35', 5,    1, 1,    'Tarjeta'),
 (13, 'B001-0013', '2026-03-20 14:10', NULL, 2, 4,    'Efectivo'),
 (14, 'B001-0014', '2026-03-28 10:55', 4,    3, NULL, 'Plin')

-- 1.7 Detalle de la venta. Una fila = un producto dentro de una boleta.
--     Esta tabla NO tiene llave primaria y por eso se coló una fila DUPLICADA (venta 7, línea 2).
CREATE TABLE ops.DetalleVenta (
    VentaID         INT,
    Linea           INT,
    ProductoID      INT,
    Cantidad        INT,
    PrecioUnitario  DECIMAL(10,2),
    Descuento       DECIMAL(10,2)   -- descuento en soles para toda la línea
)
INSERT INTO ops.DetalleVenta VALUES
 ( 1, 1, 1, 1, 459,  0), ( 1, 2, 7, 2,  59,  0),
 ( 2, 1, 5, 1, 249,  0),
 ( 3, 1, 2, 1, 649, 50), ( 3, 2, 8, 1,  89,  0),
 ( 4, 1, 3, 1, 499,  0),
 ( 5, 1, 4, 2, 299,  0),
 ( 6, 1, 6, 1, 799, 80),
 ( 7, 1, 3, 1, 499,  0), ( 7, 2, 7, 1,  59,  0), ( 7, 2, 7, 1,  59,  0),   -- <- la última está duplicada
 ( 8, 1, 5, 2, 249,  0),
 ( 9, 1, 1, 1, 459,  0),
 (10, 1, 4, 1, 299, 30), (10, 2, 8, 2,  89,  0),
 (11, 1, 3, 1, 499,  0),
 (12, 1, 2, 1, 649,  0), (12, 2, 7, 3,  59,  0),
 (13, 1, 5, 1, 249,  0),
 (14, 1, 6, 1, 799,  0)

-- 1.8 Miremos lo que tenemos.
SELECT * FROM ops.Clientes
SELECT * FROM ops.Productos
SELECT * FROM ops.Ventas
SELECT * FROM ops.DetalleVenta

/*
PREGUNTAS PARA LOS ALUMNOS (sección 1)
  P1.1 ¿Cuántas filas tiene ops.DetalleVenta? ¿Y cuántas deberían ser sin el duplicado?
       Pista: COUNT(*) y COUNT de un SELECT DISTINCT.
  P1.2 ¿Cuántas formas distintas de escribir "Miraflores" y "Surco" hay en ops.Clientes?
       Pista: SELECT DISTINCT Distrito.
  P1.3 ¿Qué producto existe en el catálogo pero nunca se vendió?
       Pista: LEFT JOIN de Productos con DetalleVenta.
*/
GO

--Resolvemos

-- P1.1 Filas del detalle (20) y filas sin el duplicado (19)
SELECT COUNT(*) AS filas FROM ops.DetalleVenta
SELECT COUNT(*) AS filas_sin_duplicado
FROM (SELECT DISTINCT * FROM ops.DetalleVenta) AS x

SELECT VentaID, Linea, ProductoID, Cantidad, PrecioUnitario, Descuento,
       COUNT(*) AS veces
FROM ops.DetalleVenta
GROUP BY VentaID, Linea, ProductoID, Cantidad, PrecioUnitario, Descuento
HAVING COUNT(*) > 1

SELECT*FROM ops.DetalleVenta
-- P1.2 Formas distintas de escribir cada distrito
SELECT DISTINCT Distrito FROM ops.Clientes

SELECT DISTINCT
       Distrito AS original,
       ISNULL(UPPER(LTRIM(RTRIM(Distrito))), 'NO REGISTRADO') AS limpio
FROM ops.Clientes



/*|=================> 2. PASO 1: LA PREGUNTA DEL NEGOCIO <=================|*/
-- Todo modelo empieza con una PREGUNTA, no con las tablas.
-- El gerente de ZapaUrban quiere saber:
--   "¿Cuánto vendemos y cuánto ganamos por mes, por tienda, por categoría y por cliente?"
-- Las palabras "cuánto" son las MEDIDAS (números que se suman): monto vendido, ganancia, unidades.
-- Las palabras "por ..." son las DIMENSIONES (cómo cortamos los números): fecha, tienda, producto, cliente.

-- 2.1 Así se responde HOY con las tablas del sistema: 5 tablas y 4 JOIN para un reporte simple.

SELECT  MONTH(v.FechaHora)                             AS Mes,
        t.Nombre                                       AS Tienda,
        c.Nombre                                       AS Categoria,
        SUM(d.Cantidad * d.PrecioUnitario - d.Descuento) AS Monto
FROM ops.Ventas v
JOIN ops.DetalleVenta d ON d.VentaID     = v.VentaID
JOIN ops.Tiendas     t ON t.TiendaID     = v.TiendaID
JOIN ops.Productos   p ON p.ProductoID   = d.ProductoID
JOIN ops.Categorias  c ON c.CategoriaID  = p.CategoriaID
GROUP BY MONTH(v.FechaHora), t.Nombre, c.Nombre
ORDER BY MONTH(v.FechaHora), t.Nombre

-- ¿Ven el problema? El duplicado de la venta 7 se suma dos veces y nadie se da cuenta.

SELECT v.VentaID,
       v.FechaHora,
       MONTH(v.FechaHora) AS Mes,
       t.Nombre           AS Tienda,
       d.Linea,
       p.Nombre           AS Producto,
       c.Nombre           AS Categoria,
       d.Cantidad,
       d.PrecioUnitario,
       d.Descuento
FROM ops.Ventas v
JOIN ops.Tiendas      t ON t.TiendaID    = v.TiendaID
JOIN ops.DetalleVenta d ON d.VentaID     = v.VentaID
JOIN ops.Productos    p ON p.ProductoID  = d.ProductoID
JOIN ops.Categorias   c ON c.CategoriaID = p.CategoriaID
WHERE v.VentaID = 7

-- Y cada reporte nuevo obliga a recordar qué tabla se une con cuál.

/*
PREGUNTAS PARA LOS ALUMNOS (sección 2)
  P2.1 En la pregunta "¿cuántas unidades vendió cada marca por mes?", ¿cuál es la medida y cuáles son las dimensiones?
  P2.2 ¿Por qué el reporte 2.1 da un monto de febrero en Mega Plaza más alto que el real?
       Pista: mira la venta 7.
  P2.3 Escribe UNA pregunta de negocio para tu proyecto final y marca sus medidas y sus dimensiones.
*/
GO


/*|=================> 3. PASO 2: EL GRANO <=================|*/
-- El GRANO dice qué representa UNA fila de la tabla de hechos. Se decide ANTES de crear tablas.
-- Opciones para ZapaUrban:
--   a) 1 fila = 1 boleta              -> no podríamos saber qué producto se vendió.
--   b) 1 fila = 1 producto en 1 boleta -> el nivel más fino que tenemos.  <- ELEGIMOS ESTE
--   c) 1 fila = ventas de 1 día        -> ya viene resumido, perdemos detalle.
-- Regla de oro: elige el nivel MÁS FINO. Resumir después es fácil; "des-resumir" es imposible.

-- 3.1 Con el grano elegido, la tabla de hechos tendrá tantas filas como el detalle SIN duplicados.
SELECT COUNT(*) AS filas_detalle_limpio
FROM (SELECT DISTINCT * FROM ops.DetalleVenta) AS x

/*
PREGUNTAS PARA LOS ALUMNOS (sección 3)
  P3.1 Si el grano fuera "1 fila = 1 boleta", ¿podrías responder "unidades vendidas por categoría"? ¿Por qué?
  P3.2 ¿Cuántas filas tendría la tabla de hechos con el grano "1 fila = 1 boleta"?
  P3.3 Escribe el grano de tu proyecto final en una frase: "1 fila = ...".
*/
GO


/*|=================> 4. PASO 3: LAS DIMENSIONES <=================|*/
-- Una DIMENSIÓN responde quién, qué, dónde y cuándo. Tiene texto para filtrar y agrupar.
-- Para ZapaUrban: DimFecha (cuándo), DimCliente (quién compra), DimProducto (qué),
--                 DimTienda (dónde) y DimVendedor (quién vende).
-- Cada dimensión lleva:
--   - una CLAVE SUSTITUTA (surrogate key): un número nuevo 1, 2, 3... que crea el DW (IDENTITY).
--   - la CLAVE NATURAL (o de negocio): el ID que traía el sistema, para saber de dónde vino.
--   - los ATRIBUTOS ya limpios y en texto (nada de "CategoriaID = 2", sino "Urbanas").
-- ¿Por qué no usar el ID del sistema? Porque el sistema puede cambiar o repetir IDs,
-- y porque necesitamos filas especiales como "Cliente no registrado" (-1).

-- 4.1 DimCliente: el distrito ya vendrá limpio.
CREATE TABLE dw.DimCliente (
    ClienteKey  INT IDENTITY(1,1),   -- clave sustituta
    ClienteID   INT,                 -- clave natural (viene de ops.Clientes)
    Nombre      VARCHAR(60),
    Distrito    VARCHAR(40),
    TieneEmail  VARCHAR(2)           -- 'Sí' / 'No'
)

-- 4.2 DimProducto: la categoría se copia aquí como TEXTO (desnormalizar).
--     Así no hace falta un JOIN extra a Categorías. Eso es lo que la hace "estrella" y no "copo de nieve".
CREATE TABLE dw.DimProducto (
    ProductoKey  INT IDENTITY(1,1),
    ProductoID   INT,
    Producto     VARCHAR(60),
    Marca        VARCHAR(30),
    Categoria    VARCHAR(30),
    PrecioLista  DECIMAL(10,2)
)

-- 4.3 DimTienda.
CREATE TABLE dw.DimTienda (
    TiendaKey  INT IDENTITY(1,1),
    TiendaID   INT,
    Tienda     VARCHAR(40),
    Tipo       VARCHAR(20),
    Distrito   VARCHAR(40)
)

-- 4.4 DimVendedor: guardamos también el nombre de su tienda.
CREATE TABLE dw.DimVendedor (
    VendedorKey  INT IDENTITY(1,1),
    VendedorID   INT,
    Vendedor     VARCHAR(60),
    Tienda       VARCHAR(40)
)

-- 4.5 DimFecha: una fila por DÍA del año. No sale del sistema: la fabricamos nosotros.
--     Su clave es un número con forma de fecha: 20260214 = 14 de febrero de 2026.
CREATE TABLE dw.DimFecha (
    FechaKey      INT NOT NULL,  -- AAAAMMDD (la PK no acepta vacíos)
    Fecha         DATE,
    Anio          INT,
    Trimestre     INT,
    Mes           INT,
    NombreMes     VARCHAR(12),
    Dia           INT,
    NombreDia     VARCHAR(12),
    EsFinDeSemana VARCHAR(2)     -- 'Sí' / 'No'
)

/*
PREGUNTAS PARA LOS ALUMNOS (sección 4)
  P4.1 ¿Cuál es la diferencia entre ClienteKey y ClienteID en dw.DimCliente?
  P4.2 ¿Por qué DimProducto guarda "Categoria" como texto en vez de CategoriaID?
  P4.3 El sistema guarda MedioPago (Tarjeta, Yape, Plin, Efectivo). Escribe el CREATE TABLE de una dw.DimMedioPago.
       Pista: copia la forma de dw.DimTienda.
*/
GO


/*|=================> 5. PASO 4: LA TABLA DE HECHOS <=================|*/
-- La tabla de HECHOS es el centro de la estrella. Cada fila es un evento (aquí: un producto vendido en una boleta).
-- Tiene dos tipos de columnas:
--   - CLAVES de las dimensiones (FechaKey, ClienteKey, ...): solo números, apuntan a cada dimensión.
--   - MEDIDAS: los números que se suman (cantidad, monto, costo, ganancia).
-- NumeroBoleta se queda aquí aunque no sea medida: es una "dimensión degenerada"
-- (un dato de la boleta que no necesita su propia tabla).

-- 5.1 Creamos dw.FactVentas.
CREATE TABLE dw.FactVentas (
    VentaLineaKey   INT IDENTITY(1,1),
    FechaKey        INT NOT NULL,    -- NOT NULL: toda venta DEBE tener fecha, cliente, producto...
    ClienteKey      INT NOT NULL,
    ProductoKey     INT NOT NULL,
    TiendaKey       INT NOT NULL,
    VendedorKey     INT NOT NULL,
    NumeroBoleta    VARCHAR(15),     -- dimensión degenerada
    Cantidad        INT,             -- medida
    PrecioUnitario  DECIMAL(10,2),   -- medida (no se suma, se promedia)
    Descuento       DECIMAL(10,2),   -- medida
    MontoBruto      DECIMAL(12,2),   -- Cantidad * PrecioUnitario
    MontoNeto       DECIMAL(12,2),   -- MontoBruto - Descuento
    CostoTotal      DECIMAL(12,2),   -- Cantidad * Costo del producto
    Ganancia        DECIMAL(12,2)    -- MontoNeto - CostoTotal
)

/*
PREGUNTAS PARA LOS ALUMNOS (sección 5)
  P5.1 Nombra 3 medidas de dw.FactVentas que SÍ se pueden sumar y 1 que NO conviene sumar.
  P5.2 ¿Por qué NumeroBoleta está en la tabla de hechos y no en una dimensión?
  P5.3 Si agregas dw.DimMedioPago (P4.3), ¿qué columna nueva necesita dw.FactVentas?
*/
GO


/*|=================> 6. PASO 5: CLAVES Y RELACIONES (PK Y FK) <=================|*/
-- PK (llave primaria): cada dimensión tiene su clave sustituta como PK.
-- FK (llave foránea): cada clave de la tabla de hechos apunta a la PK de su dimensión.
-- Relación: 1 dimensión -> muchas filas de hechos (uno a muchos, 1:N).
-- Las FK impiden guardar una venta que apunte a un producto que no existe.
-- Las agregamos con ALTER TABLE para ver cada paso por separado.

-- 6.1 Llaves primarias de las dimensiones y de los hechos.
ALTER TABLE dw.DimCliente  ADD CONSTRAINT PK_DimCliente  PRIMARY KEY (ClienteKey)
ALTER TABLE dw.DimProducto ADD CONSTRAINT PK_DimProducto PRIMARY KEY (ProductoKey)
ALTER TABLE dw.DimTienda   ADD CONSTRAINT PK_DimTienda   PRIMARY KEY (TiendaKey)
ALTER TABLE dw.DimVendedor ADD CONSTRAINT PK_DimVendedor PRIMARY KEY (VendedorKey)
ALTER TABLE dw.DimFecha    ADD CONSTRAINT PK_DimFecha    PRIMARY KEY (FechaKey)
ALTER TABLE dw.FactVentas  ADD CONSTRAINT PK_FactVentas  PRIMARY KEY (VentaLineaKey)

-- 6.2 Llaves foráneas: los 5 "brazos" de la estrella.
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_Fecha    FOREIGN KEY (FechaKey)    REFERENCES dw.DimFecha(FechaKey)
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_Cliente  FOREIGN KEY (ClienteKey)  REFERENCES dw.DimCliente(ClienteKey)
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_Producto FOREIGN KEY (ProductoKey) REFERENCES dw.DimProducto(ProductoKey)
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_Tienda   FOREIGN KEY (TiendaKey)   REFERENCES dw.DimTienda(TiendaKey)
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_Vendedor FOREIGN KEY (VendedorKey) REFERENCES dw.DimVendedor(VendedorKey)

-- 6.3 La clave natural tampoco debe repetirse dentro de una dimensión (un cliente = una fila).
ALTER TABLE dw.DimCliente  ADD CONSTRAINT UQ_DimCliente_ID  UNIQUE (ClienteID)
ALTER TABLE dw.DimProducto ADD CONSTRAINT UQ_DimProducto_ID UNIQUE (ProductoID)

-- 6.4 Revisemos las relaciones creadas: tabla hija, columna y tabla padre.
SELECT  fk.name                                 AS Relacion,
        OBJECT_NAME(fk.parent_object_id)        AS Tabla_Hechos,
        COL_NAME(fc.parent_object_id, fc.parent_column_id) AS Columna,
        OBJECT_NAME(fk.referenced_object_id)    AS Dimension
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = fk.object_id
WHERE SCHEMA_NAME(fk.schema_id) = 'dw'
ORDER BY Dimension

/*
VER EL DIAGRAMA EN SSMS
  1. En el Explorador de objetos: Bases de datos > ZapaUrban (clic derecho > Actualizar).
  2. Clic derecho en "Diagramas de base de datos" > "Nuevo diagrama de base de datos".
     (Si pregunta por crear los objetos de soporte, di que Sí.)
  3. Elige las 6 tablas del esquema dw y pulsa Agregar.
  4. Arrastra FactVentas al centro: ¡ahí está la estrella!
  Si sale un error de "propietario", ejecuta esto una vez y vuelve a intentar:
     ALTER AUTHORIZATION ON DATABASE::ZapaUrban TO sa
*/

/*
PREGUNTAS PARA LOS ALUMNOS (sección 6)
  P6.1 ¿Qué tipo de relación hay entre dw.DimTienda y dw.FactVentas? ¿Qué lado es el "1" y cuál el "muchos"?
  P6.2 Escribe el ALTER TABLE que agrega la FK de FactVentas hacia dw.DimMedioPago (de P4.3 y P5.3).
  P6.3 Después de cargar los datos (sección 8), intenta insertar en dw.FactVentas una fila con ProductoKey = 999.
       ¿Qué pasa y por qué?
*/
GO


/*|=================> 7. PASO 6: CARGAR LAS DIMENSIONES <=================|*/
-- Las dimensiones se cargan PRIMERO (los hechos necesitan sus claves).
-- Usamos INSERT INTO ... SELECT: copia desde ops y limpia en el mismo paso.

-- 7.1 Fila especial -1 "Cliente no registrado" para las ventas sin cliente (boleta 13).
--     IDENTITY_INSERT permite escribir nosotros el número de la clave sustituta.
SET IDENTITY_INSERT dw.DimCliente ON
INSERT INTO dw.DimCliente (ClienteKey, ClienteID, Nombre, Distrito, TieneEmail)
VALUES (-1, NULL, 'Cliente no registrado', 'SIN DISTRITO', 'No')
SET IDENTITY_INSERT dw.DimCliente OFF

-- 7.2 Clientes: TRIM quita espacios, UPPER deja todo en mayúsculas, ISNULL rellena vacíos.
INSERT INTO dw.DimCliente (ClienteID, Nombre, Distrito, TieneEmail)
SELECT  ClienteID,
        Nombre,
        ISNULL(UPPER(TRIM(Distrito)), 'SIN DISTRITO'),
        CASE WHEN Email IS NULL THEN 'No' ELSE 'Sí' END
FROM ops.Clientes
ORDER BY ClienteID

SELECT * FROM dw.DimCliente   -- "Miraflores" y " miraflores" ahora dicen lo mismo

-- 7.3 Productos: unimos con Categorías UNA vez, aquí, para que el análisis ya no lo necesite.
INSERT INTO dw.DimProducto (ProductoID, Producto, Marca, Categoria, PrecioLista)
SELECT  p.ProductoID, p.Nombre, p.Marca, c.Nombre, p.PrecioLista
FROM ops.Productos p
JOIN ops.Categorias c ON c.CategoriaID = p.CategoriaID
ORDER BY p.ProductoID

SELECT * FROM dw.DimProducto

-- 7.4 Tiendas.
INSERT INTO dw.DimTienda (TiendaID, Tienda, Tipo, Distrito)
SELECT TiendaID, Nombre, Tipo, UPPER(Distrito)
FROM ops.Tiendas
ORDER BY TiendaID

-- 7.5 Vendedores, con la fila -1 para las ventas web.
SET IDENTITY_INSERT dw.DimVendedor ON
INSERT INTO dw.DimVendedor (VendedorKey, VendedorID, Vendedor, Tienda)
VALUES (-1, NULL, 'Sin vendedor (web)', 'Tienda Web')
SET IDENTITY_INSERT dw.DimVendedor OFF

INSERT INTO dw.DimVendedor (VendedorID, Vendedor, Tienda)
SELECT v.VendedorID, v.Nombre, t.Nombre
FROM ops.Vendedores v
JOIN ops.Tiendas t ON t.TiendaID = v.TiendaID
ORDER BY v.VendedorID

-- 7.6 DimFecha: generamos los 365 días de 2026 con una CTE recursiva (se llama a sí misma, sumando un día).
--     1900-01-01 fue lunes; por eso (días desde esa fecha % 7) da 0 = lunes ... 6 = domingo.
;WITH Dias AS (
    SELECT CAST('2026-01-01' AS DATE) AS Fecha
    UNION ALL
    SELECT DATEADD(DAY, 1, Fecha) FROM Dias WHERE Fecha < '2026-12-31'
)
INSERT INTO dw.DimFecha
SELECT  YEAR(Fecha) * 10000 + MONTH(Fecha) * 100 + DAY(Fecha),     -- 20260214
        Fecha,
        YEAR(Fecha),
        DATEPART(QUARTER, Fecha),
        MONTH(Fecha),
        CHOOSE(MONTH(Fecha), 'Enero','Febrero','Marzo','Abril','Mayo','Junio',
                             'Julio','Agosto','Setiembre','Octubre','Noviembre','Diciembre'),
        DAY(Fecha),
        CHOOSE(DATEDIFF(DAY, '19000101', Fecha) % 7 + 1,
               'Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'),
        CASE WHEN DATEDIFF(DAY, '19000101', Fecha) % 7 >= 5 THEN 'Sí' ELSE 'No' END
FROM Dias
OPTION (MAXRECURSION 400)

SELECT TOP 10 * FROM dw.DimFecha

-- 7.7 ¿Cuántas filas tiene cada dimensión?
SELECT 'DimCliente'  AS tabla, COUNT(*) AS filas FROM dw.DimCliente  UNION ALL
SELECT 'DimProducto',          COUNT(*)          FROM dw.DimProducto UNION ALL
SELECT 'DimTienda',            COUNT(*)          FROM dw.DimTienda   UNION ALL
SELECT 'DimVendedor',          COUNT(*)          FROM dw.DimVendedor UNION ALL
SELECT 'DimFecha',             COUNT(*)          FROM dw.DimFecha

/*
PREGUNTAS PARA LOS ALUMNOS (sección 7)
  P7.1 ¿Cuántos clientes hay por distrito en dw.DimCliente? Compáralo con ops.Clientes.
       Pista: GROUP BY Distrito en las dos tablas.
  P7.2 ¿Qué días de marzo de 2026 son fin de semana?
       Pista: dw.DimFecha con WHERE Mes = 3.
  P7.3 Escribe el INSERT ... SELECT que carga tu dw.DimMedioPago desde ops.Ventas.
       Pista: SELECT DISTINCT MedioPago.
*/
GO


/*|=================> 8. PASO 7: CARGAR LA TABLA DE HECHOS Y VALIDAR <=================|*/
-- Ahora sí: cada línea de venta se convierte en una fila de hechos.
-- El truco: buscamos cada clave NATURAL del sistema en su dimensión y guardamos la clave SUSTITUTA.
-- LEFT JOIN + ISNULL(..., -1): si la venta no tiene cliente o vendedor, va a la fila -1.
-- SELECT DISTINCT en el detalle: así el duplicado de la venta 7 no entra.

-- 8.1 Carga de dw.FactVentas.
INSERT INTO dw.FactVentas (FechaKey, ClienteKey, ProductoKey, TiendaKey, VendedorKey, NumeroBoleta,
                           Cantidad, PrecioUnitario, Descuento, MontoBruto, MontoNeto, CostoTotal, Ganancia)
SELECT  f.FechaKey,
        ISNULL(dc.ClienteKey, -1),
        dp.ProductoKey,
        dt.TiendaKey,
        ISNULL(dv.VendedorKey, -1),
        v.NumeroBoleta,
        d.Cantidad,
        d.PrecioUnitario,
        d.Descuento,
        d.Cantidad * d.PrecioUnitario,
        d.Cantidad * d.PrecioUnitario - d.Descuento,
        d.Cantidad * p.Costo,
        d.Cantidad * d.PrecioUnitario - d.Descuento - d.Cantidad * p.Costo
FROM (SELECT DISTINCT * FROM ops.DetalleVenta) d           -- sin duplicados
JOIN ops.Ventas      v  ON v.VentaID     = d.VentaID
JOIN ops.Productos   p  ON p.ProductoID  = d.ProductoID    -- para traer el costo
JOIN dw.DimFecha     f  ON f.Fecha       = CAST(v.FechaHora AS DATE)
JOIN dw.DimProducto  dp ON dp.ProductoID = d.ProductoID
JOIN dw.DimTienda    dt ON dt.TiendaID   = v.TiendaID
LEFT JOIN dw.DimCliente  dc ON dc.ClienteID  = v.ClienteID
LEFT JOIN dw.DimVendedor dv ON dv.VendedorID = v.VendedorID
ORDER BY d.VentaID, d.Linea

SELECT * FROM dw.FactVentas

-- 8.2 VALIDAR (siempre): ¿las filas y el total cuadran con el sistema sin duplicados?
SELECT 'Sistema (sin duplicados)' AS origen, COUNT(*) AS filas, SUM(Cantidad * PrecioUnitario - Descuento) AS monto
FROM (SELECT DISTINCT * FROM ops.DetalleVenta) d
UNION ALL
SELECT 'Modelo estrella', COUNT(*), SUM(MontoNeto)
FROM dw.FactVentas

-- 8.3 ¿Entraron todas las boletas? Deben ser 14 en los dos lados.
SELECT (SELECT COUNT(*) FROM ops.Ventas)                       AS boletas_sistema,
       (SELECT COUNT(DISTINCT NumeroBoleta) FROM dw.FactVentas) AS boletas_modelo

-- 8.4 La FK nos protege: esta venta apunta a un producto que no existe. Quita los -- para probar.
-- INSERT INTO dw.FactVentas (FechaKey, ClienteKey, ProductoKey, TiendaKey, VendedorKey, NumeroBoleta, Cantidad)
-- VALUES (20260301, 1, 999, 1, 1, 'B001-9999', 1)
-- Error: "The INSERT statement conflicted with the FOREIGN KEY constraint FK_Fact_Producto"

/*
PREGUNTAS PARA LOS ALUMNOS (sección 8)
  P8.1 ¿Cuántas filas de dw.FactVentas tienen ClienteKey = -1 y cuántas VendedorKey = -1?
  P8.2 ¿Cuál es la diferencia de monto entre el reporte 2.1 (con el duplicado) y el modelo estrella?
       Pista: SUM del detalle completo menos SUM(MontoNeto).
  P8.3 Agrega la columna MedioPagoKey a dw.FactVentas y llénala.
       Pista: ALTER TABLE ... ADD, y luego UPDATE con JOIN a ops.Ventas por NumeroBoleta.
*/
GO


/*|=================> 9. PASO 8: CONSULTAS DE ANÁLISIS SOBRE LA ESTRELLA <=================|*/
-- La forma de TODA consulta en estrella: FROM hechos + JOIN a las dimensiones que necesites + GROUP BY.
-- Cada JOIN es directo (hechos -> dimensión). Nunca hay que "encadenar" tablas.

-- 9.1 La misma pregunta del 2.1, ahora con la estrella (y sin el duplicado).
SELECT  f.NombreMes, t.Tienda, p.Categoria, SUM(h.MontoNeto) AS Monto
FROM dw.FactVentas h
JOIN dw.DimFecha    f ON f.FechaKey    = h.FechaKey
JOIN dw.DimTienda   t ON t.TiendaKey   = h.TiendaKey
JOIN dw.DimProducto p ON p.ProductoKey = h.ProductoKey
GROUP BY f.Mes, f.NombreMes, t.Tienda, p.Categoria
ORDER BY f.Mes, t.Tienda

-- 9.2 Ventas y ganancia por mes.
SELECT  f.Mes, f.NombreMes,
        SUM(h.MontoNeto) AS Ventas,
        SUM(h.Ganancia)  AS Ganancia,
        CAST(SUM(h.Ganancia) * 100.0 / SUM(h.MontoNeto) AS DECIMAL(5,1)) AS Margen_pct
FROM dw.FactVentas h
JOIN dw.DimFecha f ON f.FechaKey = h.FechaKey
GROUP BY f.Mes, f.NombreMes
ORDER BY f.Mes

-- 9.3 ¿Qué canal vende más: tiendas físicas u online? Con % del total.
SELECT  t.Tipo,
        SUM(h.MontoNeto) AS Ventas,
        CAST(SUM(h.MontoNeto) * 100.0 / (SELECT SUM(MontoNeto) FROM dw.FactVentas) AS DECIMAL(5,1)) AS Pct_del_total
FROM dw.FactVentas h
JOIN dw.DimTienda t ON t.TiendaKey = h.TiendaKey
GROUP BY t.Tipo

-- 9.4 Unidades y ganancia por categoría y marca.
SELECT  p.Categoria, p.Marca, SUM(h.Cantidad) AS Unidades, SUM(h.Ganancia) AS Ganancia
FROM dw.FactVentas h
JOIN dw.DimProducto p ON p.ProductoKey = h.ProductoKey
GROUP BY p.Categoria, p.Marca
ORDER BY Ganancia DESC

-- 9.5 Top 3 clientes por monto, con su ticket promedio (monto / número de boletas).
SELECT TOP 3
        c.Nombre, c.Distrito,
        COUNT(DISTINCT h.NumeroBoleta)  AS Boletas,
        SUM(h.MontoNeto)                AS Monto,
        CAST(SUM(h.MontoNeto) / COUNT(DISTINCT h.NumeroBoleta) AS DECIMAL(10,2)) AS Ticket_promedio
FROM dw.FactVentas h
JOIN dw.DimCliente c ON c.ClienteKey = h.ClienteKey
WHERE c.ClienteKey <> -1
GROUP BY c.Nombre, c.Distrito
ORDER BY Monto DESC

-- 9.6 Ranking de vendedores (solo tiendas físicas).
SELECT  v.Vendedor, v.Tienda, SUM(h.MontoNeto) AS Ventas, SUM(h.Descuento) AS Descuentos_dados
FROM dw.FactVentas h
JOIN dw.DimVendedor v ON v.VendedorKey = h.VendedorKey
WHERE v.VendedorKey <> -1
GROUP BY v.Vendedor, v.Tienda
ORDER BY Ventas DESC

-- 9.7 Fin de semana vs. días de semana.
SELECT  f.EsFinDeSemana, COUNT(DISTINCT h.NumeroBoleta) AS Boletas, SUM(h.MontoNeto) AS Ventas
FROM dw.FactVentas h
JOIN dw.DimFecha f ON f.FechaKey = h.FechaKey
GROUP BY f.EsFinDeSemana

-- 9.8 Una VISTA que junta la estrella en una sola tabla "ancha": lista para Excel o Power BI.
GO
CREATE OR ALTER VIEW dw.vw_Ventas AS
SELECT  f.Fecha, f.Anio, f.Mes, f.NombreMes, f.NombreDia, f.EsFinDeSemana,
        c.Nombre AS Cliente, c.Distrito AS DistritoCliente,
        p.Producto, p.Marca, p.Categoria,
        t.Tienda, t.Tipo AS Canal,
        v.Vendedor,
        h.NumeroBoleta, h.Cantidad, h.MontoBruto, h.Descuento, h.MontoNeto, h.CostoTotal, h.Ganancia
FROM dw.FactVentas h
JOIN dw.DimFecha    f ON f.FechaKey    = h.FechaKey
JOIN dw.DimCliente  c ON c.ClienteKey  = h.ClienteKey
JOIN dw.DimProducto p ON p.ProductoKey = h.ProductoKey
JOIN dw.DimTienda   t ON t.TiendaKey   = h.TiendaKey
JOIN dw.DimVendedor v ON v.VendedorKey = h.VendedorKey
GO

SELECT * FROM dw.vw_Ventas

/*
PREGUNTAS PARA LOS ALUMNOS (sección 9)
  P9.1 ¿Qué día de la semana se vende más (en soles)?
       Pista: igual que 9.7, pero con NombreDia.
  P9.2 ¿Cuánto vendió cada tienda en febrero y cuál fue su margen %?
       Pista: mezcla 9.2 y 9.3 con WHERE f.Mes = 2.
  P9.3 ¿Qué medio de pago trae más ventas? (usa tu dw.DimMedioPago)
*/
GO


/*|=================> 10. TAREA: TU PROPIO MODELO ESTRELLA <=================|*/
/*
Para la parte "Diseño del modelo dimensional" del proyecto final, entreguen esto:

  1. Pregunta del negocio:  "¿Cuánto ... por ..., por ... y por ...?"
  2. Grano:                 "1 fila de la tabla de hechos = ..."
  3. Tabla de hechos:       nombre, medidas (y si se suman o no), dimensiones degeneradas.
  4. Dimensiones:           nombre, clave sustituta, clave natural y atributos.
  5. Claves y relaciones:   PK de cada tabla, FK de los hechos hacia cada dimensión (1:N).
  6. Script:                CREATE TABLE + ALTER TABLE (PK/FK) + INSERT ... SELECT.
  7. Diagrama:              captura del diagrama de SSMS.
  8. Validación:            filas y totales del origen = filas y totales de la tabla de hechos.

Ejemplo de cómo se ve el punto 3 y 4 para ZapaUrban:

  TABLA          TIPO        PK              FK hacia                     GRANO / CONTENIDO
  FactVentas     Hechos      VentaLineaKey   las 5 dimensiones            1 producto en 1 boleta
  DimFecha       Dimensión   FechaKey        -                            1 día
  DimCliente     Dimensión   ClienteKey      -                            1 cliente (+ fila -1)
  DimProducto    Dimensión   ProductoKey     -                            1 producto
  DimTienda      Dimensión   TiendaKey       -                            1 tienda
  DimVendedor    Dimensión   VendedorKey     -                            1 vendedor (+ fila -1)

PRÁCTICA PARA CASA: un delivery de comida ("PideYa") tiene estas tablas en su sistema:
  Pedidos(PedidoID, FechaHora, ClienteID, RestauranteID, RepartidorID, CostoEnvio)
  DetallePedido(PedidoID, PlatoID, Cantidad, Precio)
  Clientes(ClienteID, Nombre, Distrito)
  Restaurantes(RestauranteID, Nombre, TipoComida)
  Platos(PlatoID, Nombre, RestauranteID)
  Repartidores(RepartidorID, Nombre, Vehiculo)

  T1. Escribe el grano.
  T2. Lista la tabla de hechos con sus medidas y las dimensiones con sus atributos.
  T3. Escribe los CREATE TABLE del modelo estrella con sus PK y FK.
       Pista: CostoEnvio es del pedido, no del plato. Piensa en qué grano lo pones.
*/
