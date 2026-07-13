 -- Se crea el esquema
CREATE DATABASE test; 



-- Eliminar base de datos
DROP DATABASE test; 
-- Usar la base de datos
USE test;

-- Crear tabla
CREATE TABLE personas(
id int,
name varchar (10),
age int,
email varchar (50),
created date
);

-- Prueba de las restriccion NOT NULL
CREATE TABLE personas2(
id int NOT NULL,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created date
); 
--  Prueba de las restriccion UNIQUE 
CREATE TABLE personas3(
id int NOT NULL,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created date,
UNIQUE (id)
); 

--  Prueba de las restriccion PK hay diferencias con lo anterior para despues relacionar con otras tablas
CREATE TABLE personas4(
id int NOT NULL,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created date,
UNIQUE (id),
PRIMARY KEY (id)
); 

--  Prueba de las restriccion CHECK 
-- CONSTRAINT `personas5_chk_1` CHECK ((`age` >= 18)) 
CREATE TABLE personas5(
id int NOT NULL,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created date,
UNIQUE (id),
PRIMARY KEY (id),
CHECK (age>=18)
); 

-- Valores por default 
CREATE TABLE personas6(
id int NOT NULL,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created datetime DEFAULT CURRENT_TIMESTAMP(),
UNIQUE (id),
PRIMARY KEY (id),
CHECK (age>=18)
); 


-- Valores por default 
CREATE TABLE personas7(
id int NOT NULL AUTO_INCREMENT,
name varchar (10)  NOT NULL,
age int,
email varchar (50),
created datetime DEFAULT CURRENT_TIMESTAMP(),
UNIQUE (id),
PRIMARY KEY (id),
CHECK (age>=18)
); 

-- Borrar tabla
CREATE TABLE personas8(
name varchar (10)  NOT NULL);
DROP TABLE  personas8;

-- Cambiar tabla una vez que ya la genere
-- Agregar columna 
ALTER TABLE personas7
	ADD surname varchar(50);
-- Cambiar nombre de la columna
ALTER TABLE personas7
	RENAME COLUMN surname TO descripcion;
-- Eliminar columna de la tabla 
ALTER TABLE personas7
	MODIFY COLUMN descripcion varchar(250);

ALTER TABLE personas7
	DROP COLUMN descripcion;