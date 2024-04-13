SELECT * FROM UsuarioTarget
SELECT * FROM UsuarioSource


MERGE UsuarioTarget AS TARGET
USING UsuarioSource AS SOURCE
	ON (TARGET.Codigo = SOURCE.Codigo)
WHEN MATCHED AND (TARGET.Codigo <> SOURCE.Codigo) THEN
	UPDATE SET TARGET.Nombre = SOURCE.Nombre, TARGET.Puntos = SOURCE.Puntos
WHEN NOT MATCHED BY TARGET THEN
	INSERT (Codigo, Nombre, Puntos)
	VALUES (SOURCE.Codigo, SOURCE.Nombre, SOURCE.Puntos)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE 

	OUTPUT $action, 
DELETED.Codigo AS TargetCodigo, 
DELETED.Nombre AS TargetNombre, 
DELETED.Puntos AS TargetPuntos, 
INSERTED.Codigo AS SourceCodigo, 
INSERTED.Nombre AS SourceNombre, 
INSERTED.Puntos AS SourcePuntos; 
SELECT @@ROWCOUNT;
