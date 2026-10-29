

-------------------------------------------------------------------------------------------------------------------------
--  05. Consultas que permitan preparar los datos, relacionar tablas y generar información útil para el negocio.
-- Cálculos e indicadores
-------------------------------------------------------------------------------------------------------------------------


USE BankFraud;
GO
-- Tablas
SELECT * FROM dw_BankFraud.DimDate 
SELECT * FROM dw_BankFraud.DimTime 
SELECT * FROM dw_BankFraud.DimCustomer
SELECT * FROM dw_BankFraud.DimLocation
SELECT * FROM dw_BankFraud.DimMerchantCategory
SELECT * FROM dw_BankFraud.DimPaymentMethod 
SELECT * FROM dw_BankFraud.DimDeviceType
SELECT * FROM dw_BankFraud.FactTransaction

-- Tema 01 Distribución de las transacciones
-- ¿Cómo se distribuyen el número y el importe de las transacciones por fecha, 
-- hora, país, ciudad, método de pago, dispositivo y categoría de comercio?

-- 1.1 Cantidad de transacciones por fecha. ¿Cómo varía la cantidad de transacciones de un día a otro?
-- Hay entre 477 y 618 transacciones diarias
SELECT dd.full_date, COUNT(ft.transaction_id) AS cantidad_transacciones_dia
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDate dd
ON ft.date_key = dd.date_key
GROUP BY dd.full_date
-- ORDER BY dd.full_date;
ORDER BY COUNT(ft.transaction_id) ASC; 

-- Calculo el dia con mayores, menores transacciones, y el promedio diario
-- Hay entre 477 y 618 tranascciones diarias
WITH TransaccionesDiarias AS (
    SELECT
        dd.full_date,
        COUNT(ft.transaction_id) AS cantidad_transacciones_dia
    FROM dw_BankFraud.FactTransaction ft
    INNER JOIN dw_BankFraud.DimDate dd
        ON ft.date_key = dd.date_key
    GROUP BY dd.full_date
)
SELECT
    MAX(cantidad_transacciones_dia) AS max_transacciones_dia,
    MIN(cantidad_transacciones_dia) AS min_transacciones_dia,
    ROUND(AVG(CAST(cantidad_transacciones_dia AS DECIMAL(10,2))),2)
        AS promedio_transacciones_dia
FROM TransaccionesDiarias;


-- 1.2 Cantidad de transacciones por hora. En qué horarios se registra mayor actividad transaccional?
-- el volumen de transacciones está distribuido de manera relativamente uniforme a lo largo del día, 41 mil para las 24 hs
SELECT dt.hour_of_day, COUNT(ft.transaction_id) AS cantidad_transacciones_hora
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimTime dt
ON ft.time_key = dt.time_key
GROUP BY dt.hour_of_day
ORDER BY dt.hour_of_day;


-- 1.3 Cantidad por país y ciudad. Cómo se distribuyen las transacciones geográficamente?
-- el volumen de operaciones está bastante distribuido geográficamente. Menores transacciones: Londres: 49613 y mayor transacciones Rio:50365

SELECT dl.country, dl.city, COUNT(ft.transaction_id) AS cantidad_transacciones_ciudad
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimLocation dl
ON ft.location_key = dl.location_key
GROUP BY dl.country, dl.city
ORDER BY cantidad_transacciones_ciudad;
;


-- 1.4 Cantidad transacciones por método de pago. Qué métodos de pago concentran mayor volumen de operaciones?

-- Las tarjetas se llevan mas del 60% de las transacciones con 35% para tarjetas de credito y debito 30%. Mientras que crypto t cheques son las que tienen menos transacciones
SELECT dpm.payment_method, COUNT(ft.transaction_id) AS cantidad_transacciones_MetodoPago,
CAST(COUNT(ft.transaction_id) * 100.0 / SUM(COUNT(ft.transaction_id)) OVER () AS DECIMAL(5,2)) AS porcentaje_transacciones
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
ON ft.payment_method_key = dpm.payment_method_key
GROUP BY dpm.payment_method
ORDER BY COUNT(ft.transaction_id) DESC;


-----------
-- 1.5 Cantidad transacciones por dispositivo. Desde qué dispositivos se realizan las transacciones?
-- Los dispositivos móviles representan el 44% de las operaciones, es el que tiene mayor participación
SELECT ddt.device_type, COUNT(ft.transaction_id) AS cantidad_transacciones_Dispositivo,
CAST(COUNT(ft.transaction_id) * 100.0 / SUM(COUNT(ft.transaction_id)) OVER() AS DECIMAL(5,2)) AS porcentaje_transacciones
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDeviceType ddt
ON ft.device_type_key = ddt.device_type_key
GROUP BY ddt.device_type
ORDER BY COUNT(ft.transaction_id) DESC;


-----------
-- 1.6 Cantidad transacciones por categorias
-- l volumen de transacciones se distribuye de manera muy uniforme entre ellas. El rango esta entre 6.63% y 6.72
SELECT dmc.merchant_category, COUNT(ft.transaction_id) AS cantidad_transacciones_categorias,
CAST(COUNT(ft.transaction_id) * 100.0 / SUM(COUNT(ft.transaction_id)) OVER() AS DECIMAL(5,2)) AS porcentaje_transacciones
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimMerchantCategory dmc
ON ft.merchant_category_key = dmc.merchant_category_key
GROUP BY dmc.merchant_category
ORDER BY COUNT(ft.transaction_id) DESC;


-- 1.7 Importe total y promedio por país y ciudad. Cómo se distribuye el dinero transaccionado geográficamente?
-- Estan bastante uniforme los importes por ciudades tanto el total (rango: 10151760-10600732) como el importe promedio
SELECT dl.country, dl.city,
    COUNT(ft.transaction_id) AS cantidad_transacciones,
    SUM(ft.transaction_amount) AS importe_total,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimLocation dl
    ON ft.location_key = dl.location_key
GROUP BY dl.country, dl.city
ORDER BY importe_total DESC;

-- 1.8 Importe por dispositivo. Qué dispositivos concentran mayor importe transaccionado y cuál es el importe promedio de sus operaciones?
-- El tipo mobile continua siendo el de mayor monto (45% del monto) seguido por desktop 25%
SELECT ddt.device_type, 
    COUNT(ft.transaction_id) AS cantidad_transacciones,
    SUM(ft.transaction_amount) AS importe_total,
    AVG (ft.transaction_amount)AS importe_promedio,
    CAST(SUM(ft.transaction_amount) * 100.0 / SUM(SUM(ft.transaction_amount)) OVER() AS DECIMAL(5,2)) AS porcentaje_monto

FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDeviceType ddt
ON ft.device_type_key = ddt.device_type_key
GROUP BY ddt.device_type
ORDER BY SUM(ft.transaction_amount) DESC;


-- 1.9 Importe por Metodo de pago. Qué métodos de pago concentran mayor importe de las transacciones?
-- Las tarjetas de crédito(34%) y débito(30) concentran una proporción importante del importe total, en línea con su participación en la cantidad de transacciones.
SELECT * FROM dw_BankFraud.DimPaymentMethod 
SELECT dpm.payment_method, COUNT(ft.transaction_id) AS cantidad_transacciones,
SUM(ft.transaction_amount) AS importe_total,
AVG(ft.transaction_amount) AS importe_promedio,
CAST(SUM(ft.transaction_amount)* 100.0 / SUM(SUM(ft.transaction_amount)) OVER() AS DECIMAL(5,2)) AS porcentaje_monto
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
ON ft.payment_method_key = dpm.payment_method_key
GROUP BY dpm.payment_method
ORDER BY CAST(SUM(ft.transaction_amount)* 100.0 / SUM(SUM(ft.transaction_amount)) OVER() AS DECIMAL(5,2)) DESC;

-- 1.10 Importe por categoría. Qué categorías concentran mayor importe y cuáles tienen operaciones de mayor valor promedio?
-- Aca si se ve la diferencia entre las cateigorias, si bien tienen una cantidad de transacciones similares, el monto si difiere.
-- Las categorias de electronica, travel y jelwery son las principales. Pero entre ellas estmaos hablando de 21% cada una.
-- Mientras que el resto es uniforme de 3% del monto total de las transacciones.
-- las categorías pueden tener cantidades similares de operaciones, pero participar de manera muy diferente en el importe total.
SELECT * FROM dw_BankFraud.DimMerchantCategory
SELECT TOP 5 * FROM dw_BankFraud.FactTransaction 

SELECT dmc.merchant_category,
COUNT(ft.transaction_id) AS cantidad_transacciones,
SUM(ft.transaction_amount) AS importe_total,
AVG(ft.transaction_amount) AS importe_promedio,
CAST(SUM(ft.transaction_amount)* 100.0 / SUM(SUM(ft.transaction_amount)) OVER() AS DECIMAL(5,2)) AS porcentaje_monto
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimMerchantCategory dmc
ON ft.merchant_category_key = dmc.merchant_category_key
GROUP BY dmc.merchant_category
ORDER BY SUM(ft.transaction_amount) DESC


-------------------------------------------------------------------------------------------------------------------------
-- Tema 02 Comparación entre transacciones consideradas como fraudes vs legitimas
-- ¿Qué diferencias descriptivas hay entre las transacciones etiquetadas como fraude y las etiquetadas como legítimas?

SELECT * FROM dw_BankFraud.DimDate 
SELECT * FROM dw_BankFraud.DimTime 
SELECT * FROM dw_BankFraud.DimCustomer
SELECT * FROM dw_BankFraud.DimLocation
SELECT * FROM dw_BankFraud.DimMerchantCategory
SELECT * FROM dw_BankFraud.DimPaymentMethod 
SELECT * FROM dw_BankFraud.DimDeviceType
SELECT * FROM dw_BankFraud.FactTransaction

-- 2.1 Cantidad de transacciones etiquetadas como fraude y legítimas.
-- Solo el 5% de las transacciones son fraudulentas, pero a cuanto equivale en monto, mucho/poco del total?. Cuanto pierde el negocio por estas transacciones?
SELECT 'Legitima' AS tipo,COUNT(transaction_id) AS cantidad_transacciones_legitimas,
ROUND(COUNT(transaction_id) * 100.0 /  (SELECT COUNT(*) FROM dw_BankFraud.FactTransaction),2) AS porcentaje
FROM dw_BankFraud.FactTransaction
WHERE is_fraud = 0
UNION ALL
SELECT 'Fraude', COUNT(transaction_id) AS cantidad_transacciones_fraude, 
ROUND(COUNT(transaction_id) * 100.0 /  (SELECT COUNT(*) FROM dw_BankFraud.FactTransaction),2) -- porque no sale el round?
FROM dw_BankFraud.FactTransaction
WHERE is_fraud = 1

-- 2.2 Importe total de cada grupo. qué proporción del importe total está asociada a transacciones etiquetadas como fraude/legitima?
-- Es un 6% del monto total, es mucho/poco lo que pierde el negocio? 
SELECT 'Legitima' AS tipo, SUM(transaction_amount) AS monto_total_legitima,
ROUND(SUM(transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction
WHERE is_fraud = 0
UNION ALL
SELECT 'Fraude', SUM(transaction_amount) AS monto_total_fraude,
ROUND(SUM(transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction
WHERE is_fraud = 1


-- 2.3 Distribución del importe total por método de pago y clasificación
-- El porcentaje representa la participación en el importe total de todas las transacciones
-- Vemos que la mayor parte de las transacciones fraudulentas se hace con tarjetas debito y credito que a su vez es el metodo mas utilizado para las transacciones (60% del total)

SELECT * FROM dw_BankFraud.DimPaymentMethod 

SELECT 'Legitima' AS tipo, dpm.payment_method, SUM(ft.transaction_amount) AS monto_total,
ROUND(SUM(ft.transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
ON ft.payment_method_key = dpm.payment_method_key
WHERE ft.is_fraud = 0
GROUP BY dpm.payment_method
-- ORDER BY porcentaje DESC;

UNION ALL
SELECT 'Fraude' AS tipo, dpm.payment_method, SUM(ft.transaction_amount) AS monto_total,
ROUND(SUM(ft.transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
ON ft.payment_method_key = dpm.payment_method_key
WHERE ft.is_fraud = 1
GROUP BY dpm.payment_method
ORDER BY porcentaje DESC;


-- 2.4 Distribución del importe total por Dispositivo y clasificación
-- Mobile concentra la mayor proporción del importe de las transacciones etiquetadas como fraude, 
-- seguido por Desktop. Sin embargo, Mobile también es el dispositivo con mayor volumen de transacciones, 
-- por lo que esta distribución no implica necesariamente que presente una mayor tasa de fraude.
SELECT 'Legitima' AS tipo, ddt.device_type, SUM(ft.transaction_amount) AS monto_total,
ROUND(SUM(ft.transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDeviceType ddt
ON ft.device_type_key = ddt.device_type_key
WHERE ft.is_fraud = 0
GROUP BY ddt.device_type
UNION ALL
SELECT 'Fraude' AS tipo, ddt.device_type, SUM(ft.transaction_amount) AS monto_total,
ROUND(SUM(ft.transaction_amount) * 100.0 / (SELECT SUM(transaction_amount) FROM dw_BankFraud.FactTransaction), 2) AS porcentaje
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDeviceType ddt
ON ft.device_type_key = ddt.device_type_key
WHERE ft.is_fraud = 1
GROUP BY ddt.device_type
ORDER BY porcentaje DESC;


-- 2.5 Tasa de fraude por método de pago
-- Lo anterior se hace sobre el total pero si consideramos el total por metodo seria:
-- que en promedio el 5% de las transacciones por metodo de pago es fraudulenta.
SELECT dpm.payment_method, COUNT(*) AS cantidad_transacciones, SUM(ft.is_fraud) AS cantidad_fraudes,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    SUM(ft.transaction_amount) AS importe_total,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
    ON ft.payment_method_key = dpm.payment_method_key
GROUP BY dpm.payment_method
ORDER BY importe_total DESC;


-- 2.6 Las transacciones etiquetadas como fraude tienen importes más altos
-- El importe maximo de fraude fue de 14767.61, mientras que el maximo de legitima fue de 46129.60
-- En ambos casos el minimo fue de 1
-- Igualmente esto no permite concluir que las transacciones fraudulentas tengan importes más altos en general.
-- Que nos quiere decir esto?, se puede hacer una especie de varios bins?
SELECT
    CASE WHEN is_fraud = 1 THEN 'Fraude' ELSE 'Legítima' END AS tipo,
    COUNT(*) AS cantidad_transacciones,
    AVG(transaction_amount) AS importe_promedio,
    MIN(transaction_amount) AS importe_minimo,
    MAX(transaction_amount) AS importe_maximo,
    SUM(transaction_amount) AS importe_total
FROM dw_BankFraud.FactTransaction
GROUP BY is_fraud;



-- 2.7 Fraudes por país. Qué países concentran más transacciones etiquetadas como fraude?
-- No hay grandes diferencias entre los paises con respecto a la tasa de fraude, todos estan entre 5-6% de fraude
SELECT dl.country, COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    SUM(CASE WHEN ft.is_fraud = 1 THEN ft.transaction_amount ELSE 0 END) AS importe_fraude
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimLocation dl
    ON ft.location_key = dl.location_key
GROUP BY dl.country
ORDER BY tasa_fraude_pct DESC;


-- 2.8 Tasa de fraude por método de pago y dispositivo 
-- Al cruzar método de pago y dispositivo, las tasas de fraude estan entre 5% y 6%.
-- Crypto + ATM presenta la tasa más alta, mientras que cheque + ATM presenta la más baja.
-- Sin embargo, las diferencias son relativamente acotadas. Las combinaciones con tarjeta y dispositivo móvil concentran
-- una gran cantidad de transacciones y de fraudes en términos absolutos, pero no presentan las tasas más elevadas.

SELECT dpm.payment_method, ddt.device_type,
    COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimPaymentMethod dpm
    ON ft.payment_method_key = dpm.payment_method_key
INNER JOIN dw_BankFraud.DimDeviceType ddt
    ON ft.device_type_key = ddt.device_type_key
GROUP BY dpm.payment_method, ddt.device_type
ORDER BY tasa_fraude_pct DESC; -- dpm.payment_method, cantidad_transacciones DESC;


-- 2.9 Evolución mensual del importe de las transacciones etiquetadas como fraude
-- La cantidad de transacciones fraudulentas no tiene alta variabilidad . Mientras que los importes mensuales si. El mes con mayores transacciones fraudulentas fue en 10/2023
-- Seguido por 1/2021 y 11-9/2020. No se nota un patron mensual o naul con respecto a las epocas
SELECT dd.year, dd.month, COUNT(*) AS cantidad_transacciones_fraudulentas,
    SUM(ft.transaction_amount) AS importe_total_fraudulento
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimDate dd
    ON ft.date_key = dd.date_key
WHERE ft.is_fraud = 1
GROUP BY dd.year, dd.month
-- ORDER BY dd.year, dd.month;
ORDER BY importe_total_fraudulento DESC


-- 2.10 Transacciones fraudulentas por categoría. Qué categoría tiene la mayor cantidad de transacciones etiquetadas como fraude?
-- Las categorias que tienen una tasa de fraude mas alta son atm withdrawal, jewelry crypto exchange con 8% cada una, el resto entre 4-5%
-- Como todas tienen cantidades de operaciones similares, la diferencia en las tasas no parece explicarse simplemente por un mayor volumen de transacciones.
SELECT * FROM dw_BankFraud.DimMerchantCategory
SELECT mc.merchant_category, COUNT(*) AS total_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS transacciones_fraude,
    ROUND(100.0 * SUM(CAST(ft.is_fraud AS INT)) / COUNT(*), 2) AS tasa_fraude_pct
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimMerchantCategory mc
    ON ft.merchant_category_key = mc.merchant_category_key
GROUP BY mc.merchant_category
ORDER BY tasa_fraude_pct DESC;

-- 2.11 Transacciones fraudulentas por categoría calculando el monto
-- Las categorías con mayor tasa de fraude no son necesariamente las que concentran el mayor importe asociado a esas transacciones.
-- Joyería lidera con 4.035.049,55, y una tasa de fraude del 8.70 %.
-- Electrónica ocupa el segundo lugar, con 2369763.87, seguida de viajes, con 2293838,82. Ambas tienen tasas de fraude cercanas al 4,7–4,8 %.
-- Crypto exchange y ATM withdrawal, pese a registrar las tasas más altas (8.65 % y 8.74%), presentan importes asociados a fraude de aproximadamente 524.027 y 521.037.

SELECT mc.merchant_category, SUM(CASE WHEN ft.is_fraud = 1 THEN ft.transaction_amount ELSE 0 END) AS importe_fraude,
    SUM(CASE WHEN ft.is_fraud = 0 THEN ft.transaction_amount ELSE 0 END) AS importe_legitimo,
    SUM(ft.transaction_amount) AS importe_total
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimMerchantCategory mc
    ON ft.merchant_category_key = mc.merchant_category_key
GROUP BY mc.merchant_category
ORDER BY importe_fraude DESC;




-------------------------------------------------------------------------------------------------------------------------
-- Tema 03 Relación con las señales de riesgo
-- ¿Cómo se relacionan, dentro del conjunto, las etiquetas con los intentos fallidos, las operaciones internacionales, 
-- el horario, la distancia y los cambios recientes de PIN?
SELECT * FROM dw_BankFraud.DimDate 
SELECT * FROM dw_BankFraud.DimTime 
SELECT * FROM dw_BankFraud.DimCustomer
SELECT * FROM dw_BankFraud.DimLocation
SELECT * FROM dw_BankFraud.DimMerchantCategory
SELECT * FROM dw_BankFraud.DimPaymentMethod 
SELECT * FROM dw_BankFraud.DimDeviceType
SELECT TOP 10 * FROM dw_BankFraud.FactTransaction

-- 3.1 Relación entre intentos fallidos y transacciones etiquetadas como fraude. Cómo varía la tasa de fraude según la cantidad de intentos fallidos registrados?
-- Se ve que tasa de fraude aumenta al aumentar los intentos fallidos, Despues de 2 intentos ya hay posibilidades de que sea fraude.
-- Los grupos con más intentos podrían ser relevantes para priorizar revisiones
-- Pero eso no quita que una transacción puede estar etiquetada como fraude incluso con cero intentos fallidos,

SELECT ft.failed_attempts AS intentos_fallidos, COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    COUNT(*) - SUM(CAST(ft.is_fraud AS INT)) AS cantidad_legitimas,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
GROUP BY ft.failed_attempts
ORDER BY ft.failed_attempts;


-- 3.2 Operaciones internacionales frente a nacionales. Las transacciones internacionales presentan una tasa de fraude diferente de las nacionales?
-- 3.2 Comparación entre transacciones internacionales y nacionales
-- Las operaciones internacionales presentan una tasa de fraude ligeramente superior a las nacionales, mientras que las nacionales concentran un importe total mayor.
SELECT
    CASE WHEN ft.is_international = 1 THEN 'Internacional' ELSE 'Nacional' END AS tipo_transaccion,
    COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    COUNT(*) - SUM(CAST(ft.is_fraud AS INT)) AS cantidad_legitimas,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    SUM(ft.transaction_amount) AS importe_total,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
GROUP BY ft.is_international
ORDER BY tasa_fraude_pct DESC;


-- 3.3 Transacciones nocturnas frente al resto. La tasa de fraude difiere entre las transacciones nocturnas y las realizadas durante el resto del día?
-- 3.3 Comparación entre transacciones nocturnas y no nocturnas
-- Las transacciones nocturnas presentan una tasa de fraude superior a la de las transacciones no nocturnas (8% frente a 4%).
-- Esta diferencia descriptiva puede ser relevante para priorizar revisiones.
SELECT CASE WHEN dt.is_night_transaction = 1 THEN 'Nocturna' ELSE 'No nocturna' END AS periodo,
    COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
INNER JOIN dw_BankFraud.DimTime dt
    ON ft.time_key = dt.time_key
GROUP BY dt.is_night_transaction
ORDER BY tasa_fraude_pct DESC;

-- 3.4 Cambios recientes de PIN. Las transacciones con un cambio reciente de PIN presentan una tasa de fraude diferente?
-- Las transacciones con cambios recientes de PIN presentan una tasa de fraude superior a las transacciones sin cambios recientes (8% frente a 5%).
-- La diferencia identifica una asociación descriptiva que puede analizarse junto con otras señales de riesgo.
SELECT
    CASE WHEN ft.pin_changed_recently = 1 THEN 'Cambio reciente' ELSE 'Sin cambio reciente' END AS estado_pin,
    COUNT(*) AS cantidad_transacciones,
    SUM(CAST(ft.is_fraud AS INT)) AS cantidad_fraudes,
    COUNT(*) - SUM(CAST(ft.is_fraud AS INT)) AS cantidad_legitimas,
    CAST(SUM(CAST(ft.is_fraud AS INT)) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS tasa_fraude_pct,
    SUM(ft.transaction_amount) AS importe_total,
    AVG(ft.transaction_amount) AS importe_promedio
FROM dw_BankFraud.FactTransaction ft
GROUP BY ft.pin_changed_recently
ORDER BY tasa_fraude_pct DESC;
-------------------------------------------------------------------------------------------------------------------------
-- Tema 04 Clientes y segmentos con más actividad
-- ¿Qué clientes o segmentos concentran más actividad o importe, y qué cambia al comparar cantidades absolutas con promedios y porcentajes?

-- 4.1 Clientes con mayor cantidad de transacciones.
-- 4.2 Clientes con mayor importe acumulado.
-- 4.3 Importe promedio por cliente.
-- 4.4 Comparación de cantidades absolutas con porcentajes.

-------------------------------------------------------------------------------------------------------------------------
-- Tema 07 Vistas
-- 7.1 vw_ResumenTransacciones: cantidades e importes por fecha y principales dimensiones.
-- 7.2 vw_IndicadoresFraude: cantidades, importes y tasas de fraude.
-- 7.3 vw_SenalesFraude: comparación de señales entre los grupos etiquetados.
-- 7.4 vw_ActividadClientes: volumen e importe por cliente

-- Se hace fraude con montos mas altos o mas bajos
-- que categorai tieene mas gfraude
que pais tiene mas graude