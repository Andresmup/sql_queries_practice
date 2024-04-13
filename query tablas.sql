CREATE DATABASE control_de_stock;
USE control_de_stock;
CREATE TABLE producto(
	id INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255),
    cantidad INT NOT NULL DEFAULT 0,
    PRIMARY KEY(id)
)Engine = InnoDB;

INSERT INTO producto (nombre, descripcion, cantidad) VALUES (
	"Mesa", "Mesa madera comedor", 2
);

INSERT INTO producto (nombre, descripcion, cantidad) VALUES (
	"Celular", "Celular Samsumg", 50
);

SELECT * FROM producto;


USE control_de_stock;
CREATE TABLE categoria(
	id INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    PRIMARY KEY(id)
)Engine = InnoDB;

INSERT INTO categoria(nombre) VALUES ('Muebles'),('Cocina'),('Tecnologia'),('Zapatillas');
INSERT INTO categoria(nombre) VALUES ('Juguetes');

SELECT * FROM producto;
SELECT * FROM categoria;


ALTER TABLE producto ADD COLUMN categoria_id INT;

ALTER TABLE producto ADD FOREIGN KEY (categoria_id) REFERENCES categoria(id);

UPDATE producto SET categoria_id = 3 WHERE id = 2;