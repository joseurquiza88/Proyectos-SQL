------------------------------------------------------------
--   SESIÓN 3: MODELO ESTRELLA PASO A PASO · SOLUCIONARIO   --
--      Blur Consulting · Grupo de Estudio Data Analyst    --
------------------------------------------------------------

/*
SOLO PARA EL PROFESOR.
Antes de usarlo, ejecuta completo "Sesion3_Modelo_Estrella_Paso_a_Paso.sql" (crea la base ZapaUrban).
Ejecuta este archivo en orden: las respuestas de DimMedioPago (P4.3, P5.3, P6.2, P7.3, P8.3)
se apoyan una en la otra.
*/

USE ZapaUrban
GO


/*|=================> 1. LAS TABLAS DEL SISTEMA <=================|*/

-- P1.1 20 filas en el detalle; sin el duplicado son 19.
SELECT COUNT(*) AS filas FROM ops.DetalleVenta
SELECT COUNT(*) AS filas_sin_duplicado FROM (SELECT DISTINCT * FROM ops.DetalleVenta) x

-- P1.2 "Miraflores" aparece de 2 formas ('Miraflores' y ' miraflores') y "Surco" de 2 ('SURCO' y '  surco').
SELECT DISTINCT Distrito FROM ops.Clientes

-- P1.3 La Mochila Classic nunca se vendió.
SELECT p.ProductoID, p.Nombre
FROM ops.Productos p
LEFT JOIN ops.DetalleVenta d ON d.ProductoID = p.ProductoID
WHERE d.ProductoID IS NULL
GO


/*|=================> 2. LA PREGUNTA DEL NEGOCIO <=================|*/
/*
P2.1 Medida: unidades (SUM de Cantidad). Dimensiones: marca (producto) y mes (fecha).
P2.2 Porque la línea 2 de la venta 7 (Medias, S/ 59) está dos veces: 2.1 da S/ 118 en Accesorios
     de febrero en Mega Plaza, cuando lo real es S/ 59.
P2.3 Respuesta libre. Ejemplo: "¿Cuántos soles vende cada tienda por mes?"
     Medida: soles vendidos. Dimensiones: tienda y mes.
*/


/*|=================> 3. EL GRANO <=================|*/
/*
P3.1 No. La boleta mezcla varios productos de distintas categorías; con 1 fila por boleta
     ya no sabes qué producto (ni qué categoría) se llevó.
P3.3 Respuesta libre. Ejemplo: "1 fila = 1 producto vendido en 1 boleta".
*/
-- P3.2 14 filas (una por boleta).
SELECT COUNT(*) AS boletas FROM ops.Ventas
GO


/*|=================> 4. LAS DIMENSIONES <=================|*/
/*
P4.1 ClienteKey es la clave sustituta: la crea el DW (1, 2, 3... y -1). ClienteID es la clave natural:
     el número que traía el sistema de ventas. Los hechos se unen por ClienteKey.
P4.2 Para no tener que hacer otro JOIN a una tabla Categorías. El texto se lee directo y el modelo
     queda en estrella (no en copo de nieve).
*/
-- P4.3
CREATE TABLE dw.DimMedioPago (
    MedioPagoKey  INT IDENTITY(1,1) PRIMARY KEY,
    MedioPago     VARCHAR(20),
    EsDigital     VARCHAR(2)       -- 'Sí' para Yape, Plin y Tarjeta (atributo extra opcional)
)
GO


/*|=================> 5. LA TABLA DE HECHOS <=================|*/
/*
P5.1 Se suman: Cantidad, MontoBruto, MontoNeto, Descuento, CostoTotal, Ganancia.
     No conviene sumar: PrecioUnitario (sumar precios no significa nada; se promedia).
P5.2 Es un dato de la boleta que no tiene más atributos: una tabla DimBoleta tendría una sola columna.
     Se queda en los hechos como "dimensión degenerada" y sirve para contar boletas (COUNT DISTINCT).
*/
-- P5.3 Una columna MedioPagoKey.
ALTER TABLE dw.FactVentas ADD MedioPagoKey INT NULL
GO


/*|=================> 6. CLAVES Y RELACIONES <=================|*/
/*
P6.1 Uno a muchos (1:N). DimTienda es el lado "1" (cada tienda aparece una vez);
     FactVentas es el lado "muchos" (la misma tienda aparece en muchas ventas).
P6.3 Da error de FOREIGN KEY (FK_Fact_Producto): no existe ProductoKey 999 en dw.DimProducto.
     La FK no deja guardar ventas "huérfanas". Para probarlo, quita los --:
*/
-- INSERT INTO dw.FactVentas (FechaKey, ClienteKey, ProductoKey, TiendaKey, VendedorKey, NumeroBoleta, Cantidad)
-- VALUES (20260301, 1, 999, 1, 1, 'B001-9999', 1)

-- P6.2
ALTER TABLE dw.FactVentas ADD CONSTRAINT FK_Fact_MedioPago FOREIGN KEY (MedioPagoKey) REFERENCES dw.DimMedioPago(MedioPagoKey)
GO


/*|=================> 7. CARGAR LAS DIMENSIONES <=================|*/

-- P7.1 En ops salen 8 grupos (contando el NULL); en DimCliente quedan 6 (contando 'SIN DISTRITO').
SELECT Distrito, COUNT(*) AS clientes FROM ops.Clientes GROUP BY Distrito
SELECT Distrito, COUNT(*) AS clientes FROM dw.DimCliente WHERE ClienteKey <> -1 GROUP BY Distrito

-- P7.2 Sábados y domingos de marzo de 2026: 1, 7, 8, 14, 15, 21, 22, 28 y 29.
SELECT Fecha, NombreDia FROM dw.DimFecha WHERE Mes = 3 AND EsFinDeSemana = 'Sí'

-- P7.3
INSERT INTO dw.DimMedioPago (MedioPago, EsDigital)
SELECT DISTINCT MedioPago, CASE WHEN MedioPago = 'Efectivo' THEN 'No' ELSE 'Sí' END
FROM ops.Ventas

SELECT * FROM dw.DimMedioPago
GO


/*|=================> 8. CARGAR LOS HECHOS <=================|*/

-- P8.1 1 fila con ClienteKey = -1 (boleta 13) y 6 filas con VendedorKey = -1 (las líneas de las ventas web).
SELECT SUM(CASE WHEN ClienteKey  = -1 THEN 1 ELSE 0 END) AS sin_cliente,
       SUM(CASE WHEN VendedorKey = -1 THEN 1 ELSE 0 END) AS sin_vendedor
FROM dw.FactVentas

-- P8.2 S/ 59 de diferencia (7,724 con el duplicado vs. 7,665 en la estrella).
SELECT (SELECT SUM(Cantidad * PrecioUnitario - Descuento) FROM ops.DetalleVenta)
     - (SELECT SUM(MontoNeto) FROM dw.FactVentas) AS diferencia

-- P8.3 (la columna se agregó en P5.3)
UPDATE h
SET    h.MedioPagoKey = mp.MedioPagoKey
FROM dw.FactVentas h
JOIN ops.Ventas      v  ON v.NumeroBoleta = h.NumeroBoleta
JOIN dw.DimMedioPago mp ON mp.MedioPago   = v.MedioPago

SELECT COUNT(*) AS filas_sin_medio_pago FROM dw.FactVentas WHERE MedioPagoKey IS NULL   -- debe dar 0
GO


/*|=================> 9. CONSULTAS DE ANÁLISIS <=================|*/

-- P9.1 El sábado: S/ 3,639.
SELECT f.NombreDia, SUM(h.MontoNeto) AS Ventas
FROM dw.FactVentas h
JOIN dw.DimFecha f ON f.FechaKey = h.FechaKey
GROUP BY f.NombreDia
ORDER BY Ventas DESC

-- P9.2 Febrero: Jockey Plaza S/ 1,178 (40.6 %), Tienda Web S/ 1,096 (50.7 %), Mega Plaza S/ 558 (48.0 %).
SELECT t.Tienda,
       SUM(h.MontoNeto) AS Ventas,
       CAST(SUM(h.Ganancia) * 100.0 / SUM(h.MontoNeto) AS DECIMAL(5,1)) AS Margen_pct
FROM dw.FactVentas h
JOIN dw.DimFecha  f ON f.FechaKey  = h.FechaKey
JOIN dw.DimTienda t ON t.TiendaKey = h.TiendaKey
WHERE f.Mes = 2
GROUP BY t.Tienda
ORDER BY Ventas DESC

-- P9.3 Tarjeta: S/ 2,959 en 5 boletas.
SELECT mp.MedioPago, COUNT(DISTINCT h.NumeroBoleta) AS Boletas, SUM(h.MontoNeto) AS Ventas
FROM dw.FactVentas h
JOIN dw.DimMedioPago mp ON mp.MedioPagoKey = h.MedioPagoKey
GROUP BY mp.MedioPago
ORDER BY Ventas DESC
GO


/*|=================> 10. TAREA: PIDEYA <=================|*/
/*
T1. Grano: 1 fila = 1 plato dentro de 1 pedido.

T2. FactPedidos (hechos): Cantidad, Precio, Monto (Cantidad * Precio), CostoEnvio; PedidoID como dimensión degenerada.
    DimFecha (fecha, mes, día, fin de semana, hora o franja: almuerzo/cena)
    DimCliente (nombre, distrito)
    DimRestaurante (nombre, tipo de comida)
    DimPlato (nombre del plato y, desnormalizado, nombre y tipo de comida de su restaurante)
    DimRepartidor (nombre, vehículo)

    CostoEnvio es del PEDIDO, no del plato. Si lo copias en cada plato, al sumar se multiplica.
    Dos salidas válidas: (a) ponerlo solo en la primera línea del pedido y 0 en las demás, o
    (b) crear una segunda tabla de hechos con grano "1 fila = 1 pedido" (FactEnvios).

T3. Una solución (la base de ejemplo no se crea; es solo el diseño):
*/
/*
CREATE TABLE dw.DimCliente     (ClienteKey INT IDENTITY PRIMARY KEY, ClienteID INT, Nombre VARCHAR(60), Distrito VARCHAR(40))
CREATE TABLE dw.DimRestaurante (RestauranteKey INT IDENTITY PRIMARY KEY, RestauranteID INT, Nombre VARCHAR(60), TipoComida VARCHAR(30))
CREATE TABLE dw.DimPlato       (PlatoKey INT IDENTITY PRIMARY KEY, PlatoID INT, Plato VARCHAR(60), Restaurante VARCHAR(60), TipoComida VARCHAR(30))
CREATE TABLE dw.DimRepartidor  (RepartidorKey INT IDENTITY PRIMARY KEY, RepartidorID INT, Nombre VARCHAR(60), Vehiculo VARCHAR(20))
CREATE TABLE dw.DimFecha       (FechaKey INT PRIMARY KEY, Fecha DATE, Anio INT, Mes INT, NombreMes VARCHAR(12), NombreDia VARCHAR(12), EsFinDeSemana VARCHAR(2))

CREATE TABLE dw.FactPedidos (
    PedidoLineaKey INT IDENTITY PRIMARY KEY,
    FechaKey       INT NOT NULL REFERENCES dw.DimFecha(FechaKey),
    ClienteKey     INT NOT NULL REFERENCES dw.DimCliente(ClienteKey),
    RestauranteKey INT NOT NULL REFERENCES dw.DimRestaurante(RestauranteKey),
    PlatoKey       INT NOT NULL REFERENCES dw.DimPlato(PlatoKey),
    RepartidorKey  INT NOT NULL REFERENCES dw.DimRepartidor(RepartidorKey),
    PedidoID       INT,             -- dimensión degenerada
    Cantidad       INT,
    Precio         DECIMAL(10,2),
    Monto          DECIMAL(12,2),
    CostoEnvio     DECIMAL(10,2)    -- solo en la primera línea del pedido
)
*/
