-----------------------------------------------------------------
--  01. Creacion base de datos, esquema e imputacion de los datos
-----------------------------------------------------------------
USE master;
GO
-- Crear base de datos
CREATE DATABASE BankFraud;
GO
-- Usamos base de datos
USE BankFraud;
GO
-- Creamos esquema el esquema stg (Staging) de prueba
CREATE SCHEMA stg_BankFraud;
GO
-- Creamos la tabla para las 26 columnas
CREATE TABLE stg_BankFraud.raw_BankFraud (
        transaction_id           NVARCHAR(100) NULL,
        customer_id              NVARCHAR(100) NULL,
        transaction_date         NVARCHAR(50) NULL,
        transaction_time         NVARCHAR(50) NULL,
        hour_of_day              NVARCHAR(20) NULL,
        is_weekend               NVARCHAR(10) NULL,
        is_night_transaction     NVARCHAR(10) NULL,
        country                  NVARCHAR(100) NULL,
        city                     NVARCHAR(100) NULL,
        merchant_category        NVARCHAR(100) NULL,
        payment_method           NVARCHAR(100) NULL,
        device_type              NVARCHAR(100) NULL,
        customer_age             NVARCHAR(20) NULL,
        credit_score             NVARCHAR(20) NULL,
        account_age_years        NVARCHAR(30) NULL,
        account_balance          NVARCHAR(40) NULL,
        transaction_amount       NVARCHAR(40) NULL,
        num_prev_transactions    NVARCHAR(20) NULL,
        transaction_freq_monthly NVARCHAR(30) NULL,
        distance_from_home_km    NVARCHAR(30) NULL,
        time_since_last_txn_hrs  NVARCHAR(30) NULL,
        is_international         NVARCHAR(10) NULL,
        failed_attempts          NVARCHAR(20) NULL,
        pin_changed_recently     NVARCHAR(10) NULL,
        is_fraud                 NVARCHAR(10) NULL,
        fraud_type               NVARCHAR(100) NULL
    );
GO

-- Insertar los datos que estan en csv
BULK INSERT stg_BankFraud.raw_BankFraud
FROM 'D:\Josefina\Proyectos\Datascience\SQL\SQL_Server\data\bank_fraud.csv'
WITH (
    FIRSTROW = 2,                           -- Salta los encabezados del CSV
    FIELDTERMINATOR = ',',                  -- Cambia por ';' si tu Excel lo guardó con punto y coma
    ROWTERMINATOR = '0x0a',                 -- Obliga a Windows a leer el salto de línea de Kaggle
    CODEPAGE = '65001'                      -- Codificación UTF-8 para evitar errores con caracteres raros
);
GO

-- Corroboramos que este se hayan imputado bien los datos
SELECT TOP 20 * FROM stg_BankFraud.raw_BankFraud;

-- Corroboramos la cantidad de filas 
SELECT COUNT(*) AS cantidadRegristros FROM stg_BankFraud.raw_BankFraud;

-- Corroboramos tipos
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg_BankFraud'
	AND TABLE_NAME = 'raw_BankFraud'
ORDER BY ORDINAL_POSITION;