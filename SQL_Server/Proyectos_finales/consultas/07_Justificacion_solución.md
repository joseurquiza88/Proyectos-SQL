

Justificación de la solución
La solución se diseñó para responder al problema planteado para Aethel Capital Bank: la necesidad de integrar y organizar la información transaccional 
para analizar su comportamiento e identificar patrones asociados a las transacciones etiquetadas como fraude.

1. Carga y preparación de los datos. En primer lugar, se creó una tabla de staging con columnas de tipo VARCHAR para importar el archivo CSV original.
Luego, se revisaron los datos y se ajustaron los tipos y valores de las columnas mediante actualizaciones y transformaciones en SQL Server. 
Se realizó un análisis exploratorio de las variables para comprobar la incorporación del millón de registros y detectar valores nulos, duplicados, 
inconsistencias numéricas y categóricas, problemas en las fechas y horarios, y posibles incompatibilidades entre variables. 
Entre los problemas identificados se encontraron identificadores de clientes asociados a distintos atributos y una asignación incorrecta de países y ciudades. 
También se normalizaron las categorías y se revisaron los espacios y la coherencia de los valores. Estos controles permitieron preparar los datos antes de 
utilizarlos en el modelo analítico.

2. Diseño e implementación del modelo dimensional. Una vez revisada la calidad de los datos, se definió un modelo estrella compuesto por una tabla de hechos, 
FactTransaction, y dimensiones vinculadas con las fechas, los horarios, los clientes, las ubicaciones, las categorías comerciales, los métodos de pago y 
los dispositivos. Se establecieron las claves primarias y foráneas, los tipos de datos y las restricciones correspondientes. 
Después de crear y cargar las tablas, se realizaron nuevas verificaciones para comprobar la integridad de las relaciones y evitar duplicaciones o 
inconsistencias en los registros. Esta estructura permite relacionar la información y analizar las transacciones desde distintas perspectivas.

3. Transformación, consultas e indicadores para el análisis del negocio. Sobre el modelo implementado se desarrollaron consultas SQL organizadas en tres ejes:
- Distribución de las transacciones: se analizaron cantidades e importes por fecha, horario, ubicación, método de pago, dispositivo y categoría comercial, 
para comprender cómo se distribuye la actividad.
- Comparación entre transacciones etiquetadas como fraude y legítimas: se calcularon cantidades, importes y tasas de fraude, tanto generales como por 
distintos segmentos, para identificar diferencias entre ambos grupos.
- Relación con señales de riesgo: se compararon las tasas de fraude según los intentos fallidos, las operaciones internacionales, el horario y los cambios 
recientes de PIN, con el propósito de identificar características que merezcan un análisis adicional.

Este proceso permitió pasar de los registros originales a una estructura organizada y, posteriormente, a indicadores que responden a las preguntas planteadas. 
Por ejemplo, se identificaron diferencias entre categorías comerciales: joyería presentó una tasa de fraude del 8,70 % y el mayor importe asociado a transacciones 
etiquetadas como fraude, mientras que otras categorías mostraron tasas menores, pero también importes relevantes.


En conjunto, la solución permite integrar la información, controlar su calidad y obtener una visión más completa del comportamiento transaccional. 
Los resultados pueden contribuir a orientar la priorización de revisiones y a identificar patrones para investigar, sin reemplazar la evaluación humana. 
Dado que se trabaja con datos sintéticos, los hallazgos describen las relaciones presentes en el conjunto y no constituyen evidencia de fraude real 
ni demuestran relaciones causales.