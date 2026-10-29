-- Crea la tabla raw y carga el CSV original. Requiere SQL Server 2017+.
USE [Aethel_Capital_Bank];
GO

-- Ajustar la ruta si se mueve el archivo. SQL Server debe tener acceso de lectura.
IF OBJECT_ID(N'dbo.raw_bank_fraud', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.raw_bank_fraud
    (
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
END;
GO

-- Evita duplicar filas si se vuelve a ejecutar el script.
IF EXISTS (SELECT 1 FROM dbo.raw_bank_fraud)
    THROW 50001, 'La tabla raw_bank_fraud ya contiene datos. No se realizó otra carga.', 1;
GO

BULK INSERT dbo.raw_bank_fraud
FROM N'D:\workspace\courses\data-engineering\database-management\BC-2020610-01GEDA SQL Server\Sessions\S04\Project\data\bank_fraud.csv'
WITH
(
    FORMAT = 'CSV',        
    FIRSTROW = 2,           -- Salta los encabezados del CSV
    FIELDTERMINATOR = ',',  -- Cambia por ';' si tu Excel lo guardó con punto y coma
    ROWTERMINATOR = '0x0a',  -- Obliga a Windows a leer el salto de línea de Kaggle
    CODEPAGE = '65001',     -- Codificación UTF-8 para evitar errores con caracteres raros
    FIELDQUOTE = '"',
    TABLOCK
);
GO

-- Confirma la cantidad cargada.
SELECT COUNT(*) AS filas_cargadas
FROM dbo.raw_bank_fraud;
GO