
-----------------------------------------------------------------
--  01. Creacion base de datos, esquema e imputacion de los datos
-----------------------------------------------------------------
-- Crear base de datos
CREATE DATABASE BankTransactions;
GO
-- Usamos base de datos
USE BankTransactions;
GO

-- Creamos esquema
CREATE SCHEMA stg;
GO


-- Crear la tabla para las 16 columnas
CREATE TABLE stg.BankTransactionsRaw (
    TransactionID NVARCHAR(50),
    AccountID NVARCHAR(50),
    TransactionAmount NVARCHAR(50),
    TransactionDate NVARCHAR(50),
    TransactionType NVARCHAR(50),
    Location NVARCHAR(100),
    DeviceID NVARCHAR(50),
    IP_Address NVARCHAR(50),
    MerchantID NVARCHAR(50),
    Channel NVARCHAR(50),
    CustomerAge NVARCHAR(50),
    CustomerOccupation NVARCHAR(100),
    TransactionDuration NVARCHAR(50),
    LoginAttempts NVARCHAR(50),
    AccountBalance NVARCHAR(50),
    PreviousTransactionDate NVARCHAR(50),    
);
GO

-- Comprobar que se creo la tabla
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'stg';

-- Forma para cargar desde un csv local
-- Revisar esta parte!
BULK INSERT stg.BankTransactionsRaw
FROM 'D:\Josefina\Proyectos\Datascience\SQL\SQL_Server\Proyectos_finales\data\bank_transactions_data_2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

-- Comprobamos que esta todo ok
SELECT COUNT(*) AS CantidadFilas
FROM stg.BankTransactionsRaw;
GO

SELECT TOP (10) *
FROM stg.BankTransactionsRaw;
GO