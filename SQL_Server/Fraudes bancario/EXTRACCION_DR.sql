-- =====================================================
-- Base de datos: FRAUDE BANCARIO (SQL Server / T-SQL)
-- =====================================================
IF DB_ID('BANK_DATA') IS NULL
    CREATE DATABASE BANK_DATA
GO

USE BANK_DATA;
GO

CREATE TABLE fraude_banco (
    TransactionID VARCHAR(255),
    AccountID VARCHAR(255),
    TransactionAmount DECIMAL(10,2),
    TransactionDate DATETIME,
    TransactionType VARCHAR(255),
    Locat VARCHAR(255),
    DeviceID VARCHAR(255),
    IP_Address VARCHAR(255), -- Representa 'IP Address'
    MerchantID VARCHAR(255),
    Channel VARCHAR(255),
    CustomerAge INT,
    CustomerOccupation VARCHAR(255),
    TransactionDuration INT,
    LoginAttempts VARCHAR(255),
    AccountBalance DECIMAL(10,2),
    PreviousTransactionDate DATETIME
);


BULK INSERT fraude_banco
FROM 'C:\Users\TOSHIBA\Downloads\bank_transactions_data_2.csv' -- Reemplaza con la ruta de tu PC
WITH (
    FIRSTROW = 2,           -- Salta los encabezados del CSV
    FIELDTERMINATOR = ',',  -- Cambia por ';' si tu Excel lo guardó con punto y coma
    ROWTERMINATOR = '0x0a',  -- Obliga a Windows a leer el salto de línea de Kaggle
    CODEPAGE = '65001'      -- Codificación UTF-8 para evitar errores con caracteres raros
);

SELECT* FROM fraude_banco


