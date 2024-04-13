DROP DATABASE IF EXISTS miempresa;
CREATE DATABASE miempresa;

USE miempresa;

DROP TABLE IF EXISTS Empleados;

CREATE TABLE Empleados(
idEmpleados int PRIMARY KEY auto_increment NOT NULL,
nombre varchar(100),
apellido varchar(100),
dni int 
);

INSERT INTO Empleados (nombre,apellido,dni) VALUES ('Andres','Munoz',42249620);
INSERT INTO Empleados (nombre,apellido,dni) VALUES ('Pedro','Diaz',14352068);
INSERT INTO Empleados (nombre,apellido,dni) VALUES ('Jose','Perez',456);
INSERT INTO Empleados (nombre,apellido,dni) VALUES ('Paula','Soria',33201485);
INSERT INTO Empleados (nombre,apellido,dni) VALUES ('Ana','Belgrano',40352163);

SELECT * FROM Empleados;

SELECT * FROM Empleados WHERE nombre LIKE 'a%';

SELECT * FROM Empleados WHERE (apellido = 'Perez') AND (dni = 456);

