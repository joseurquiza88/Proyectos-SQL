# Diccionario de variables — Bank Transaction Fraud Detection Dataset

## 1. Contexto de uso
**Fuente:** [Bank Transaction Fraud Detection Dataset — Kaggle](https://www.kaggle.com/datasets/nafiulislam490/bank-transaction-fraud-detection-dataset). La ficha indica licencia CC0: Public Domain; comprobar la ficha vigente al entregar.

## 2. Convenciones

- Los tipos son propuestas para PostgreSQL, no tipos físicos confirmados del CSV.
- Los indicadores `is_*` y `pin_changed_recently` pueden cargarse primero como enteros y convertirse a `BOOLEAN` tras confirmar que sus valores son 0/1 o equivalentes.
- **PK** = clave primaria; **FK** = clave foránea; **NK** = clave natural de origen.
- La ubicación dimensional es una propuesta para el modelo estrella; se ajustará si el perfilado revela otra semántica.
- Los campos derivados o redundantes deben validarse contra su campo fuente.

## 3. Identificadores

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_id` | `VARCHAR(40)` | NK única en `FactTransaction` | Identificador único de la transacción; permite rastrear el registro de origen. | Revisar nulos y duplicados. No es una medida ni predictor. |
| `customer_id` | `VARCHAR(40)` | NK única en `DimCustomer`; FK mediante `customer_key` | Identificador del cliente asociado a la transacción; permite agrupar actividad simulada por cliente. | Revisar nulos, formato y consistencia de atributos. No identifica a una persona real. |

## 4. Tiempo

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_date` | `DATE` | FK `date_key` en hechos; `DimDate` | Fecha de la transacción; base de tendencias por día, mes, trimestre y año. | Validar conversión y rango 2020–2024 indicado por la ficha. |
| `transaction_time` | `TIME` | FK `time_key` en hechos; `DimTime` | Hora de la transacción; permite analizar actividad intradía. | Validar formato y concordancia con `hour_of_day`. |
| `hour_of_day` | `SMALLINT` | Atributo derivable de `DimTime` | Hora numérica del día, entre 0 y 23. | Verificar rango y compararlo con la hora extraída de `transaction_time`. |
| `is_weekend` | `BOOLEAN` | Atributo de `DimDate` | Indica sábado o domingo según la descripción. | Contrastar con `transaction_date`; conservar el valor original antes de corregir discrepancias. |
| `is_night_transaction` | `BOOLEAN` | Atributo de `DimTime` | Marca transacciones en el intervalo nocturno descrito (10 p. m.–6 a. m.). | Confirmar límites horarios y comparar con `transaction_time`. |

## 5. Cliente y cuenta

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `customer_age` | `SMALLINT` | `DimCustomer` | Edad atribuida al cliente; puede usarse para segmentación descriptiva. | Revisar nulos, rangos y consistencia por cliente. No inferir identidad real. |
| `credit_score` | `SMALLINT` | `DimCustomer` | Puntaje crediticio; la ficha indica 300–850. | Comparar rango declarado con valores observados. No tratarlo como evaluación crediticia real. |
| `account_age_years` | `NUMERIC(6,2)` | `DimCustomer` o atributo temporal del hecho | Antigüedad de la cuenta en años. | Validar no negatividad y estabilidad por cliente. Si varía en el tiempo, manejarlo como atributo histórico o del evento. |

## 6. Ubicación, comercio, pago y dispositivo

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `country` | `VARCHAR(80)` | `DimLocation` | País asociado al cliente según la ficha. | Normalizar etiquetas y confirmar si representa país del cliente o de la operación. |
| `city` | `VARCHAR(120)` | `DimLocation` | Ciudad asociada al registro. | Validar nulos y relación con país; no inferir residencia real ni coordenadas. |
| `merchant_category` | `VARCHAR(100)` | `DimMerchantCategory` | Categoría del comercio, como Grocery o Electronics según la ficha. | Estandarizar valores; no asumir que identifica un comercio individual. |
| `payment_method` | `VARCHAR(80)` | `DimPaymentMethod` | Método de pago, por ejemplo tarjeta de crédito, débito o móvil. | Confirmar dominio real y normalizar categorías. |
| `device_type` | `VARCHAR(80)` | `DimDeviceType` | Tipo de dispositivo o terminal, por ejemplo Mobile, Desktop, ATM o POS Terminal. | Confirmar valores. Es tipo de dispositivo, no identificador único. |

## 7. Importe y actividad transaccional

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `transaction_amount` | `NUMERIC(18,2)` | Medida en `FactTransaction` | Importe de la transacción. Permite calcular sumas, promedios, medianas y distribuciones por segmento. | Revisar nulos, negativos y extremos. La ficha no especifica moneda; no asignarla sin confirmación. |
| `account_balance` | `NUMERIC(18,2)` | Atributo/medida no aditiva en `FactTransaction` | Saldo de cuenta descrito como saldo actual. Puede analizarse como saldo observado asociado al registro. | No sumar entre transacciones como flujo monetario. Revisar si varía por cliente y si es comparable entre filas. |
| `num_prev_transactions` | `INTEGER` | Medida/atributo de evento en `FactTransaction` | Número total de transacciones previas según el campo. | Validar no negatividad y coherencia temporal. No asumir que puede reconstruirse con las filas del CSV. |
| `transaction_freq_monthly` | `NUMERIC(12,3)` | Medida/atributo de evento en `FactTransaction` | Frecuencia mensual promedio de transacciones. | Validar rango y definición del periodo; podría resumir historial externo al archivo. |

## 8. Señales de comportamiento y seguridad

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `distance_from_home_km` | `NUMERIC(12,3)` | Atributo de evento en `FactTransaction` | Distancia en kilómetros respecto de la ubicación del hogar del cliente. | Validar no negatividad y extremos. No equivale a geolocalización verificada. |
| `time_since_last_txn_hrs` | `NUMERIC(12,3)` | Atributo de evento en `FactTransaction` | Horas transcurridas desde la transacción anterior. | Validar no negatividad y coherencia temporal; confirmar tratamiento de la primera transacción por cliente. |
| `is_international` | `BOOLEAN` | Indicador en `FactTransaction` | Indica si la transacción está marcada como internacional. | Confirmar codificación. La definición operacional de “internacional” no está detallada. |
| `failed_attempts` | `INTEGER` | Medida/atributo de evento en `FactTransaction` | Intentos fallidos de acceso o transacción asociados al evento. | Validar no negatividad y rango; confirmar si son intentos de inicio de sesión, de pago o ambos. |
| `pin_changed_recently` | `BOOLEAN` | Indicador en `FactTransaction` | Indica si el PIN se cambió recientemente. | Confirmar codificación y ventana temporal de “recientemente”, que no está especificada. |

## 9. Etiquetas de resultado

| Variable | Tipo sugerido | Rol / ubicación | Descripción y uso | Validaciones y cautelas |
|---|---|---|---|---|
| `is_fraud` | `BOOLEAN` | Etiqueta en `FactTransaction` | 1 = fraude y 0 = legítimo según el dataset; permite comparar grupos dentro del conjunto. | Verificar dominio y porcentaje observado. Describirlo como etiqueta sintética, no fraude confirmado. |
| `fraud_type` | `VARCHAR(100)` | Resultado en `FactTransaction` o dimensión opcional `DimFraudType` | Tipo de fraude descrito para filas etiquetadas, con ejemplos como Phishing o Card Cloning. | Verificar dominio y nulos; validar compatibilidad con `is_fraud`. **No usar como predictor de `is_fraud`**, pues revela el resultado. |

## 10. Distribución sugerida en el modelo estrella

### `FactTransaction`

**Grano:** una fila por transacción del archivo.

- **PK:** `transaction_key` (clave sustituta).
- **NK única:** `transaction_id`.
- **FK:** `date_key`, `time_key`, `customer_key`, `location_key`, `merchant_category_key`, `payment_method_key`, `device_type_key`.
- **Medidas/atributos:** `transaction_amount`, `account_balance`, `num_prev_transactions`, `transaction_freq_monthly`, `distance_from_home_km`, `time_since_last_txn_hrs`, `is_international`, `failed_attempts`, `pin_changed_recently`, `is_fraud`, `fraud_type`.

### Dimensiones

| Dimensión | PK propuesta | NK / campos fuente principales |
|---|---|---|
| `DimDate` | `date_key` | `transaction_date`, `is_weekend`, año, trimestre, mes y día de semana |
| `DimTime` | `time_key` | `transaction_time`, `hour_of_day`, `is_night_transaction` |
| `DimCustomer` | `customer_key` | `customer_id`, `customer_age`, `credit_score`, `account_age_years` |
| `DimLocation` | `location_key` | `country`, `city` |
| `DimMerchantCategory` | `merchant_category_key` | `merchant_category` |
| `DimPaymentMethod` | `payment_method_key` | `payment_method` |
| `DimDeviceType` | `device_type_key` | `device_type` |

`fraud_type` puede permanecer como atributo de resultado en la tabla de hechos. Crear una dimensión aparte solo si el análisis necesita un catálogo separado. En ambos diseños, excluirlo de predictores de `is_fraud`.

## 11. Advertencias analíticas

1. **Naturaleza sintética:** describir hallazgos como patrones observados en datos simulados.
2. **Posible fuga de información:** la ficha dice que algunas señales se generaron correlacionadas con la probabilidad de fraude; no interpretar su asociación como causal ni independiente.
3. **Campos derivados:** validar `hour_of_day`, `is_weekend` e `is_night_transaction` desde fecha y hora.
4. **Etiqueta y tipo:** `fraud_type` contiene información del resultado y debe excluirse de cualquier predicción de `is_fraud`.
5. **Definiciones ausentes:** no asumir moneda, ventana de “recientemente” ni definiciones operativas no documentadas.
6. **Esquema:** el diccionario suministrado enumera 26 variables, incluido `fraud_type`; verificar encabezados y contenido del CSV antes de cerrar la base.
