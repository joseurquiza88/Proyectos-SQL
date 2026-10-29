


-------------------------------------------------------------------------------------------------------------------------
--  03. Crear las tablas de hecho y dimesiones junto con el modelo estrella, ademas de poblar las tablas correspondientes
-------------------------------------------------------------------------------------------------------------------------
-- Conocer qué tenemos
USE BankTransactions;
GO



USE BankTransactions;
GO

-- 1. Dimensión fecha
CREATE TABLE dbo.DimFecha (
    ID_Date INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL UNIQUE
);
GO

-- 2. Dimensión cuenta
CREATE TABLE dbo.DimCuenta (
    ID_Account INT IDENTITY(1,1) PRIMARY KEY,
    AccountID VARCHAR(50) NOT NULL UNIQUE
);
GO



-- 3. Dimensión canal
CREATE TABLE dbo.DimCanal (
    ID_Channel INT IDENTITY(1,1) PRIMARY KEY,
    Channel VARCHAR(20) NOT NULL UNIQUE
);
GO

-- 4. Dimensión tipo de transacción
CREATE TABLE dbo.DimTipoTransaccion (
    ID_TransactionType INT IDENTITY(1,1) PRIMARY KEY,
    TransactionType VARCHAR(20) NOT NULL UNIQUE
);
GO

-- 5. Dimensión ubicación
CREATE TABLE dbo.DimUbicacion (
    ID_Location INT IDENTITY(1,1) PRIMARY KEY,
    Location VARCHAR(100) NOT NULL UNIQUE
);
GO


-- Cargar las dimensiones
USE BankTransactions;
GO

-- 1. Cargar DimFecha
INSERT INTO dbo.DimFecha (Fecha)
SELECT DISTINCT CAST(TransactionDate AS DATE)
FROM stg.BankTransactionsTyped;
GO





-- 2. Cargar DimCuenta

INSERT INTO dbo.DimCuenta (AccountID)
SELECT DISTINCT AccountID
FROM stg.BankTransactionsTyped;
GO



-- 3. Cargar DimCanal
INSERT INTO dbo.DimCanal (Channel)
SELECT DISTINCT Channel
FROM stg.BankTransactionsTyped;
GO

-- 4. Cargar DimTipoTransaccion
INSERT INTO dbo.DimTipoTransaccion (TransactionType)
SELECT DISTINCT TransactionType
FROM stg.BankTransactionsTyped;
GO

-- 5. Cargar DimUbicacion
INSERT INTO dbo.DimUbicacion (Location)
SELECT DISTINCT Location
FROM stg.BankTransactionsTyped;
GO


-- comprobar que las dimensiones se hayan cargado correctamente
SELECT * FROM dbo.DimFecha;
SELECT * FROM dbo.DimCanal;
SELECT * FROM dbo.DimTipoTransaccion;
SELECT * FROM dbo.DimUbicacion;
SELECT * FROM dbo.DimCuenta;


SELECT 'DimFecha' AS Tabla, COUNT(*) AS Cantidad FROM dbo.DimFecha
UNION ALL
SELECT 'DimCanal', COUNT(*) FROM dbo.DimCanal
UNION ALL
SELECT 'DimTipoTransaccion', COUNT(*) FROM dbo.DimTipoTransaccion
UNION ALL
SELECT 'DimUbicacion', COUNT(*) FROM dbo.DimUbicacion;




-- Crear tabla de hechos

CREATE TABLE dbo.FactTransaccion (
    TransactionID VARCHAR(50) PRIMARY KEY,
    ID_Date INT,
    ID_Account INT,
    ID_Channel INT,
    ID_TransactionType INT,
    ID_Location INT,
    TransactionAmount DECIMAL(18,2),
    AccountBalance DECIMAL(18,2),
    TransactionDuration INT,
    LoginAttempts INT,

    FOREIGN KEY (ID_Date) REFERENCES dbo.DimFecha(ID_Date),
    FOREIGN KEY (ID_Account) REFERENCES dbo.DimCuenta(ID_Account),
    FOREIGN KEY (ID_Channel) REFERENCES dbo.DimCanal(ID_Channel),
    FOREIGN KEY (ID_TransactionType) REFERENCES dbo.DimTipoTransaccion(ID_TransactionType),
    FOREIGN KEY (ID_Location) REFERENCES dbo.DimUbicacion(ID_Location)
);
GO


-- Poblar la tbla de hechos
INSERT INTO dbo.FactTransaccion (
    TransactionID,
    ID_Date,
    ID_Account,
    ID_Channel,
    ID_TransactionType,
    ID_Location,
    TransactionAmount,
    AccountBalance,
    TransactionDuration,
    LoginAttempts
)
SELECT
    t.TransactionID,
    f.ID_Date,
    a.ID_Account,
    c.ID_Channel,
    tt.ID_TransactionType,
    u.ID_Location,
    t.TransactionAmount,
    t.AccountBalance,
    t.TransactionDuration,
    t.LoginAttempts
FROM stg.BankTransactionsTyped AS t
INNER JOIN dbo.DimFecha AS f
    ON CAST(t.TransactionDate AS DATE) = f.Fecha
INNER JOIN dbo.DimCuenta AS a
    ON t.AccountID = a.AccountID
INNER JOIN dbo.DimCanal AS c
    ON t.Channel = c.Channel
INNER JOIN dbo.DimTipoTransaccion AS tt
    ON t.TransactionType = tt.TransactionType
INNER JOIN dbo.DimUbicacion AS u
    ON t.Location = u.Location;
GO

-- Algunas comprobaciones
SELECT COUNT(*) AS TotalTransacciones
FROM dbo.FactTransaccion;

SELECT TOP 10 *
FROM dbo.FactTransaccion;

-- Uno las tres tablas y corroboro datos
SELECT 'Original' AS Tabla, COUNT(*) AS CantidadFilas FROM stg.BankTransactionsRaw
UNION ALL
SELECT 'Tipos_cambiados', COUNT(*) FROM stg.BankTransactionsTyped
UNION ALL
SELECT 'Tabla_hehcos_final', COUNT(*) FROM dbo.FactTransaccion;

-- Comprobar que no haya transacciones duplicadas en la tabla de hechos
SELECT COUNT(*) AS TotalFilas, 
        COUNT(DISTINCT TransactionID) AS TransaccionesDistintas
FROM dbo.FactTransaccion;


-- Comprobar las relaciones con las dimensiones
-- La consulta cuenta las transacciones que tienen al menos una de las cinco claves vacía.
SELECT COUNT(*) AS TransaccionesSinClaves
FROM dbo.FactTransaccion
WHERE ID_Date IS NULL
   OR ID_Account IS NULL
   OR ID_Channel IS NULL
   OR ID_TransactionType IS NULL
   OR ID_Location IS NULL;

-- Comprobar que los importes coincidan con la fuente
SELECT
    'Typed' AS Tabla,
    SUM(TransactionAmount) AS ImporteTotal
FROM stg.BankTransactionsTyped

UNION ALL

SELECT
    'FactTransaccion',
    SUM(TransactionAmount)
FROM dbo.FactTransaccion;

-- Verificar que las claves estén conectadas correctamente
SELECT c.Channel, COUNT(*) AS CantidadTransacciones,
    SUM(f.TransactionAmount) AS ImporteTotal
FROM dbo.FactTransaccion AS f
INNER JOIN dbo.DimCanal AS c
    ON f.ID_Channel = c.ID_Channel
GROUP BY c.Channel
ORDER BY CantidadTransacciones DESC;




-- Comprobams el modelo estella
SELECT
    c.Channel,
    COUNT(*) AS CantidadTransacciones,
    SUM(f.TransactionAmount) AS ImporteTotal,
    AVG(f.TransactionAmount) AS ImportePromedio
FROM dbo.FactTransaccion AS f
INNER JOIN dbo.DimCanal AS c
    ON f.ID_Channel = c.ID_Channel
GROUP BY c.Channel
ORDER BY ImporteTotal DESC;