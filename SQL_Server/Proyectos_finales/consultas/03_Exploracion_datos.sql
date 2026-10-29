----------------------------------------------------------------------------------------
--  03. Exploración de la tabla inicial para ver inconsistencias, nulos, faltantes (EDA)
----------------------------------------------------------------------------------------

-- Usar base
USE BankFraud;
GO
-- 1. Vemos que tipo de datos son y si esta ok
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg_BankFraud'
	AND TABLE_NAME = 'raw_BankFraud'
ORDER BY ORDINAL_POSITION;


-- 1.1 Mirar muestra de datos
SELECT TOP 10 * FROM stg_BankFraud.raw_BankFraud;


-- 2. Cantidad de valores distintos por cada columna
-- Hay alguna otra forma de hacer esto? demasiada repeticion innecesaria
SELECT 'transaction_id' AS columna, COUNT(DISTINCT transaction_id) AS cantidad_valores_distintos FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'customer_id', COUNT(DISTINCT customer_id) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'transaction_date', COUNT(DISTINCT transaction_date) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'transaction_time', COUNT(DISTINCT transaction_time) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'hour_of_day', COUNT(DISTINCT hour_of_day) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'is_weekend', COUNT(DISTINCT is_weekend) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'is_night_transaction', COUNT(DISTINCT is_night_transaction) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'country', COUNT(DISTINCT country) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'city', COUNT(DISTINCT city) FROM stg_BankFraud.raw_BankFraud
UNION ALL
SELECT 'merchant_category', COUNT(DISTINCT merchant_category) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'payment_method', COUNT(DISTINCT payment_method) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'device_type', COUNT(DISTINCT device_type) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'customer_age', COUNT(DISTINCT customer_age) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'credit_score', COUNT(DISTINCT credit_score) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'account_age_years', COUNT(DISTINCT account_age_years) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'account_balance', COUNT(DISTINCT account_balance) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'transaction_amount', COUNT(DISTINCT transaction_amount) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'num_prev_transactions', COUNT(DISTINCT num_prev_transactions) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'transaction_freq_monthly', COUNT(DISTINCT transaction_freq_monthly) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'distance_from_home_km', COUNT(DISTINCT distance_from_home_km) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'time_since_last_txn_hrs', COUNT(DISTINCT time_since_last_txn_hrs) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'is_international', COUNT(DISTINCT is_international) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'failed_attempts', COUNT(DISTINCT failed_attempts) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'pin_changed_recently', COUNT(DISTINCT pin_changed_recently) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'is_fraud', COUNT(DISTINCT is_fraud) FROM stg_BankFraud.raw_BankFraud 
UNION ALL
SELECT 'fraud_type', COUNT(DISTINCT fraud_type) FROM stg_BankFraud.raw_BankFraud 


-- 3. Comprobar si hay identificadores repetidos de transaction_id
-- No hay transaction_id repetidos
SELECT transaction_id, COUNT(transaction_id) AS cantidad
FROM stg_BankFraud.raw_BankFraud
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 3.1 Tambien veo si hay registros completos iguales
SELECT
    customer_id, transaction_date, transaction_time, hour_of_day, is_weekend,
    is_night_transaction, country, city,merchant_category, payment_method,device_type,
    customer_age, credit_score, account_age_years, account_balance, transaction_amount,
    num_prev_transactions, transaction_freq_monthly, distance_from_home_km, time_since_last_txn_hrs,
    is_international, failed_attempts, pin_changed_recently, is_fraud, fraud_type,
    COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
GROUP BY
    customer_id, transaction_date, transaction_time, hour_of_day, is_weekend,
    is_night_transaction, country, city,merchant_category, payment_method,device_type,
    customer_age, credit_score, account_age_years, account_balance, transaction_amount,
    num_prev_transactions, transaction_freq_monthly, distance_from_home_km, time_since_last_txn_hrs,
    is_international, failed_attempts, pin_changed_recently, is_fraud, fraud_type
HAVING COUNT(*) > 1;


-- 4. Comprobar si hay nulos y valores vacios
-- No hay nulos en ninguna fila
-- Nulos
SELECT
    COUNT(*) AS TotalFilas,
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id_Nulos,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_Nulos,
    SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) AS transaction_date_Nulos,
    SUM(CASE WHEN transaction_time IS NULL THEN 1 ELSE 0 END) AS transaction_time_Nulos,
    SUM(CASE WHEN hour_of_day IS NULL THEN 1 ELSE 0 END) AS hour_of_day_Nulos,
    SUM(CASE WHEN is_weekend IS NULL THEN 1 ELSE 0 END) AS is_weekend_Nulos,
    SUM(CASE WHEN is_night_transaction IS NULL THEN 1 ELSE 0 END) AS is_night_transaction_Nulos,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_Nulos,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_Nulos,
    SUM(CASE WHEN merchant_category IS NULL THEN 1 ELSE 0 END) AS merchant_category_Nulos,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS payment_method_Nulos,
    SUM(CASE WHEN device_type IS NULL THEN 1 ELSE 0 END) AS device_type_Nulos,
    SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS customer_age_Nulos,
    SUM(CASE WHEN credit_score IS NULL THEN 1 ELSE 0 END) AS credit_score_Nulos,
    SUM(CASE WHEN account_age_years IS NULL THEN 1 ELSE 0 END) AS account_age_years_Nulos,
    SUM(CASE WHEN account_balance IS NULL THEN 1 ELSE 0 END) AS account_balance_Nulos,
    SUM(CASE WHEN transaction_amount IS NULL THEN 1 ELSE 0 END) AS transaction_amount_Nulos,
    SUM(CASE WHEN num_prev_transactions IS NULL THEN 1 ELSE 0 END) AS num_prev_transactions_Nulos,
    SUM(CASE WHEN transaction_freq_monthly IS NULL THEN 1 ELSE 0 END) AS transaction_freq_monthly_Nulos,
    SUM(CASE WHEN distance_from_home_km IS NULL THEN 1 ELSE 0 END) AS distance_from_home_km_Nulos,
    SUM(CASE WHEN time_since_last_txn_hrs IS NULL THEN 1 ELSE 0 END) AS time_since_last_txn_hrs_Nulos,
    SUM(CASE WHEN is_international IS NULL THEN 1 ELSE 0 END) AS is_international_Nulos,
    SUM(CASE WHEN failed_attempts IS NULL THEN 1 ELSE 0 END) AS failed_attempts_Nulos,
    SUM(CASE WHEN pin_changed_recently IS NULL THEN 1 ELSE 0 END) AS pin_changed_recently_Nulos,
    SUM(CASE WHEN is_fraud IS NULL THEN 1 ELSE 0 END) AS is_fraud_Nulos,
    SUM(CASE WHEN fraud_type IS NULL THEN 1 ELSE 0 END) AS fraud_type_Nulos

FROM stg_BankFraud.raw_BankFraud;


-- 4.1 Vacios
-- Solo lo puedo hacer de esta forma con las columnas de texto, porque se supone que en las demas no hay vacios
-- Cantidad de textos vacíos
SELECT
    COUNT(*) AS TotalFilas,
    SUM(CASE WHEN transaction_id = '' THEN 1 ELSE 0 END) AS transaction_id_vacios,
    SUM(CASE WHEN customer_id = '' THEN 1 ELSE 0 END) AS customer_id_vacios,
    SUM(CASE WHEN country = '' THEN 1 ELSE 0 END) AS country_vacios,
    SUM(CASE WHEN city = '' THEN 1 ELSE 0 END) AS city_vacios,
    SUM(CASE WHEN merchant_category = '' THEN 1 ELSE 0 END) AS merchant_category_vacios,
    SUM(CASE WHEN payment_method = '' THEN 1 ELSE 0 END) AS payment_method_vacios,
    SUM(CASE WHEN device_type = '' THEN 1 ELSE 0 END) AS device_type_vacios,
    SUM(CASE WHEN fraud_type = '' THEN 1 ELSE 0 END) AS fraud_type_vacios
FROM stg_BankFraud.raw_BankFraud;



-- 4.2.Marcadores textuales
-- Se hace solo en las columnas que hay texto
-- Solo hay en tipo de fraude
SELECT
    COUNT(*) AS TotalFilas, 
    SUM(CASE WHEN UPPER(LTRIM(RTRIM(transaction_id))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS transaction_id_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(customer_id))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS customer_id_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(country))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS country_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(city))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS city_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(merchant_category))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS merchant_category_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(payment_method))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS payment_method_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(device_type))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS device_type_marcadores,

    SUM(CASE WHEN UPPER(LTRIM(RTRIM(fraud_type))) IN ('N/A', 'NA', 'UNKNOWN', 'NONE', 'NULL', 'SIN DATO', '-') THEN 1 ELSE 0 END) AS fraud_type_marcadores

FROM stg_BankFraud.raw_BankFraud;

-- 5. Corroboramos periodo del dataset
-- Desde 2020 - 2024, esta ok
SELECT 
    MIN(transaction_date) AS fecha_inicial,
    MAX(transaction_date) AS fecha_fin
FROM stg_BankFraud.raw_BankFraud;


-- 6. Valores únicos de las variables categóricas
-- Son 10 paises distintos
SELECT DISTINCT country
FROM stg_BankFraud.raw_BankFraud
ORDER BY country;

-- Son 20 ciudades distintas
SELECT DISTINCT city
FROM stg_BankFraud.raw_BankFraud
ORDER BY city;

-- Son 15 categirias distintas
SELECT DISTINCT merchant_category
FROM stg_BankFraud.raw_BankFraud
ORDER BY merchant_category;

-- Son 6 metodos de pagos
SELECT DISTINCT payment_method
FROM stg_BankFraud.raw_BankFraud
ORDER BY payment_method;

-- Son 5 tipos de dispositivo
SELECT DISTINCT device_type
FROM stg_BankFraud.raw_BankFraud
ORDER BY device_type;

-- Son 7 tipos de fraude,
-- hay uno que es None que significa? Lo cambiamos o lo dejamos asi?
SELECT DISTINCT fraud_type
FROM stg_BankFraud.raw_BankFraud
ORDER BY fraud_type;

-- 7. Hay columnas que son binarias,comprobar que solo sean esos numeros
-- Columnas: is_weekend, is_night_transaction, is_international, pin_changed_recently y is_fraud
-- Son todos 0 y 1

SELECT 'is_weekend' AS columna, COUNT(*) AS valores_invalidos
    FROM stg_BankFraud.raw_BankFraud
    WHERE is_weekend != 0 AND is_weekend != 1
UNION ALL

SELECT 'is_night_transaction', COUNT(*)
    FROM stg_BankFraud.raw_BankFraud
    WHERE is_night_transaction != 0 AND is_night_transaction != 1 

UNION ALL

SELECT 'is_international', COUNT(*)
FROM stg_BankFraud.raw_BankFraud
WHERE is_international != 0 AND is_international != 1 

UNION ALL

SELECT 'pin_changed_recently', COUNT(*)
FROM stg_BankFraud.raw_BankFraud
WHERE pin_changed_recently != 0 AND pin_changed_recently != 1 

UNION ALL
-- 1 = Fraud, 0 = Legitimate
SELECT 'is_fraud', COUNT(*)
FROM stg_BankFraud.raw_BankFraud
WHERE is_fraud != 0 AND is_fraud != 1 


-- 8. Conocer valores minimos y maximos de las variables numericas
-- Creo que lo mas importante a revisar son las edades, las horas, antiguedad que sean numeros razonables y que no haya negativos
--
SELECT
    MIN(customer_age) AS edad_minima,
    MAX(customer_age) AS edad_maxima,
    MIN(credit_score) AS score_minimo,
    MAX(credit_score) AS score_maximo,
    MIN(account_age_years) AS antiguedad_minima,
    MAX(account_age_years) AS antiguedad_maxima,
    MIN(account_balance) AS saldo_minimo,
    MAX(account_balance) AS saldo_maximo,
    MIN(transaction_amount) AS monto_minimo,
    MAX(transaction_amount) AS monto_maximo,
    MIN(failed_attempts) AS intentos_minimos,
    MAX(failed_attempts) AS intentos_maximos,
    MIN(hour_of_day) AS hora_minima,
    MAX(hour_of_day) AS hora_maxima
FROM stg_BankFraud.raw_BankFraud;


-- 09. is_night_transaction: que coincida con la hora, entre 22:00 y las 06:00 (inclusive) es nocturno is_night_transaction = 1
-- Todos los de la hora
SELECT COUNT(*) AS horarios_nocturnos_inconsistentes
FROM stg_BankFraud.raw_BankFraud
WHERE is_night_transaction <>
    CASE
        -- WHEN transaction_time BETWEEN '22:00:00' AND '06:59:59' THEN 1 ELSE 0 -- No funciona, porque?
        WHEN transaction_time >= '22:00:00' OR transaction_time <= '06:59:59' THEN 1 ELSE 0
    END;

-- 10. Que credit_score esté entre 300 y 850
SELECT COUNT(*) AS cantidad_rango
FROM stg_BankFraud.raw_BankFraud
WHERE credit_score < 300 OR credit_score > 850;

-- 11. Que hour_of_day este entre 0-23
SELECT COUNT(*) AS cantidad_rango
FROM stg_BankFraud.raw_BankFraud
WHERE hour_of_day < 0 OR hour_of_day > 23;

-- 12. Consistencia de las categorías (minusculas/mayusculas/espacios)
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg_BankFraud'
	AND TABLE_NAME = 'raw_BankFraud'
ORDER BY ORDINAL_POSITION;
-- Deberia cambiar country, city, merchant_category, payment_method, device_type, fraud_type
-- Veo como queda y despues actualizo la tabla
-- LTRIM: elimina los espacios que hay al principio del texto
-- RTRIM: elimina los espacios que hay al final del texto.


-- Pais
SELECT country, LOWER(LTRIM(RTRIM(country))) AS country_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY country

-- Ciudad
SELECT city, LOWER(LTRIM(RTRIM(city))) AS city_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY city

-- Categoria
SELECT merchant_category, LOWER(LTRIM(RTRIM(merchant_category))) AS merchant_category_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY merchant_category


-- Metodo de pago
SELECT payment_method, LOWER(LTRIM(RTRIM(payment_method))) AS payment_method_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY Payment_method


-- device_type, 
SELECT device_type, LOWER(LTRIM(RTRIM(device_type))) AS device_type_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY device_type


-- fraud_type
SELECT fraud_type, LOWER(LTRIM(RTRIM(fraud_type))) AS fraud_type_limpio
FROM stg_BankFraud.raw_BankFraud
GROUP BY fraud_type

-- Actualizamos la tabla asi queda todo consistente

UPDATE stg_BankFraud.raw_BankFraud
SET country = LOWER(LTRIM(RTRIM(country)))
WHERE country IS NOT NULL;

UPDATE stg_BankFraud.raw_BankFraud
SET city = LOWER(LTRIM(RTRIM(city)))
WHERE city IS NOT NULL;

UPDATE stg_BankFraud.raw_BankFraud
SET merchant_category = LOWER(LTRIM(RTRIM(merchant_category)))
WHERE merchant_category IS NOT NULL;

UPDATE stg_BankFraud.raw_BankFraud
SET payment_method = LOWER(LTRIM(RTRIM(payment_method)))
WHERE payment_method IS NOT NULL;

UPDATE stg_BankFraud.raw_BankFraud
SET device_type = LOWER(LTRIM(RTRIM(device_type)))
WHERE device_type IS NOT NULL;

UPDATE stg_BankFraud.raw_BankFraud
SET fraud_type = LOWER(LTRIM(RTRIM(fraud_type)))
WHERE fraud_type IS NOT NULL;

-- Comprobamos
SELECT TOP 10 * FROM stg_BankFraud.raw_BankFraud;

-- 13. Consistencia de las etiquetas de fraude is_fraud y fraud_type
-- Hay consistencia entre los datos porque cuando es 0 en is_fraud significa que no hay fraude. Mientras que el resto
-- cuando is_fraud es 1 muestra los distintos tipos de fraude
SELECT is_fraud, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
GROUP BY is_fraud, fraud_type
ORDER BY is_fraud, fraud_type;

-- 14. Consistencia entre el metodo de pago y y el tipo de fraude
SELECT DISTINCT payment_method
FROM stg_BankFraud.raw_BankFraud 
-- bank transfer, mobile payment, credit card, crypto, cheque, debit card

-- En este me resulta extraño lo de card cloning con bank transfer.   
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'bank transfer'
GROUP BY payment_method, fraud_type;

-- No veo inconsistencias
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'mobile payment'
GROUP BY payment_method, fraud_type;
-- No veo inconsistencias
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'credit card'
GROUP BY payment_method, fraud_type;

-- Resulta raro lo de card cloning y friendly fraud 
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'crypto'
GROUP BY payment_method, fraud_type;

-- Resulta raro lo de card cloning 
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'cheque'
GROUP BY payment_method, fraud_type;

-- No veo inconsistencias
SELECT payment_method, fraud_type, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
WHERE payment_method = 'debit card'
GROUP BY payment_method, fraud_type;



-- 15. Consistencias de los clientes
-- Aca hay una inconsistencia grandes porque no es unico el valor de customer id, se repite 
-- Sera por la fecha, la ciudad, el pais la diferencia de porque se repiten los id? o porque otra cosa?
SELECT TOP 10 customer_id, COUNT(DISTINCT customer_age) AS edades_distintas,
    COUNT(DISTINCT country) AS paises_distintos,
    COUNT(DISTINCT city) AS ciudades_distintas,
    COUNT(DISTINCT transaction_id) AS transacciones_distintas -- este tiene sentido que haya mas de 1
FROM stg_BankFraud.raw_BankFraud
GROUP BY customer_id
-- HAVING COUNT(DISTINCT customer_age) > 1
ORDER BY customer_id;

-- Cuantos son los casos de edades distintas?: 191518, casi el 20%
SELECT COUNT(*) AS clientes_con_edades_distintas
FROM (
    SELECT customer_id
    FROM stg_BankFraud.raw_BankFraud
    GROUP BY customer_id
    HAVING COUNT(DISTINCT customer_age) > 1
) AS clientes;

-- Cuantos son los casos de paises distintas?: 188110, casi el 20%
SELECT COUNT(*) AS paises_distintos
FROM (
    SELECT customer_id
    FROM stg_BankFraud.raw_BankFraud
    GROUP BY customer_id
    HAVING COUNT(DISTINCT country) > 1
) AS clientes;

-- Cuantos son los casos de ciudades distintas?: 191085, casi el 20%
SELECT COUNT(*) AS ciudades_distintas
FROM (
    SELECT customer_id
    FROM stg_BankFraud.raw_BankFraud
    GROUP BY customer_id
    HAVING COUNT(DISTINCT city) > 1
) AS clientes;

-- 16 Comprobar incosistencias entre la hora de transaccion y la hora del dia
-- No hay incosistencias, todas las horas coinciden
SELECT TOP 10 hour_of_day, transaction_time
FROM stg_BankFraud.raw_BankFraud

SELECT COUNT(*) AS horarios_inconsistentes
FROM stg_BankFraud.raw_BankFraud
WHERE hour_of_day != DATEPART(HOUR, transaction_time);



-- 17. Comprobar ciudades vs paises
-- Lo que se repite es que para cada pais (10) estan todas las ciudades (20)
-- Como lo corregimos? o descartamos por ejemplo el pais del analisis?
-- Hay 2 o 3 ciuades por cada pais igual
SELECT country, city, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
GROUP BY country, city
ORDER BY country;

-- Cuantos paises tiene asociada cada ciudad
SELECT city, COUNT(DISTINCT country) AS cantidad_paises
FROM stg_BankFraud.raw_BankFraud
GROUP BY city
ORDER BY COUNT(DISTINCT country)DESC;

-- Cuantas ciudades tiene asociado cada pais.
SELECT country, COUNT(DISTINCT city) AS cantidad_ciudades
FROM stg_BankFraud.raw_BankFraud
GROUP BY country
ORDER BY COUNT(DISTINCT city)  DESC;

-- Se hace el update
UPDATE stg_BankFraud.raw_BankFraud
SET country =
    CASE
        WHEN city IN ('melbourne', 'sydney')                THEN 'australia'
        WHEN city IN ('rio', 'sã£o paulo', 'são paulo')     THEN 'brazil'
        WHEN city IN ('toronto', 'vancouver')               THEN 'canada'
        WHEN city IN ('lyon', 'paris')                      THEN 'france'
        WHEN city IN ('berlin', 'munich')                   THEN 'germany'
        WHEN city IN ('delhi', 'mumbai')                    THEN 'india'
        WHEN city IN ('osaka', 'tokyo')                     THEN 'japan'
        WHEN city IN ('guadalajara', 'mexico city')         THEN 'mexico'
        WHEN city IN ('london', 'manchester')               THEN 'uk'
        WHEN city IN ('los angeles', 'new york')            THEN 'usa'
        ELSE country
    END;
-- Corroboramos, esta ok
SELECT country, city, COUNT(*) AS cantidad
FROM stg_BankFraud.raw_BankFraud
GROUP BY country, city
ORDER BY country;

------------------------------------------------------------------------------------------------------------------
-- 15. Tabla de perfilado de datos (data profiling).
-- No la hice yo, revisar y entender!!
-- Sirve para revisar la calidad de los datos antes de analizarlos o construir el modelo dimensional.
--  Perfilado de datos: nulos, vacíos y marcadores textuales

DECLARE @sql NVARCHAR(MAX);
SELECT @sql = STRING_AGG(
    CAST(
        'SELECT
            N''' + REPLACE(c.name, '''', '''''') + ''' AS columna,
            COUNT(*) AS cantidad_filas,
            SUM(CASE WHEN ' + QUOTENAME(c.name) +
                ' IS NULL THEN 1 ELSE 0 END) AS nulos, ' +

            CASE
                WHEN c.system_type_id IN (167, 175, 231, 239, 35, 99)
                THEN
                    'SUM(CASE WHEN ' + QUOTENAME(c.name) +
                    ' IS NOT NULL AND LEN(LTRIM(RTRIM(CONVERT(NVARCHAR(MAX), ' +
                    QUOTENAME(c.name) + ')))) = 0 THEN 1 ELSE 0 END)'
                ELSE '0'
            END + ' AS vacios, ' +

            CASE
                WHEN c.system_type_id IN (167, 175, 231, 239, 35, 99)
                THEN
                    'SUM(CASE WHEN UPPER(LTRIM(RTRIM(CONVERT(NVARCHAR(MAX), ' +
                    QUOTENAME(c.name) + ')))) IN
                    (''N/A'', ''NA'', ''NULL'', ''UNKNOWN'', ''SIN DATO'', ''NONE'', ''-'')
                    THEN 1 ELSE 0 END)'
                ELSE '0'
            END + ' AS marcadores_textuales

        FROM stg_BankFraud.raw_BankFraud'
        AS NVARCHAR(MAX)
    ),
    ' UNION ALL '
)
FROM sys.columns c
INNER JOIN sys.tables t
    ON c.object_id = t.object_id
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
WHERE s.name = 'stg_BankFraud'
  AND t.name = 'raw_BankFraud';

EXEC sp_executesql @sql;

-- Comentario consulta:
-- Con esto se quiere tener: Nombre de la variable, cantidad de filas, nulos, vacios y marcadores textuales (como 'N/A' o 'Unknown', none)
-- por eso aparece en el ultimo fraud type porque esta none