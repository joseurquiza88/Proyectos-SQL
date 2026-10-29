

-----------------------------------------------------------------
--  02. Exploración de la tabla
-----------------------------------------------------------------
-- Conocer qué tenemos
USE BankTransactions;
GO
-- Hay 2512 filas igual que el csv
SELECT COUNT(*) AS CantidadFilas
FROM stg.BankTransactionsRaw;

-- Vemos que tipo de datos son, pero ojo les habia puesto nvarchar
-- Ahora hay que setearlos bien a que tipo de datos son
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME = 'BankTransactionsRaw'
ORDER BY ORDINAL_POSITION;


-- Mirar una muestra de datos
SELECT TOP 10 *
FROM stg.BankTransactionsRaw;

-- Como son nvarchar, hay que hacer ciertas comprobaciones para checkear que sean realmente del tipo que pensamos
-- para todas las columnas

--  Revisar nulos y valores vacíos
-- No hay nulos 
SELECT
    COUNT(*) AS TotalFilas,
    SUM(CASE WHEN TransactionID IS NULL THEN 1 ELSE 0 END) AS TransactionID_Nulos,
    SUM(CASE WHEN AccountID IS NULL THEN 1 ELSE 0 END) AS AccountID_Nulos,
    SUM(CASE WHEN TransactionAmount IS NULL THEN 1 ELSE 0 END) AS TransactionAmount_Nulos,
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) AS TransactionDate_Nulos,
    SUM(CASE WHEN TransactionType IS NULL THEN 1 ELSE 0 END) AS TransactionType_Nulos,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Location_Nulos,
    SUM(CASE WHEN DeviceID IS NULL THEN 1 ELSE 0 END) AS DeviceID_Nulos,
    SUM(CASE WHEN IP_Address IS NULL THEN 1 ELSE 0 END) AS IP_Address_Nulos,
    SUM(CASE WHEN MerchantID IS NULL THEN 1 ELSE 0 END) AS MerchantID_Nulos,
    SUM(CASE WHEN Channel IS NULL THEN 1 ELSE 0 END) AS Channel_Nulos,
    SUM(CASE WHEN CustomerAge IS NULL THEN 1 ELSE 0 END) AS CustomerAge_Nulos,
    SUM(CASE WHEN CustomerOccupation IS NULL THEN 1 ELSE 0 END) AS CustomerOccupation_Nulos,
    SUM(CASE WHEN TransactionDuration IS NULL THEN 1 ELSE 0 END) AS TransactionDuration_Nulos,
    SUM(CASE WHEN LoginAttempts IS NULL THEN 1 ELSE 0 END) AS LoginAttempts_Nulos,
    SUM(CASE WHEN AccountBalance IS NULL THEN 1 ELSE 0 END) AS AccountBalance_Nulos,
    SUM(CASE WHEN PreviousTransactionDate IS NULL THEN 1 ELSE 0 END) AS PreviousTransactionDate_Nulos
FROM stg.BankTransactionsRaw;



-- Revisar duplicados: ver si hay TransactionID repetidos, porque se supone que es unico y es el unico indicador de 
-- TransactionID
-- No hay

SELECT
    TransactionID,
    COUNT(*) AS Cantidad
FROM stg.BankTransactionsRaw
GROUP BY TransactionID
HAVING COUNT(*) > 1;
GO

-- Con esto vemos si hay
SELECT DISTINCT *
INTO #TransaccionesUnicas
FROM stg.BankTransactionsRaw;

SELECT
    (SELECT COUNT(*) FROM stg.BankTransactionsRaw) AS FilasOriginales,
    (SELECT COUNT(*) FROM #TransaccionesUnicas) AS FilasDiferentes;

DROP TABLE #TransaccionesUnicas;
GO


-- Validar los tipos de datos, asi despues hago una tabla general con l
-- Numeros y fechas

SELECT
    SUM(CASE WHEN TRY_CONVERT(DECIMAL(18,2), TransactionAmount) IS NULL
        AND TransactionAmount IS NOT NULL THEN 1 ELSE 0 END) AS Importe_Invalidos,

    SUM(CASE WHEN TRY_CONVERT(DATETIME2, TransactionDate) IS NULL
        AND TransactionDate IS NOT NULL THEN 1 ELSE 0 END) AS Fecha_Invalidas,

    SUM(CASE WHEN TRY_CONVERT(INT, CustomerAge) IS NULL
        AND CustomerAge IS NOT NULL THEN 1 ELSE 0 END) AS Edad_Invalidas,

    SUM(CASE WHEN TRY_CONVERT(INT, TransactionDuration) IS NULL
        AND TransactionDuration IS NOT NULL THEN 1 ELSE 0 END) AS Duracion_Invalidas,

    SUM(CASE WHEN TRY_CONVERT(INT, LoginAttempts) IS NULL
        AND LoginAttempts IS NOT NULL THEN 1 ELSE 0 END) AS Intentos_Invalidos,

    SUM(CASE WHEN TRY_CONVERT(DECIMAL(18,2), AccountBalance) IS NULL
        AND AccountBalance IS NOT NULL THEN 1 ELSE 0 END) AS Saldo_Invalidos,

    SUM(CASE WHEN TRY_CONVERT(DATETIME2, PreviousTransactionDate) IS NULL
        AND PreviousTransactionDate IS NOT NULL THEN 1 ELSE 0 END) AS FechaAnterior_Invalidas
FROM stg.BankTransactionsRaw;
GO

-- Revisar también las categorías, los tipo de texto
SELECT DISTINCT TransactionType
FROM stg.BankTransactionsRaw;

SELECT DISTINCT Channel
FROM stg.BankTransactionsRaw;

SELECT DISTINCT CustomerOccupation
FROM stg.BankTransactionsRaw;
GO


-- Creo otra tabla con los datos cambiados a partir de la tabla ba
CREATE TABLE stg.BankTransactionsTyped (
    TransactionID VARCHAR(50),
    AccountID VARCHAR(50),
    TransactionAmount DECIMAL(18,2),
    TransactionDate DATETIME2,
    TransactionType VARCHAR(20),
    Location VARCHAR(100),
    DeviceID VARCHAR(50),
    IP_Address VARCHAR(50),
    MerchantID VARCHAR(50),
    Channel VARCHAR(20),
    CustomerAge INT,
    CustomerOccupation VARCHAR(100),
    TransactionDuration INT,
    LoginAttempts INT,
    AccountBalance DECIMAL(18,2),
    PreviousTransactionDate DATETIME2
);
GO

INSERT INTO stg.BankTransactionsTyped (
    TransactionID,
    AccountID,
    TransactionAmount,
    TransactionDate,
    TransactionType,
    Location,
    DeviceID,
    IP_Address,
    MerchantID,
    Channel,
    CustomerAge,
    CustomerOccupation,
    TransactionDuration,
    LoginAttempts,
    AccountBalance,
    PreviousTransactionDate
)
SELECT
    TransactionID,
    AccountID,
    TRY_CONVERT(DECIMAL(18,2), TransactionAmount),
    TRY_CONVERT(DATETIME2, TransactionDate),
    TransactionType,
    Location,
    DeviceID,
    IP_Address,
    MerchantID,
    Channel,
    TRY_CONVERT(INT, CustomerAge),
    CustomerOccupation,
    TRY_CONVERT(INT, TransactionDuration),
    TRY_CONVERT(INT, LoginAttempts),
    TRY_CONVERT(DECIMAL(18,2), AccountBalance),
    TRY_CONVERT(DATETIME2, PreviousTransactionDate)
FROM stg.BankTransactionsRaw;
GO

SELECT TOP 10 *
FROM stg.BankTransactionsTyped;

SELECT COUNT(*) AS TotalFilas
FROM stg.BankTransactionsTyped;
GO


-- Revisar inconsistencias de contenido y rangos razonables
-- Edades fuera de un rango razonable
SELECT *
FROM stg.BankTransactionsTyped
WHERE CustomerAge < 18 OR CustomerAge > 100;

-- Importes negativos
SELECT *
FROM stg.BankTransactionsTyped
WHERE TransactionAmount < 0;

-- Duraciones o intentos negativos
SELECT *
FROM stg.BankTransactionsTyped
WHERE TransactionDuration < 0
   OR LoginAttempts < 0;

-- Tipos de transacción no esperados
SELECT DISTINCT TransactionType
FROM stg.BankTransactionsTyped
WHERE TransactionType NOT IN ('Credit', 'Debit');

-- Canales no esperados
SELECT DISTINCT Channel
FROM stg.BankTransactionsTyped
WHERE Channel NOT IN ('Online', 'ATM', 'Branch');
GO


-- Compruebo que la nueva tabla este ok y que no tenga nulls
SELECT
    SUM(CASE WHEN TransactionAmount IS NULL THEN 1 ELSE 0 END) AS Importe_Nulos,
    SUM(CASE WHEN TransactionDate IS NULL THEN 1 ELSE 0 END) AS Fecha_Nulos,
    SUM(CASE WHEN CustomerAge IS NULL THEN 1 ELSE 0 END) AS Edad_Nulos,
    SUM(CASE WHEN TransactionDuration IS NULL THEN 1 ELSE 0 END) AS Duracion_Nulos,
    SUM(CASE WHEN LoginAttempts IS NULL THEN 1 ELSE 0 END) AS Intentos_Nulos,
    SUM(CASE WHEN AccountBalance IS NULL THEN 1 ELSE 0 END) AS Saldo_Nulos,
    SUM(CASE WHEN PreviousTransactionDate IS NULL THEN 1 ELSE 0 END) AS FechaAnterior_Nulos
FROM stg.BankTransactionsTyped;


-- Comprobar que no se perdieron ni se agregaron filas, hay 2512 en ambas tablas
SELECT
    'Originales' AS TipoTabla,
    COUNT(*) AS CantidadFilas
FROM stg.BankTransactionsRaw

UNION ALL

SELECT
    'Tipadas' AS TipoTabla,
    COUNT(*) AS CantidadFilas
FROM stg.BankTransactionsTyped;

-- Revisar el rango de fechas
SELECT
    MIN(TransactionDate) AS FechaDesde,
    MAX(TransactionDate) AS FechaHasta,
    MIN(PreviousTransactionDate) AS FechaAnteriorDesde,
    MAX(PreviousTransactionDate) AS FechaAnteriorHasta
FROM stg.BankTransactionsTyped;

-- Revisar filas completamente duplicadas sin crear una tabla temporal
SELECT
    TransactionID,
    AccountID,
    TransactionAmount,
    TransactionDate,
    TransactionType,
    Location,
    DeviceID,
    IP_Address,
    MerchantID,
    Channel,
    CustomerAge,
    CustomerOccupation,
    TransactionDuration,
    LoginAttempts,
    AccountBalance,
    PreviousTransactionDate,
    COUNT(*) AS Cantidad
FROM stg.BankTransactionsRaw
GROUP BY
    TransactionID,
    AccountID,
    TransactionAmount,
    TransactionDate,
    TransactionType,
    Location,
    DeviceID,
    IP_Address,
    MerchantID,
    Channel,
    CustomerAge,
    CustomerOccupation,
    TransactionDuration,
    LoginAttempts,
    AccountBalance,
    PreviousTransactionDate
HAVING COUNT(*) > 1;
GO


-- Revisamos rangos razonables en la nueva tabla
-- Edades fuera del rango elegido para la revisión
SELECT *
FROM stg.BankTransactionsTyped
WHERE CustomerAge < 18 OR CustomerAge > 100;

-- Importes negativos
SELECT *
FROM stg.BankTransactionsTyped
WHERE TransactionAmount < 0;

-- Duraciones o intentos negativos
SELECT *
FROM stg.BankTransactionsTyped
WHERE TransactionDuration < 0
   OR LoginAttempts < 0;

-- Tipos de transacción no contemplados
SELECT DISTINCT TransactionType
FROM stg.BankTransactionsTyped
WHERE TransactionType NOT IN ('Credit', 'Debit');

-- Canales no contemplados
SELECT DISTINCT Channel
FROM stg.BankTransactionsTyped
WHERE Channel NOT IN ('Online', 'ATM', 'Branch');
GO