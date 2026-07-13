CREATE SCHEMA escuela;
USE escuela;

CREATE TABLE alumnos(
id_alumno INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
apellido VARCHAR(50),
nombre VARCHAR(50),
edad INT,
direccion VARCHAR(100),
telefono VARCHAR(20),
email VARCHAR(50)
);

CREATE TABLE cursos(
id_curso INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
nombre VARCHAR(50),
nivel_habilidad  VARCHAR(35),
tipo_instrumento VARCHAR(35)
);

CREATE TABLE inscripciones(
id_inscripciones INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
fecha_inscripicion date,
abono_insc boolean,
id_alumno INT,
id_curso INT,
FOREIGN KEY (id_alumno) REFERENCES alumnos (id_alumno),
FOREIGN KEY (id_curso) REFERENCES cursos (id_curso),
UNIQUE(id_alumno,id_curso)
);


-- ---------------------------------------------------------------------------
INSERT INTO alumnos (apellido, nombre, edad, direccion, telefono, email) VALUES
('Martínez', 'Sofía', 21, 'Calle Rivadavia 512', '351-6001234', 'sofia.martinez@example.com'),
('Arias', 'Tomás', 26, 'Av. O’Higgins 340', '351-6002345', 'tomas.arias@example.com'),
('García', 'Paula', 29, 'Calle Laprida 980', '351-6003456', 'paula.garcia@example.com'),
('Bustos', 'Andrés', 20, 'Corrientes 470', '351-6004567', 'andres.bustos@example.com'),
('Rojas', 'Martina', 32, 'Mendoza 1450', '351-6005678', 'martina.rojas@example.com'),
('Herrera', 'Nicolás', 24, 'Caseros 230', '351-6006789', 'nicolas.herrera@example.com'),
('Medina', 'Camila', 23, 'Bolívar 190', '351-6007890', 'camila.medina@example.com'),
('Silva', 'Hugo', 35, 'Perú 600', '351-6008901', 'hugo.silva@example.com'),
('Juárez', 'Emilia', 22, 'Catamarca 350', '351-6009012', 'emilia.juarez@example.com'),
('Molina', 'Sebastián', 28, 'San José 520', '351-6000123', 'sebastian.molina@example.com'),
('Aguilar', 'Carla', 27, 'Santa Fe 980', '351-6111234', 'carla.aguilar@example.com'),
('Coronel', 'Rodrigo', 30, 'Colón 2300', '351-6112345', 'rodrigo.coronel@example.com'),
('Vega', 'Micaela', 25, 'Bv. San Juan 430', '351-6113456', 'micaela.vega@example.com'),
('Peralta', 'Franco', 19, 'Sucre 210', '351-6114567', 'franco.peralta@example.com'),
('Benítez', 'Daniela', 33, 'Santiago 770', '351-6115678', 'daniela.benitez@example.com'),
('Figueroa', 'Leandro', 31, 'Rosario 1890', '351-6116789', 'leandro.figueroa@example.com'),
('Navarro', 'Brenda', 26, 'Chacabuco 250', '351-6117890', 'brenda.navarro@example.com'),
('Campos', 'Iván', 23, 'Belgrano 880', '351-6118901', 'ivan.campos@example.com'),
('Suárez', 'Julieta', 24, 'Sarmiento 450', '351-6119012', 'julieta.suarez@example.com'),
('Castro', 'Pablo', 34, 'Av. Patria 1020', '351-6120123', 'pablo.castro@example.com');


INSERT INTO cursos (nombre, nivel_habilidad, tipo_instrumento) VALUES
('Bajo Eléctrico Inicial', 'Principiante', 'Cuerda'),
('Bajo Eléctrico Intermedio', 'Intermedio', 'Cuerda'),
('Saxofón Básico', 'Principiante', 'Viento'),
('Saxofón Avanzado', 'Avanzado', 'Viento'),
('Percusión Latina', 'Intermedio', 'Percusión'),
('Teoría Musical I', 'Principiante', 'General'),
('Teoría Musical II', 'Intermedio', 'General'),
('Producción Musical', 'Intermedio', 'Digital'),
('DJ Inicial', 'Principiante', 'Digital'),
('DJ Avanzado', 'Avanzado', 'Digital');

INSERT INTO inscripciones (fecha_inscripicion, abono_insc, id_alumno, id_curso) VALUES
('2025-02-01', TRUE, 1, 1),
('2025-02-02', TRUE, 1, 3),
('2025-02-05', FALSE, 2, 2),
('2025-02-06', TRUE, 2, 6),
('2025-02-07', TRUE, 3, 4),
('2025-02-10', FALSE, 3, 8),
('2025-02-12', TRUE, 4, 5),
('2025-02-14', TRUE, 4, 1),
('2025-02-16', FALSE, 5, 7),
('2025-02-18', TRUE, 5, 2),
('2025-02-20', TRUE, 6, 9),
('2025-02-21', TRUE, 6, 10),
('2025-02-22', FALSE, 7, 3),
('2025-02-25', TRUE, 7, 6),
('2025-02-26', TRUE, 8, 4),
('2025-02-28', FALSE, 8, 1),
('2025-03-01', TRUE, 9, 5),
('2025-03-02', TRUE, 9, 10),
('2025-03-03', TRUE, 10, 7),
('2025-03-05', FALSE, 10, 9),
('2025-03-06', TRUE, 11, 1),
('2025-03-07', TRUE, 11, 8),
('2025-03-08', FALSE, 12, 4),
('2025-03-09', TRUE, 12, 6),
('2025-03-10', TRUE, 13, 3),
('2025-03-11', TRUE, 13, 5),
('2025-03-12', FALSE, 14, 2),
('2025-03-13', TRUE, 14, 7),
('2025-03-14', TRUE, 15, 9),
('2025-03-15', FALSE, 15, 10),
('2025-03-16', TRUE, 16, 6),
('2025-03-17', TRUE, 16, 1),
('2025-03-18', FALSE, 17, 8),
('2025-03-19', TRUE, 17, 4),
('2025-03-20', TRUE, 18, 3),
('2025-03-21', FALSE, 18, 7),
('2025-03-22', TRUE, 19, 2),
('2025-03-23', TRUE, 19, 10),
('2025-03-24', FALSE, 20, 5),
('2025-03-25', TRUE, 20, 9);

INSERT INTO inscripciones (fecha_inscripicion, abono_insc, id_alumno, id_curso) VALUES
('2025-04-01', TRUE, 1, 6),
('2025-02-02', TRUE, 2, 7),
('2025-02-02', TRUE, 20, 2);

INSERT INTO inscripciones (fecha_inscripicion, abono_insc, id_alumno, id_curso) VALUES
('2025-03-12', FALSE, 14, 2);


DELETE FROM inscripciones WHERE id_alumno = 14 and id_curso = 7;