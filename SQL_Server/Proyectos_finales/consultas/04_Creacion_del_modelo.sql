-------------------------------------------------------------------------------------------------------------------------
--  04. Crear las tablas de hecho y dimesiones junto con el modelo estrella, ademas de poblar las tablas correspondientes
-------------------------------------------------------------------------------------------------------------------------
-- Conocer qué tenemos
USE BankFraud;
GO

-- 1. Crear esquema para el modelo dimensional final para el Data Warehouse
IF SCHEMA_ID('dw_BankFraud') IS NULL
    EXEC('CREATE SCHEMA dw_BankFraud');
GO

-- 2. Crear tablas con las dimensiones
-- 2.1 Dimensión de fecha y hora
CREATE TABLE dw_BankFraud.DimDate (
    date_key                    INT IDENTITY(1,1) PRIMARY KEY,
    full_date                   DATE NOT NULL UNIQUE,
    year                        INT NOT NULL,
    quarter                     INT NOT NULL,
    month                       INT NOT NULL,
    day_of_month                INT NOT NULL,
    day_of_week                 INT NOT NULL,
    is_weekend                  INT NOT NULL

   -- CONSTRAINT CK_DimDate_IsWeekend
      --  CHECK (is_weekend IN (0,1))
);
GO

-- 2.2 Dimensión de hora (Esta no la habia hecho)
CREATE TABLE dw_BankFraud.DimTime (
    time_key SMALLINT PRIMARY KEY,
    hour_of_day TINYINT NOT NULL UNIQUE,
    is_night_transaction BIT NOT NULL
);

-- 2.3. Dimensión de clientes
-- CREATE TABLE dw_BankFraud.DimCustomer (
   --  customer_key                INT IDENTITY(1,1) PRIMARY KEY,
    -- customer_id                 VARCHAR(40) NOT NULL UNIQUE,
    -- customer_age                SMALLINT,
    -- credit_score                SMALLINT,
    -- account_age_years           DECIMAL(6,2)
-- );
-- GO

-- 2.3. Dimensión de clientes
CREATE TABLE dw_BankFraud.DimCustomer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id  VARCHAR(40) NOT NULL UNIQUE
);
GO

-- 2.4. Dimensión de ubicación
CREATE TABLE dw_BankFraud.DimLocation (
    location_key                INT IDENTITY(1,1) PRIMARY KEY,
    country                     VARCHAR(80) NOT NULL,
    city                        VARCHAR(120) NOT NULL,
    CONSTRAINT UQ_DimLocation_Country_City UNIQUE (country, city) -- Esta bien esto?
);
GO

-- 2.5. Dimensión de categoría del comercio
CREATE TABLE dw_BankFraud.DimMerchantCategory (
    merchant_category_key        INT IDENTITY(1,1) PRIMARY KEY,
    merchant_category            VARCHAR(100) NOT NULL UNIQUE
);


-- 2.6. Dimensión de método de pago
CREATE TABLE dw_BankFraud.DimPaymentMethod (
    payment_method_key            INT IDENTITY(1,1) PRIMARY KEY,
    payment_method                VARCHAR(80) NOT NULL UNIQUE
);
GO

-- 2.7. Dimensión de tipo de dispositivo
CREATE TABLE dw_BankFraud.DimDeviceType (
    device_type_key                 INT IDENTITY(1,1) PRIMARY KEY,
    device_type                     VARCHAR(80) NOT NULL UNIQUE
);
GO

-- 3. Crear la tabla de hechos
CREATE TABLE dw_BankFraud.FactTransaction (
    -- Identificadores
    transaction_key                 INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id                  VARCHAR(40) NOT NULL UNIQUE,

    -- Claves foraneas de las dimensiones
    date_key                        INT NOT NULL,
    time_key                        SMALLINT NOT NULL,
    customer_key                    INT NOT NULL,
    location_key                    INT NOT NULL,
    merchant_category_key           INT NOT NULL,
    payment_method_key              INT NOT NULL,
    device_type_key                 INT NOT NULL,

     -- Atributos del cliente registrados en cada transacción
    customer_age                    SMALLINT,
    credit_score                    SMALLINT,
    account_age_years               DECIMAL(6,2),

    -- Datos de la transacción
    transaction_amount             DECIMAL(18,2),
    account_balance                DECIMAL(18,2),
    num_prev_transactions          INT,
    transaction_freq_monthly       DECIMAL(12,3),
    distance_from_home_km          DECIMAL(12,3),
    time_since_last_txn_hrs        DECIMAL(12,3),
    is_international               INT,
    failed_attempts                INT,
    pin_changed_recently           INT,
    is_fraud                       INT,
    fraud_type                     VARCHAR(100),

    -- Restricciones
    CONSTRAINT FK_FactTransaction_Date
    FOREIGN KEY (date_key)
    REFERENCES dw_BankFraud.DimDate(date_key),

    CONSTRAINT FK_FactTransaction_Time
    FOREIGN KEY (time_key)
    REFERENCES dw_BankFraud.DimTime(time_key),

    CONSTRAINT FK_FactTransaction_Customer
    FOREIGN KEY (customer_key)
    REFERENCES dw_BankFraud.DimCustomer(customer_key),

    CONSTRAINT FK_FactTransaction_Location
    FOREIGN KEY (location_key)
    REFERENCES dw_BankFraud.DimLocation(location_key),

    CONSTRAINT FK_FactTransaction_Merchant
    FOREIGN KEY (merchant_category_key)
    REFERENCES dw_BankFraud.DimMerchantCategory(merchant_category_key),

    CONSTRAINT FK_FactTransaction_Payment
    FOREIGN KEY (payment_method_key)
    REFERENCES dw_BankFraud.DimPaymentMethod(payment_method_key),

    CONSTRAINT FK_FactTransaction_Device
    FOREIGN KEY (device_type_key)
    REFERENCES dw_BankFraud.DimDeviceType(device_type_key)
);
GO


-- 4. Cargar los datos y corroborar
-- Hay que revisar el orden en que cargamos las tablas

-- 4.1. Dimensión de fecha
-- Solo quiero una fila por dia, por eso el group by
INSERT INTO dw_BankFraud.DimDate (
    full_date,
    year,
    quarter,
    month,
    day_of_month,
    day_of_week,
    is_weekend
)
SELECT
    transaction_date,
    YEAR(transaction_date),
    DATEPART(QUARTER, transaction_date),
    MONTH(transaction_date),
    DAY(transaction_date),
    (DATEDIFF(DAY, '19000101', transaction_date) % 7) + 1,
    MAX(CAST(is_weekend AS INT))
FROM stg_BankFraud.raw_BankFraud
GROUP BY transaction_date;
GO

-- 4.2. Dimensión de hora
INSERT INTO dw_BankFraud.DimTime (
    time_key, hour_of_day, is_night_transaction
)
SELECT
    hour_of_day, hour_of_day,
    MAX(CAST(is_night_transaction AS INT))
FROM stg_BankFraud.raw_BankFraud
GROUP BY hour_of_day;
GO



-- 4.3. Dimensión de clientes
-- INSERT INTO dw_BankFraud.DimCustomer (
   -- customer_id, customer_age, credit_score,account_age_years
-- )
-- SELECT
   -- customer_id,
    -- MAX(customer_age),
    -- MAX(credit_score),
    -- MAX(account_age_years)
-- FROM stg_BankFraud.raw_BankFraud
-- GROUP BY customer_id;
-- GO

-- 4.3. Cargar dimensión de clientes
INSERT INTO dw_BankFraud.DimCustomer (customer_id)
SELECT DISTINCT customer_id
FROM stg_BankFraud.raw_BankFraud;
GO


-- 4.4.Dimensión de ubicación
INSERT INTO dw_BankFraud.DimLocation (
    country,city
)
SELECT DISTINCT
    country,city
FROM stg_BankFraud.raw_BankFraud;
GO

-- 4.5. Dimensión de categoría del comercio
INSERT INTO dw_BankFraud.DimMerchantCategory (
    merchant_category
)
SELECT DISTINCT merchant_category
FROM stg_BankFraud.raw_BankFraud;
GO

-- 4.6 Dimensión de método de pago
INSERT INTO dw_BankFraud.DimPaymentMethod (
    payment_method
)
SELECT DISTINCT payment_method
FROM stg_BankFraud.raw_BankFraud;
GO

-- 4.7 Dimensión de tipo de dispositivo
INSERT INTO dw_BankFraud.DimDeviceType (
    device_type
)
SELECT DISTINCT device_type
FROM stg_BankFraud.raw_BankFraud;
GO


-- 5. Cargar la tabla de hechos
INSERT INTO dw_BankFraud.FactTransaction (
    transaction_id, date_key, time_key,
    customer_key, location_key, merchant_category_key,
    payment_method_key, device_type_key,

    -- Atributos del cliente
    customer_age, credit_score, account_age_years,

    -- Datos de la transacción
    transaction_amount, account_balance,
    num_prev_transactions, transaction_freq_monthly,
    distance_from_home_km, time_since_last_txn_hrs,
    is_international, failed_attempts,
    pin_changed_recently, is_fraud, fraud_type
)
SELECT
    r.transaction_id,
    d.date_key,
    t.time_key,
    c.customer_key,
    l.location_key,
    mc.merchant_category_key,
    pm.payment_method_key,
    dv.device_type_key,

    -- Atributos del cliente
    r.customer_age,
    r.credit_score,
    r.account_age_years,

    -- Datos de la transacción
    r.transaction_amount,
    r.account_balance,
    r.num_prev_transactions,
    r.transaction_freq_monthly,
    r.distance_from_home_km,
    r.time_since_last_txn_hrs,
    r.is_international,
    r.failed_attempts,
    r.pin_changed_recently,
    r.is_fraud,
    r.fraud_type

FROM stg_BankFraud.raw_BankFraud AS r

INNER JOIN dw_BankFraud.DimDate AS d
    ON r.transaction_date = d.full_date

INNER JOIN dw_BankFraud.DimTime AS t
    ON r.hour_of_day = t.hour_of_day

INNER JOIN dw_BankFraud.DimCustomer AS c
    ON r.customer_id = c.customer_id

INNER JOIN dw_BankFraud.DimLocation AS l
    ON r.country = l.country
   AND r.city = l.city

INNER JOIN dw_BankFraud.DimMerchantCategory AS mc
    ON r.merchant_category = mc.merchant_category

INNER JOIN dw_BankFraud.DimPaymentMethod AS pm
    ON r.payment_method = pm.payment_method

INNER JOIN dw_BankFraud.DimDeviceType AS dv
    ON r.device_type = dv.device_type;
GO


-- 6. Se corrobora que todo este correctamente cargado en las tablas
SELECT 'DimDate' AS tabla, COUNT(*) AS registros FROM dw_BankFraud.DimDate

UNION ALL

SELECT 'DimTime', COUNT(*) FROM dw_BankFraud.DimTime

UNION ALL

SELECT 'DimCustomer', COUNT(*) FROM dw_BankFraud.DimCustomer

UNION ALL

SELECT 'DimLocation', COUNT(*) FROM dw_BankFraud.DimLocation

UNION ALL

SELECT 'DimMerchantCategory', COUNT(*) FROM dw_BankFraud.DimMerchantCategory

UNION ALL

SELECT 'DimPaymentMethod', COUNT(*) FROM dw_BankFraud.DimPaymentMethod

UNION ALL

SELECT 'DimDeviceType', COUNT(*) FROM dw_BankFraud.DimDeviceType

UNION ALL

SELECT 'FactTransaction', COUNT(*) FROM dw_BankFraud.FactTransaction;
GO





-- Comparar los registros de origen con los de la tabla de hechos
SELECT
    COUNT(*) AS total_filas,
    COUNT(DISTINCT transaction_id) AS transacciones_distintas
FROM dw_BankFraud.FactTransaction;


-- 7. Verificar que todas las claves foráneas estén completas.
SELECT
    COUNT(*) AS total_filas,
    SUM(CASE WHEN date_key IS NULL THEN 1 ELSE 0 END) AS fechas_nulas,
    SUM(CASE WHEN time_key IS NULL THEN 1 ELSE 0 END) AS horas_nulas,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS clientes_nulos,
    SUM(CASE WHEN location_key IS NULL THEN 1 ELSE 0 END) AS ubicaciones_nulas
FROM dw_BankFraud.FactTransaction;






-------------------------------------------------------------------------------------
-- Por si hay errores
-- 1. Eliminar primero la tabla de hechos
-- DROP TABLE IF EXISTS dw_BankFraud.FactTransaction;
-- GO

-- 2. Eliminar las dimensiones
DROP TABLE IF EXISTS dw_BankFraud.DimDate;
DROP TABLE IF EXISTS dw_BankFraud.DimTime
DROP TABLE IF EXISTS dw_BankFraud.DimCustomer;
DROP TABLE IF EXISTS dw_BankFraud.DimLocation;
DROP TABLE IF EXISTS dw_BankFraud.DimMerchantCategory;
DROP TABLE IF EXISTS dw_BankFraud.DimPaymentMethod;
DROP TABLE IF EXISTS dw_BankFraud.DimDeviceType;
DROP TABLE IF EXISTS dw_BankFraud.FactTransaction
GO






