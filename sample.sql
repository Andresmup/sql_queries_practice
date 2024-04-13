DROP DATABASE examen_final;
CREATE DATABASE examen_final;
USE examen_final;
CREATE TABLE Bicicleteria (
idBicicleteria int PRIMARY KEY auto_increment NOT NULL,
ganancias varchar(45),
cantVentas int
);

CREATE TABLE Bicicleta(
nroDeSerie varchar(45) PRIMARY KEY NOT NULL,
modelo varchar(45),
anio int,
precio varchar(45),
Bicicleteria_idBicicleteria int,
KEY `Bicicleteria_idBicicleteria` (`Bicicleteria_idBicicleteria`),
CONSTRAINT `bicicleta_bicicleteriaID` FOREIGN KEY (`Bicicleteria_idBicicleteria`) REFERENCES `Bicicleteria` (`idBicicleteria`)
);

INSERT INTO Bicicleteria (idBicicleteria, ganancias,cantVentas ) VALUES 
(1,"450000",20),
(2,"2000",3),
(3,"2001020",34),
(4,"32349",10);

INSERT INTO Bicicleta(nroDeSerie,modelo,anio,precio,Bicicleteria_idBicicleteria)  VALUES
("AA001", "Vayron_Matrix", 2020,"200000", 1),
("AA002", "Vayron_Redemption", 2022,"400000", 2),
("AA003", "Vayron_Matrix", 2020,"200000", 2),
("AA004", "Vayron_Redemption_Reload", 2022,"500000", 2),
("BB001", "Bespo", 2010,"35000", 1),
("BB002", "Bespo", 2011,"45000", 2),
("BB003", "Bespo_Espirit", 2018,"150000", 2),
("BB004", "Bespo_Philco", 2010,"55000", 3),
("CC001", "Clauser", 2020,"350000", 3),
("CC002", "Clauser_Reload", 2020,"370000", 4);

SELECT * FROM Bicicleteria;
SELECT * FROM Bicicleta;


SELECT nroDeSerie, modelo, anio FROM Bicicleta WHERE anio >= 2018;


SELECT * FROM Bicicleteria WHERE idBicicleteria = 2;
SELECT * FROM Bicicleta WHERE Bicicleteria_idBicicleteria = 2;
SELECT Bicicleteria.cantVentas, Bicicleteria.ganancias, COUNT(Bicicleta.Bicicleteria_idBicicleteria) AS "cantidad de bicicletas en venta" 
FROM Bicicleteria
INNER JOIN Bicicleta ON Bicicleta.Bicicleteria_idBicicleteria = Bicicleteria.idBicicleteria
WHERE Bicicleteria.idBicicleteria = 2;

