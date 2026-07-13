
--                            LIMPIEZA DE DATOS SQL
-- Creacion de la base de datos para trabajar
 CREATE DATABASE IF NOT EXISTS clean;
 use clean;
 #Es una funcion que vamos a usar seguido en el proyecto
 SELECT * FROM limpieza;
 -- Hacemos un Store Procedure
DELIMITER //
CREATE PROCEDURE limp()
BEGIN
	 SELECT * FROM limpieza;
END //
DELIMITER ;
-- Llamar al procedimiento
CALL limp();

-- Renombrar columnas con nombres que tienen caracteres especiales
ALTER TABLE limpieza CHANGE COLUMN `ï»¿Id?empleado` id_emp VARCHAR (20);
ALTER TABLE limpieza CHANGE COLUMN `gÃ©nero` gender VARCHAR (20);

-- Elementos duplicados
SELECT id_emp, COUNT(*) AS cantidad_duplicados
FROM limpieza
GROUP BY id_emp
HAVING COUNT(*) > 1; 

-- Hacer subconsulta para que nos cuente cuantos registros hay
SELECT COUNT(*) AS cantidad_duplicados
FROM (
	SELECT id_emp, COUNT(*) AS cantidad_duplicados
	FROM limpieza
	GROUP BY id_emp
	HAVING COUNT(*) > 1 
) AS subquery;


-- Remover los valores duplicados (n=9)
-- Primero cambiamos el nombre a la tabla
RENAME TABLE limpieza to conDuplicados;

-- Crear tabla sin datos duplicados pero es temporal
CREATE TEMPORARY TABLE temp_limpieza;
SELECT DISTINCT * FROM conDuplicados;

-- Corroboramos que no esten los duplicados
SELECT COUNT(*) AS original FROM conDuplicados;
SELECT COUNT(*) AS original FROM temp_limpieza;

-- Creamos la tabla  que probamos antes
CREATE TABLE limpieza AS SELECT * FROM temp_limpieza;

CALL limp();
-- Eliminamos la tabla atnerior
DROP TABLE conDuplicados;
-- Activar/ desactivar el modo seguro de sql
SET sql_safe_updates = 0;

-- Cambiar otros nombre de columnas
ALTER TABLE limpieza CHANGE COLUMN Apellido last_name VARCHAR(50) NULL;
ALTER TABLE limpieza CHANGE COLUMN star_date start_date VARCHAR(50) NULL;
CALL limp();
-- Vemos tipos de datos
DESCRIBE limpieza;

-- Remover espacios extra
-- Primero vemos si hay espacios en el name
SELECT name FROM limpieza
-- longitud de cada nombre - los caracteres finales totales
WHERE length(name) - length(trim(name)) > 0;

-- Corroboramos esto que el trim elimina los espacios
SELECT name, trim(name) AS name
 FROM limpieza
WHERE length(name) - length(trim(name)) > 0;
-- ahora lo modificamos en la tabla real
UPDATE limpieza SET name = trim(name)
WHERE length(name) - length(trim(name)) > 0;
-- corroboramos con la lineas anteriores
SELECT name FROM limpieza WHERE length(name) - length(trim(name)) > 0;

-- Remover espacios extra pero de apellidos
-- Primero vemos si hay espacios en el name
SELECT last_name FROM limpieza
-- longitud de cada nombre - los caracteres finales totales
WHERE length(last_name) - length(trim(last_name)) > 0;

-- Corroboramos esto que el trim elimina los espacios
SELECT last_name, trim(last_name) AS last_name
 FROM limpieza
WHERE length(last_name) - length(trim(last_name)) > 0;
-- ahora lo modificamos en la tabla real
UPDATE limpieza SET last_name = trim(last_name)
WHERE length(last_name) - length(trim(last_name)) > 0;
-- corroboramos con la lineas anteriores
SELECT last_name FROM limpieza WHERE length(last_name) - length(trim(last_name)) > 0;

-- Que pasa si tenemos espacios en el medio de dos palabaras, ejemplo
UPDATE limpieza SET area = REPLACE (area, ' ', '     ');
CALL limp();
-- Corroboramos cuantos registros tienen espacios
SELECT area FROM limpieza
WHERE area regexp '\\s{2,}'; -- esto muestra que tiene especacios (23)

-- Probar como quedatria la tabla si eliminamos esos espacios
SELECT area, trim(regexp_replace(area,'\\s+',' ')) as ensayo
FROM limpieza;
-- Corregimos y despues volvemos a cooroborar
UPDATE limpieza SET area = trim(regexp_replace(area,'\\s+',' '));
CALL limp();

-- Como estan en ingles los titulos hay que cambiar hombre/mujer
-- primero corroboramos
SELECT gender,
CASE 
	WHEN gender = 'hombre' then 'male'
    WHEN gender = 'mujer' then 'female'
    ELSE 'other'
END AS gender1
FROM limpieza;

-- Actualizamos
UPDATE limpieza SET gender = CASE 
	WHEN gender = 'hombre' then 'male'
    WHEN gender = 'mujer' then 'female'
    ELSE 'other'
END;

CALL limp();

-- Cambiar el type que es del tipo INT para poder cambiarlo a text y que nos de mas info de que se trata la columna
DESCRIBE limpieza;
ALTER TABLE limpieza MODIFY COLUMN type TEXT;

-- Corroboramos la  columna
SELECT type,
CASE 
	WHEN type = '1' then 'Remote'
    WHEN type = '0' then 'Hybrid'
    ELSE 'other'
END AS ejemplo
FROM limpieza;


-- Actualizamos
UPDATE limpieza SET type = CASE 
	WHEN type = '1' then 'Remote'
    WHEN type = '0' then 'Hybrid'
    ELSE 'other'
END;

CALL limp();


-- Cambiar la columna salary que esta con $
-- Primero corroboramos, el trim pare que no haya espacios en blanco asi despues lo podemos cambiar a numero
-- se reemplazan las "," y "$"
SELECT salary,
CAST(trim(REPLACE(REPLACE(salary, '$',''), ',', '')) AS decimal (15,2)) AS salary2
FROM limpieza;

-- Actualizamos
UPDATE limpieza SET salary = CAST(trim(REPLACE(REPLACE(salary, '$',''), ',', '')) AS decimal (15,2));
CALL limp();
-- Lo cambiamos a numero
ALTER TABLE limpieza MODIFY COLUMN salary INT NULL;

DESCRIBE limpieza;

-- Formato fechas
SELECT birth_date FROM limpieza; -- fromato m/d/y, deberia estar

-- Probar Cambiar formaro
SELECT birth_date, CASE
WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date,'%m/%d/%Y'),'%Y-%m-%d') -- Formato fecha
WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END AS new_birth_date
FROM limpieza;

-- Actualizamos
UPDATE limpieza SET birth_date = CASE
WHEN birth_date LIKE '%/%' THEN date_format(str_to_date(birth_date,'%m/%d/%Y'),'%Y-%m-%d') -- Formato fecha
WHEN birth_date LIKE '%-%' THEN date_format(str_to_date(birth_date,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

CALL limp();
-- Poner en formato date
ALTER TABLE limpieza MODIFY COLUMN birth_date date;
DESCRIBE limpieza;

-- Ahora revisamos start_date
-- Formato fechas
SELECT start_date FROM limpieza; -- fromato m/d/y, deberia estar

-- Probar Cambiar formaro
SELECT start_date, CASE
WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date,'%m/%d/%Y'),'%Y-%m-%d') -- Formato fecha
WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END AS new_start_date
FROM limpieza;
-- Actualizamos
UPDATE limpieza SET start_date = CASE
WHEN start_date LIKE '%/%' THEN date_format(str_to_date(start_date,'%m/%d/%Y'),'%Y-%m-%d') -- Formato fecha
WHEN start_date LIKE '%-%' THEN date_format(str_to_date(start_date,'%m-%d-%Y'),'%Y-%m-%d')
ELSE NULL
END;

CALL limp();
-- Poner en formato date
ALTER TABLE limpieza MODIFY COLUMN start_date date;
DESCRIBE limpieza;

-- Finish date que tiene distintos formatos de fecha
-- Probar Cambiar formaro
SELECT finish_date, date_format(str_to_date(finish_date,'%Y-%m-%d %H:%i:%s'),'%Y-%m-%d') AS fecha FROM limpieza;

ALTER TABLE limpieza ADD COLUMN date_backup TEXT;
UPDATE limpieza SET date_backup = finish_date;
UPDATE limpieza SET finish_date = str_to_date(finish_date,'%Y-%m-%d %H:%i:%s UTC')
WHERE finish_date <>'';

ALTER TABLE limpieza 
ADD COLUMN fecha date,
ADD COLUMN hora time;

UPDATE limpieza SET 
	fecha = date(finish_date),
	hora = time(finish_date)
    WHERE finish_date IS NOT NULL AND finish_date <>'';
    
UPDATE limpieza SET finish_date = NULL WHERE finish_date = '';

ALTER TABLE limpieza MODIFY COLUMN finish_date datetime;
DESCRIBE limpieza;


-- Calculos con fechas
ALTER TABLE limpieza ADD COLUMN age INT;
-- Esta mal porque hay uno que tiene -1 por ejemplo
SELECT name, birth_date, start_date, timestampdiff(year, birth_date, start_date) AS edad_ingreso FROM limpieza;

UPDATE limpieza SET age = timestampdiff(year,birth_date,curdate());
SELECT name,age FROM limpieza;
CALL limp();

-- Generar una columna nueva con el mail concatenatndo distinta info de las columnas dispobibles
SELECT concat(SUBSTRING_INDEX(name,' ', 1),'_', SUBSTRING(last_name,1,2), '.',SUBSTRING(type,1,2), '@consulting.com') AS email FROM limpieza;
-- Actualizar
ALTER TABLE limpieza ADD COLUMN email VARCHAR (100);
UPDATE limpieza SET email = concat(SUBSTRING_INDEX(name,' ', 1),'_', SUBSTRING(last_name,1,2), '.',SUBSTRING(type,1,2), '@consulting.com');


-- Definir las columnas con las que realmente queremos trabajar
SELECT id_emp, name, last_name, age, gender, area, salary, email, finish_date FROM limpieza
WHERE finish_date <= curdate() OR finish_date IS NULL
ORDER BY area, last_name;

-- Contar cuantos empleados hay por areea
SELECT area, COUNT(*) AS cantidad_empleados FROM limpieza
GROUP BY area
ORDER BY cantidad_empleados DESC;

-- Exportar datos
