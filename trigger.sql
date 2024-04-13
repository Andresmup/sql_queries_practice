USE Platzi; 

SELECT * FROM UsuarioSource;
SELECT * FROM UsuarioTarget;


CREATE OR ALTER TRIGGER t_delete
ON UsuarioSource
FOR DELETE
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
	RETURN;
	ELSE
	PRINT('Columnas borradas')
	SELECT Codigo, Nombre, Puntos FROM deleted
END;

CREATE OR ALTER TRIGGER t_delete
ON UsuarioSource
INSTEAD OF DELETE
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
	RETURN;
	ELSE
	PRINT('Ibas a borrar esto!!:')
	SELECT Codigo, Nombre, Puntos FROM deleted
END;

INSERT INTO UsuarioSource(Codigo, Nombre, Puntos) VALUES (6, 'Perez sol', 20);
DELETE FROM UsuarioSource WHERE Codigo = 6;




CREATE OR ALTER TRIGGER t_insert
ON UsuarioSource
AFTER INSERT
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
	RETURN;
		DECLARE @codigo int
		SELECT @codigo = codigo FROM INSERTED
			 IF @codigo > 10
				 BEGIN
				 PRINT('No se inserto porque el codigo era > 10');
				 ROLLBACK;
				 RETURN;
			 END
		 ELSE
		 PRINT('Fila insertada correctamente');
		 SELECT * FROM inserted;


END;

INSERT INTO UsuarioSource(Codigo, Nombre, Puntos) VALUES (6, 'Perez sol', 20);
INSERT INTO UsuarioSource(Codigo, Nombre, Puntos) VALUES (16, 'Perez sol', 20);




/*
Un disparador o trigger es una funcionalidad que la base de datos ejecuta de forma automática cuando se realiza una operación de tipo Insert, Update o Delete en una tabla o vista, o cuando se ejecuta una consulta SQL sobre una tabla o vista.
Se crean para conservar la integridad referencial y la coherencia entre los datos entre distintas tablas; para registrar los cambios que se efectúan sobre las tablas y la identidad de quien los realizó; para realizar cualquier acción cuando una tabla es modificada; etc.
Si se intenta modificar (agregar, actualizar o eliminar) datos de una tabla asociada a un disparador, el disparador se ejecuta (se dispara) en forma automática.
La diferencia con los procedimientos almacenados del sistema es que los triggers:
• no pueden ser invocados directamente; al intentar modificar los datos de una tabla asociada a un disparador, el disparador se ejecuta automáticamente.
• no reciben y retornan parámetros.
• son apropiados para mantener la integridad de los datos, no para obtener resultados de consultas.

Sintaxis general para crear un disparador:
create or replace trigger NOMBREDISPARADOR
MOMENTO-- before, after o instead of
EVENTO-- insert, update o delete
of CAMPOS-- solo para update
on NOMBRETABLA
NIVEL–puede ser a nivel de sentencia (statement) o de fila (for each row)
when CONDICION–opcional
begin
CUERPO DEL DISPARADOR–sentencias
end NOMBREDISPARADOR;

Los triggers se crean con la instrucción “create trigger” seguido del nombre del disparador. Si se agrega “or replace” al momento de crearlo y ya existe un trigger con el mismo nombre, tal disparador será borrado y vuelto a crear.
“MOMENTO” indica cuando se disparará el trigger en relación al evento, puede ser BEFORE (antes), AFTER (después) o INSTEAD OF (en lugar de). “before” significa que el disparador se activará antes que se ejecute la operación (insert, update o delete) sobre la tabla, que causó el disparo del mismo. “after” significa que el trigger se activará después que se ejecute la operación que causó el disparo. “instead of” sólo puede definirse sobre vistas, anula la sentencia disparadora, se ejecuta en lugar de tal sentencia (ni antes ni después).
“EVENTO” especifica la operación (acción, tipo de modificación) que causa que el trigger se dispare (se active), puede ser “insert”, “update” o “delete”; DEBE colocarse al menos una acción, puede ser más de una, en tal caso se separan con “or”. Si “update” lleva una lista de atributos, el trigger sólo se ejecuta si se actualiza algún atributo de la lista.
“on NOMBRETABLA” indica la tabla (o vista) asociada al disparador;
“NIVEL” puede ser a nivel de sentencia o de fila. “for each row” indica que el trigger es a nivel de fila, es decir, se activa una vez por cada registro afectado por la operación sobre la tabla, cuando una sola operación afecta a varios registros. Los triggers a nivel de sentencia, se activan una sola vez (antes o después de ejecutar la operación sobre la tabla). Si no se especifica, o se especifica “statement”, es a nivel de sentencia.
“CUERPO DEL DISPARADOR” son las acciones que se ejecutan al dispararse el trigger, las condiciones que determinan cuando un intento de inserción, actualización o borrado provoca las acciones que el trigger realizará. El bloque se delimita con “begin… end”.
Entonces, un disparador es un bloque de código asociado a una tabla que se dispara automáticamente antes o después de una sentencia “insert”, “update” o “delete” sobre la tabla.
Se crean con la instrucción “create trigger” especificando el momento en que se disparará, qué evento lo desencadenará (inserción, actualización o borrado), sobre qué tabla (o vista) y las instrucciones que se ejecutarán.
Los disparadores pueden clasificarse según tres parámetros:
• el momento en que se dispara: si se ejecutan antes (before) o después (after) de la sentencia.
• el evento que los dispara: insert, update o delete, según se ejecute una de estas sentencias sobre la tabla.
• nivel: dependiendo si se ejecuta para cada fila afectada en la sentencia (por cada fila) o bien una única vez por sentencia independientemente de la filas afectadas (nivel de sentencia).
Consideraciones generales:
• Las siguientes instrucciones no están permitidas en un desencadenador: create database, alter database, drop database, load database, restore database, load log, reconfigure, restore log, disk init, disk resize.
• Se pueden crear varios triggers para cada evento, es decir, para cada tipo de modificación (inserción, actualización o borrado) para una misma tabla. Por ejemplo, se puede crear un “insert trigger” para una tabla que ya tiene otro “insert trigger”.
A continuación veremos la creación de disparadores para los distintos sucesos (inserción, borrado, actualización) y todas las cláusulas adicionales.

*/