# Análisis de transacciones bancarias con SQL Server

## Descripción del proyecto

Proyecto de **Data Analytics & Business Intelligence** desarrollado como
trabajo final de la primera etapa de SQL del grupo de trabajo de **Data
Analytics & BI de Blur Consulting**.

El proyecto utiliza SQL Server para preparar, validar, modelar y
analizar un dataset sintético de transacciones bancarias. El objetivo es
construir una base de datos analítica que permita explorar la
distribución de las operaciones, comparar las transacciones etiquetadas
como fraude con las etiquetadas como legítimas e identificar patrones
que puedan orientar análisis y revisiones posteriores.

> **Importante:** los datos son sintéticos y la variable `is_fraud` es
> una etiqueta generada dentro del dataset. Los resultados describen
> patrones presentes en esos datos; no constituyen evidencia de fraude
> real, pérdidas financieras reales ni relaciones causales.

## Objetivos

-   Aplicar SQL Server a un caso de negocio de análisis de
    transacciones.
-   Perfilar los datos e identificar problemas de calidad e
    inconsistencias.
-   Limpiar y preparar los datos antes de su carga analítica.
-   Diseñar e implementar un modelo dimensional en estrella.
-   Definir claves primarias y foráneas y comprobar la integridad entre
    las tablas.
-   Desarrollar consultas SQL para responder preguntas de negocio.
-   Calcular indicadores de volumen, importe y tasas asociadas a las
    transacciones etiquetadas como fraude.
-   Presentar hallazgos que permitan orientar análisis posteriores y la
    priorización de revisiones humanas.

## Herramientas y tecnologías

-   **SQL Server:** implementación de la base de datos, transformación,
    modelado y análisis.
-   **SQL:** consultas de exploración y validación, agregaciones,
    uniones entre tablas y cálculo de indicadores.
-   **Modelo dimensional:** esquema estrella con una tabla de hechos y
    siete dimensiones.

## Dataset

-   **Fuente:** [Bank Transaction Fraud Detection Dataset ---
    Kaggle](https://www.kaggle.com/datasets/nafiulislam490/bank-transaction-fraud-detection-dataset)
-   **Volumen:** 1.000.000 de transacciones.
-   **Período:** 2020--2024.
-   **Tipo de datos:** sintéticos.
-   **Variable de referencia:** `is_fraud`, que identifica las
    transacciones etiquetadas como fraude en el dataset.

El conjunto contiene información transaccional y atributos como fecha y
hora, cliente, ubicación, método de pago, dispositivo, categoría de
comercio, importe y algunas características de la operación, entre ellas
transacciones internacionales, intentos fallidos y cambios recientes de
PIN.

Los resultados dependen de cómo se generaron los datos y de las
relaciones incorporadas en el dataset sintético. Por eso, las tasas
observadas no deben interpretarse como estimaciones de fraude bancario
real.

## Problema de negocio

Una entidad financiera necesita una vista integrada de sus transacciones
para poder comparar la actividad desde distintas perspectivas: cuándo
ocurre, dónde, mediante qué método de pago y dispositivo, y en qué
categoría de comercio.

Sin un modelo analítico integrado, responder estas preguntas implica
consultar información desde diferentes campos y construir cálculos
repetidamente. El proyecto organiza los datos en un modelo dimensional y
desarrolla consultas que permiten explorar volúmenes, importes y
diferencias entre las transacciones según su etiqueta.

El análisis es **descriptivo**: busca identificar patrones dentro del
dataset y generar información que pueda ayudar a orientar revisiones
posteriores. No implementa un sistema automático de detección ni toma
decisiones sobre transacciones individuales.

## Proceso de trabajo

### 1. Carga inicial y exploración

Los datos se cargaron inicialmente en una tabla de staging. Durante la
importación se utilizó una estructura inicial flexible para facilitar la
incorporación del archivo y luego revisar los tipos y valores.

La exploración incluyó:

-   Revisión de la estructura y los tipos de datos.
-   Comprobación del volumen de registros.
-   Identificación de valores nulos y registros duplicados.
-   Revisión de valores únicos, categorías y consistencia de los campos.
-   Análisis de rangos y valores numéricos.
-   Validación de fechas, horas y atributos derivados.
-   Revisión de posibles inconsistencias entre variables relacionadas.

### 2. Perfilamiento y calidad de datos

Se realizaron controles para conocer la distribución y calidad de los
datos antes de utilizarlos en el modelo analítico.

Entre las validaciones se incluyeron:

-   Conteo de valores nulos.
-   Búsqueda de duplicados en el identificador de transacción.
-   Revisión de categorías y valores distintos.
-   Detección de inconsistencias entre campos.
-   Comprobación de rangos y valores esperados.
-   Verificación de la coherencia de indicadores relacionados con la
    hora de la transacción.

Durante este proceso se identificaron y corrigieron inconsistencias en
los datos. También se revisó la relación entre país y ciudad para evitar
asociaciones geográficas incorrectas en el análisis.

### 3. Diseño del modelo dimensional

Se diseñó un **modelo estrella** para separar las métricas
transaccionales de los atributos descriptivos utilizados para analizar
las operaciones.

El modelo incluye una tabla de hechos y siete dimensiones:

  -----------------------------------------------------------------------
  Tabla                               Función
  ----------------------------------- -----------------------------------
  `FactTransaction`                   Registra las transacciones y sus
                                      métricas y claves dimensionales.

  `DimDate`                           Permite analizar las operaciones
                                      por fecha y períodos calendario.

  `DimTime`                           Permite analizar las operaciones
                                      por hora y franja horaria.

  `DimCustomer`                       Permite identificar al cliente
                                      asociado a cada transacción.

  `DimLocation`                       Permite analizar las operaciones
                                      por país y ciudad.

  `DimMerchantCategory`               Permite agrupar las transacciones
                                      por categoría de comercio.

  `DimPaymentMethod`                  Permite comparar los distintos
                                      métodos de pago.

  `DimDeviceType`                     Permite analizar las operaciones
                                      según el tipo de dispositivo.
  -----------------------------------------------------------------------

Las dimensiones permiten filtrar y agrupar las transacciones desde
diferentes perspectivas, mientras que la tabla de hechos concentra los
registros que se analizan.

### 4. Implementación y carga

En SQL Server se crearon las tablas del modelo, se definieron las claves
primarias y foráneas y se cargaron los datos transformados.

Después de la carga se realizaron controles para verificar:

-   La cantidad de registros cargados.
-   La ausencia de duplicados en las claves revisadas.
-   La correspondencia entre las claves de la tabla de hechos y las
    dimensiones.
-   La consistencia de las relaciones del modelo.
-   La integridad de los datos utilizados en las consultas analíticas.

### 5. Consultas analíticas

Se desarrollaron consultas SQL para responder preguntas de negocio
mediante uniones entre tablas, agrupaciones, funciones de agregación y
cálculos de indicadores.

Los análisis se organizaron en tres ejes principales.

#### Eje 1. Distribución de las transacciones

-   ¿Cómo varía la cantidad de transacciones por fecha y hora?
-   ¿Cómo se distribuyen por país y ciudad?
-   ¿Qué participación tienen los métodos de pago y los dispositivos?
-   ¿Cómo se distribuyen las operaciones por categoría de comercio?
-   ¿Qué diferencias existen en el importe total y el importe promedio
    entre segmentos?

#### Eje 2. Comparación entre transacciones etiquetadas como fraude y legítimas

-   ¿Qué proporción de las transacciones está etiquetada como fraude?
-   ¿Qué participación tiene su importe en el importe total?
-   ¿Cómo varían las tasas según el método de pago, dispositivo,
    ubicación y categoría de comercio?
-   ¿Qué diferencias aparecen al cruzar método de pago y dispositivo?
-   ¿Cómo se distribuyen los importes de ambos grupos?
-   ¿Cómo varían las cantidades e importes por mes?

#### Eje 3. Características de las transacciones

-   ¿Cómo varía la tasa según la cantidad de intentos fallidos?
-   ¿Qué diferencias se observan entre operaciones nacionales e
    internacionales?
-   ¿Cómo se comparan las transacciones nocturnas con las realizadas en
    otros horarios?
-   ¿Qué diferencias aparecen entre operaciones con y sin cambios
    recientes de PIN?

Estas comparaciones son descriptivas. Una tasa más alta en un grupo no
demuestra que una característica cause fraude ni permite, por sí sola,
clasificar una transacción como fraudulenta.

## Principales resultados

Los siguientes resultados corresponden al dataset analizado y se deben
interpretar en el contexto de sus datos sintéticos.

### Distribución general

-   Las tarjetas de crédito y débito concentran, en conjunto, más del
    **60 % de las transacciones**.
-   Los dispositivos móviles representan aproximadamente el **44 % del
    volumen de operaciones** y cerca del **45 % del importe total**.
-   Las categorías de comercio tienen cantidades de transacciones
    relativamente similares, aunque su participación en el importe total
    varía.

### Volumen e importe

-   Electrónica, viajes y joyería representan, en conjunto, cerca del
    **63 % del importe total**.
-   Cada una de esas categorías aporta alrededor del 21 % del importe, a
    pesar de que las cantidades de transacciones por categoría son
    similares a las de otras categorías.
-   Esto muestra que el volumen de operaciones y su contribución
    monetaria son indicadores diferentes y conviene analizarlos por
    separado.

### Transacciones etiquetadas como fraude

-   Aproximadamente el **5 % de los registros** está etiquetado como
    fraude.
-   El importe asociado a esas transacciones representa aproximadamente
    el **6 % del importe total**.
-   La categoría **joyería** presenta una tasa del **8,70 %** y
    concentra alrededor de **4,04 millones** en importe de transacciones
    etiquetadas como fraude.
-   Las **extracciones en cajeros automáticos** presentan la tasa más
    alta entre las categorías analizadas, con **8,74 %**, pero un
    importe asociado a transacciones etiquetadas como fraude mucho
    menor, de aproximadamente **521 mil**.
-   El cruce entre tasa e importe permite observar que el segmento con
    la tasa más alta no necesariamente es el que concentra el mayor
    importe.

### Características de las operaciones

-   Las transacciones nocturnas muestran una tasa de etiquetas de fraude
    de alrededor del **8 %**, frente a cerca del **4 %** en las demás.
-   Las operaciones con cambios recientes de PIN presentan una tasa
    cercana al **8 %**, frente a alrededor del **5 %** en las
    operaciones sin ese atributo.
-   La tasa observada aumenta en los grupos con más intentos fallidos.

Estos patrones pueden servir para formular nuevas preguntas analíticas,
pero no prueban relaciones causales. Además, los resultados pueden
reflejar reglas o correlaciones incorporadas durante la generación del
dataset.

## Conclusiones

El proyecto permitió construir una base de datos analítica en SQL Server
y recorrer distintas etapas del trabajo con datos: carga, perfilamiento,
validación, transformación, modelado dimensional, control de integridad
y análisis mediante consultas SQL.

Los resultados muestran la importancia de combinar diferentes
indicadores. La cantidad de transacciones permite dimensionar la
actividad, mientras que los importes y las tasas aportan otras
perspectivas para comparar segmentos.

El modelo y las consultas constituyen una base para continuar explorando
los datos y presentar los indicadores de forma más accesible. El
siguiente paso del proyecto es llevar los análisis a **Power BI**,
mediante visualizaciones e indicadores interactivos.

## Estructura del repositorio

La estructura puede organizarse de la siguiente manera, ajustándola a
los archivos incluidos en el repositorio:

``` text
.
├── README.md
├── sql/
│   ├── 01_staging_y_carga.sql
│   ├── 02_perfilamiento_y_calidad.sql
│   ├── 03_modelo_dimensional.sql
│   ├── 04_carga_dimensiones_y_hechos.sql
│   ├── 05_validaciones.sql
│   └── 06_consultas_analiticas.sql
└── images/
    └── modelo_estrella.png
```

Los nombres anteriores son una propuesta de organización: deben
reemplazarse por los nombres reales de los archivos del proyecto. Si se
agregan capturas o un diagrama, se pueden ubicar en `images/` y enlazar
desde esta documentación.

## Cómo revisar el proyecto

1.  Descargar el dataset desde
    [Kaggle](https://www.kaggle.com/datasets/nafiulislam490/bank-transaction-fraud-detection-dataset),
    respetando sus condiciones de uso.
2.  Abrir SQL Server Management Studio y conectarse a una instancia de
    SQL Server.
3.  Crear la base de datos y los esquemas requeridos por los scripts.
4.  Ejecutar los scripts en el orden correspondiente: staging y carga
    inicial, perfilamiento y limpieza, creación del modelo, carga de
    dimensiones y hechos, validaciones y consultas analíticas.
5.  Revisar los resultados de las consultas y el diagrama del modelo
    estrella.

> Los pasos exactos de ejecución dependen de los nombres de las bases de
> datos, esquemas, archivos y rutas utilizados en la implementación. La
> estructura y los scripts del repositorio deben reflejar el proyecto
> real.

## Alcance y limitaciones

-   El dataset es sintético y no representa necesariamente el
    comportamiento de clientes o transacciones bancarias reales.
-   La etiqueta `is_fraud` se utiliza como variable de referencia para
    comparar grupos; no se valida de forma independiente si las
    transacciones serían fraudulentas en un entorno real.
-   Los importes asociados a transacciones etiquetadas como fraude **no
    equivalen a pérdidas financieras confirmadas**.
-   Las diferencias entre tasas son asociaciones descriptivas y no
    demuestran causalidad.
-   El proyecto no implementa un sistema de detección en producción ni
    automatiza decisiones sobre transacciones. Cualquier revisión
    posterior requeriría controles adicionales y evaluación humana.

## Próximos pasos

-   Construir un dashboard en Power BI a partir del modelo dimensional.
-   Presentar indicadores de volumen, importe y tasas por los
    principales segmentos.
-   Facilitar la exploración de patrones mediante filtros y
    visualizaciones interactivas.
-   Ampliar el análisis según las preguntas de negocio que surjan
    durante la revisión de los resultados.

------------------------------------------------------------------------

**Proyecto desarrollado como trabajo final de la etapa de SQL del grupo
de trabajo de Data Analytics & BI de Blur Consulting.**
