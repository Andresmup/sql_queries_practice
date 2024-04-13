USE miempresa;

DROP TABLE IF EXISTS Departamento;

CREATE TABLE Departamento(
idDep int PRIMARY KEY auto_increment NOT NULL,
Nombre varchar(100),
Presupuesto int
);

INSERT INTO Departamento (Nombre,Presupuesto) VALUES ('Comercial',45000);
INSERT INTO Departamento (Nombre,Presupuesto) VALUES ('Administrativo',45000);


SET SQL_SAFE_UPDATES = 0;
UPDATE Departamento SET Presupuesto = 60000 WHERE Nombre = 'Administrativo';
SET SQL_SAFE_UPDATES = 1;


SELECT * FROM Departamento;