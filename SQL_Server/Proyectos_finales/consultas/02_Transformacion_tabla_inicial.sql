-----------------------------------------------------------------------------------
--  02. Tomar la tabla con los datos ingresados y ponerlos en el formato correcto
-----------------------------------------------------------------------------------


-- Base
USE BankFraud;
GO

-- Revisar la tabla para ir viendo los tipos
-- Se hace asi cambiando la original? o es recomendable hacer otra tabla nueva?!!
SELECT TOP 10 * FROM stg_BankFraud.raw_BankFraud;

-- Se hace columna por columna
ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN transaction_id VARCHAR(255) NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN customer_id VARCHAR(255) NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN transaction_date DATE NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN transaction_time TIME(0) NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN hour_of_day INT NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN is_weekend BIT NULL; -- Puede ser int o bit, bool no existe en SQL server
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN is_night_transaction BIT NULL; -- Puede ser int o bit, bool no existe en SQL server
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN country VARCHAR(100) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN city VARCHAR(100) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN merchant_category VARCHAR(100) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN payment_method VARCHAR(100) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN device_type VARCHAR(100) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN customer_age INT NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN credit_score INT NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN account_age_years DECIMAL(10,2) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN account_balance DECIMAL(18,2) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN transaction_amount DECIMAL(18,2) NULL; 
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN num_prev_transactions INT NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN transaction_freq_monthly INT NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN distance_from_home_km DECIMAL(10,2) NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN time_since_last_txn_hrs DECIMAL(10,2) NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN is_international BIT NULL; -- Puede ser int o bit, bool no existe en SQL server
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN failed_attempts INT NULL;
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN pin_changed_recently BIT NULL; -- Puede ser int o bit, bool no existe en SQL server
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN is_fraud BIT NULL; -- Puede ser int o bit, bool no existe en SQL server
GO

ALTER TABLE stg_BankFraud.raw_BankFraud
ALTER COLUMN fraud_type VARCHAR(100) NULL;
GO

-- Hacemos consulta basica
SELECT TOP 5 * FROM stg_BankFraud.raw_BankFraud;

-- Corroboramos los tipos
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg_BankFraud'
	AND TABLE_NAME = 'raw_BankFraud'
ORDER BY ORDINAL_POSITION;