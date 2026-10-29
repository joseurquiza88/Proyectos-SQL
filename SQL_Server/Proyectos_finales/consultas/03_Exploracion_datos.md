
--  Resumen:  03. Exploración de la tabla inicial para ver inconsistencias, nulos, faltantes (EDA)


01. Tipos de datos y muestra inicial
Se revisaron los tipos de datos definidos para cada columna y una muestra de los registros para conocer la estructura de la tabla. 
La consulta permite inspeccionar los datos, aunque la adecuación de cada tipo debe evaluarse según el uso de la columna.

02. Cantidad de valores distintos
Se calculó la cantidad de valores diferentes por columna para conocer la variedad de los datos e identificar posibles particularidades en las variables categóricas y numéricas.

03. Identificadores y registros duplicados
- No se encontraron identificadores transaction_id repetidos.
- También se buscaron registros con todos los atributos iguales, excepto transaction_id y no se encontraron duplicados. 


04. Valores nulos, vacíos y marcadores textuales
- Nulos: no se encontraron valores NULL en las columnas revisadas.
- Vacíos: se revisaron las columnas de texto para detectar cadenas vacías. Si, hay algunos con espacios entre medio, se dejaron igual.
- Marcadores textuales: se identificaron como posibles marcadores de datos faltantes. Se observó el valor None en fraud_type, pero representa la ausencia de fraude y por lo que se decidio por ahora dejarlo de esa forma.

05. Período
Se verificó el período de las transacciones. Se encontro que el periodo esta entre 2020 y 2024 como figura en kaggle.

06. Valores únicos de las variables categóricas
Se identificaron 10 países, 20 ciudades, 15 categorías de comercio, 6 métodos de pago, 5 tipos de dispositivos y 7 valores distintos en fraud_type.

07. Variables binarias y rangos numéricos
Se comprobó que las variables binarias (is_weekend, is_night_transaction, is_international, pin_changed_recently e is_fraud) presentaran valores 0 y 1. 

08. Valores minimos y maximos de las variables numericas
Los resultados de estas comprobaciones deben interpretarse según las cantidades devueltas por las consultas. La inspección de mínimos y máximos, por sí sola, no permite descartar todos los valores inválidos.

09. Revisión de la variable is_night_transaction
Se comprobo que todos los registros coincida, con la hora, entre 22:00 y las 06:00 (inclusive) es nocturno is_night_transaction = 1

10. Revisión de la variable credit_score.
Se comprobo que todos los registros coincidan con el rango mencionado en kaggle que estuvieran entre 300 y 850

11. Revisión de la variable hour_of_day este entre 0-23
Se comprobo que todos los registros coincidan con el rango entre 0-23

12. Consistencia y normalización de las categorías de texto
Se normalizaron las columnas country, city, merchant_category, payment_method, device_type y fraud_type, convirtiendo los textos a minúsculas y eliminando los espacios al principio y al final. 
El objetivo fue unificar el formato de los valores para facilitar su análisis.

13. Consistencia entre is_fraud y fraud_type
La distribución de ambas variables mostró una correspondencia entre la etiqueta de fraude y los tipos registrados: los casos con is_fraud = 0 se asocian a la ausencia de fraude, 
mientras que los casos con is_fraud = 1 presentan distintos tipos de fraude. No se identificaron inconsistencias en la revisión realizada.

14. Consistencia entre el método de pago y el tipo de fraude
Se analizaron las combinaciones de payment_method y fraud_type. Se identificaron algunas asociaciones que conviene revisar, como:
- bank transfer con card cloning.
- crypto con card cloning y friendly fraud.
- cheque con card cloning.
Estas combinaciones resultan llamativas, pero no se pueden considerar errores confirmados sin conocer mejor las definiciones y reglas de generación del dataset.
Se deberia profundizar en el tema

15. Consistencia de los atributos asociados a customer_id
Se comprobó que un mismo cliente puede tener múltiples transacciones, lo cual es esperable. 
Sin embargo, se encontraron clientes con distintos valores de edad, país y ciudad.
Esto no debería ser asi ya que el dataset menciona es: Unique customer identifier
Los conteos obtenidos fueron:
- 191.518 clientes con más de una edad registrada.
- 188.110 clientes asociados a más de un país 
- 191.085 clientes asociados a más de una ciudad.
Estos resultados indican posibles inconsistencias en los atributos asociados a los clientes. 
Para afirmar que representan casi el 20 % de los clientes, se debe calcular el porcentaje sobre el total de customer_id distintos. 
Las diferencias de edad son especialmente relevantes, mientras que los cambios de país o ciudad podrían depender de si esos campos representan la ubicación del cliente o la de cada transacción.

16. Consistencia entre transaction_time y hour_of_day
Se comparó la hora extraída de transaction_time con el valor de hour_of_day. 
No se encontraron inconsistencias entre ambas variables.

17. Consistencia entre países y ciudades
Se analizaron las combinaciones de country y city. Se observó que las ciudades aparecen asociadas a distintos países, por lo que se debe comprobar si todas las ciudades están presentes en todos los países.
Este patrón podría indicar una inconsistencia geográfica del dataset. 
Se hizo un update y se cambio

Conclusión general
La exploración permitió revisar la estructura, los valores faltantes, los duplicados, los rangos y la consistencia entre distintas variables. 
Se normalizaron las categorías de texto y se identificaron posibles problemas en los atributos de los clientes y en las relaciones entre países y ciudades. 
También se detectaron algunas combinaciones de métodos de pago y tipos de fraude que requieren mayor investigación.

