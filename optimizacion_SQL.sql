------------------------------------------------------
-- Clase 05 - Introducción Planes de Ejecución
------------------------------------------------------

-- Ejecutaremos algunos querys de practica

USE WideWorldImporters

GO

-- Activemos las estadísticas 
SET STATISTICS IO ON

GO

SELECT TOP 10000 * 
  FROM Application.People p INNER JOIN 
       Sales.InvoiceLines i ON p.PersonID = i.LastEditedBy INNER JOIN 
       Warehouse.StockItemTransactions s ON p.PersonID = s.LastEditedBy
 ORDER BY i.StockItemID

GO

SELECT *
  FROM Sales.Invoices
--WITH(INDEX([FK_Sales_Invoices_AccountsPersonID]))
 WHERE CustomerID = 191

GO

SELECT * FROM Warehouse.VehicleTemperatures

GO

SELECT * FROM Sales.InvoiceLines

GO

SELECT * FROM Sales.Invoices WHERE OrderID = 100

GO

SELECT * FROM Purchasing.PurchaseOrders


-- Para desplegar pantalla
-- TOOLS \ OPTIONS \ Query Results \ SQL Server \ Result to Grid


SET STATISTICS IO ON

SELECT (SELECT MAX([OrderDate])
FROM [Sales].[Orders]) mx,
(SELECT
MIN([BackorderOrderID])
FROM [Sales].[Orders]) mn;

GO

SELECT MAX([OrderDate]) mx,
MIN([BackorderOrderID]) mn
FROM [Sales].[Orders];

------------------------------------------------------
-- Clase 06 - Indices
------------------------------------------------------

USE WideWorldImporters

GO

SET STATISTICS IO ON;
GO

SELECT TOP 10000 * 
  FROM Application.People p INNER JOIN 
       Sales.InvoiceLines i ON p.PersonID = i.LastEditedBy INNER JOIN 
       Warehouse.StockItemTransactions s ON p.PersonID = s.LastEditedBy
 ORDER BY i.StockItemID

 GO

-- Ejecute el siguiente comando para habilitar las estadísticas para el IO.
-- Activando las estadísticas nos va a mostrar el detalle de la carga de escritura y tamaño de paginación
SET STATISTICS IO ON

SELECT [OrderID],[ContactPersonID],
        [PickingCompletedWhen]
FROM [WideWorldImporters].[Sales].[Orders]
WHERE ContactPersonID = 3176;

-- Corregir el índice
FK_Sales_Orders_ContactPersonID agregar [PickingCompletedWhen]

-- Aqui podemos ver la respuesta de las estadísticas.
-- Table 'Orders'. Scan count 1, logical reads 416,
-- En el plan de ejecucion podemos ver el Key Lookup y las columnas que estan fuera del índice.
-- Corregir el índice

-------------------------

SET STATISTICS IO ON
SELECT [InvoiceID]     
      ,[ContactPersonID]
      ,[AccountsPersonID]
  FROM [WideWorldImporters].[Sales].[Invoices]
  WHERE [ContactPersonID] >= 3032 AND
        [ContactPersonID] <= 3035;

-- Corregir el índice
FK_Sales_Invoices_ContactPersonID agregar [AccountsPersonID]

------------------------------------------------------
-- Clase 07 - Crear índices, entender plan de ejecución
------------------------------------------------------

USE WideWorldImporters

GO

-- Activamos las estadísitcas
SET STATISTICS IO ON

SELECT TOP 10000 * 
  FROM Application.People p INNER JOIN 
       Sales.InvoiceLines i ON p.PersonID = i.LastEditedBy INNER JOIN 
       Warehouse.StockItemTransactions s ON p.PersonID = s.LastEditedBy
 ORDER BY i.StockItemID



 ------------------------------------------------------
-- Clase 08 - Forzar Indices
------------------------------------------------------

USE WideWorldImporters

GO

SET STATISTICS IO ON

-- En este ejemplo indicamos que queremos utulizar el índice FK_Sales_Invoices_AccountsPersonID
SELECT *
FROM [WideWorldImporters].[Sales].[Invoices]
--WITH(INDEX([FK_Sales_Invoices_AccountsPersonID]))
WHERE CustomerID = 191


SELECT *
FROM [WideWorldImporters].[Sales].[Invoices]
WITH(INDEX([FK_Sales_Invoices_AccountsPersonID]))
WHERE CustomerID = 191
 
-- Reiterando que forzar el uso de un indice NO es una buena idea, exepto en casos aislados de uso temporal. 
-- Imaginemos una migracion o una carga especial de datos donde queremos que los datos se comporten de una forma en específico.
-- Siempre es recomendado reescribir una consulta para que se utilice el indice adecuado.

------------------------------------------------------
-- Clase 09 - Índices pueden perjudicar el rendimiento?
------------------------------------------------------

USE AdventureWorks2019

GO 
-- Activamos las estadísticas
SET STATISTICS IO ON

GO

SELECT SalesOrderDetailID,
	   OrderQty
  FROM Sales.SalesOrderDetail S
 WHERE ProductID = (SELECT AVG(ProductID)
					 FROM Sales.SalesOrderDetail S2
					 WHERE S2.SalesOrderID = S.SalesOrderID
					 GROUP BY SalesOrderID)

-- Se pueden ver los datos y analizar la cantidad e información
-- una pagina pesa 8K. se multiplican los valores para ver el tamaño de la informacion que estamos procesando.

CREATE NONCLUSTERED INDEX IX_PRIMERO
ON Sales.SalesOrderDetail
(SalesOrderID ASC, ProductID ASC)
INCLUDE (SalesOrderDetailID, OrderQty)


CREATE NONCLUSTERED INDEX IX_SEGUNDO
ON Sales.SalesOrderDetail
(ProductID ASC, SalesOrderID ASC)
INCLUDE (SalesOrderDetailID, OrderQty)

-- Ejecutamos los dos indices y vemos que el segundo, donde aparentemente tienen los mismos datos solo que en orden distinto,
-- afecta el rendimiento de la consulta

DROP INDEX IX_PRIMERO ON Sales.SalesOrderDetail
DROP INDEX IX_SEGUNDO ON Sales.SalesOrderDetail

------------------------------------------------------
-- Clase 11 - Merge 01
------------------------------------------------------

USE Platzi

GO

CREATE TABLE UsuarioTarget
(
Codigo INT PRIMARY KEY,
Nombre VARCHAR(100),
Puntos INT
) 
GO
INSERT INTO UsuarioTarget VALUES
(1,'Juan Perez',10),
(2,'Marco Salgado',5),
(3,'Carlos Soto',9),
(4,'Alberto Ruiz',12),
(5,'Alejandro Castro',5)
GO
CREATE TABLE UsuarioSource
(
Codigo INT PRIMARY KEY,
Nombre VARCHAR(100),
Puntos INT
) 
GO
INSERT INTO UsuarioSource VALUES
(1,'Juan Perez',12),
(2,'Marco Salgado',11),
(4,'Alberto Ruiz Castro',4),
(5,'Alejandro Castro',5),
(6,'Pablo Ramos',8)
 
GO

SELECT * FROM UsuarioTarget
SELECT * FROM UsuarioSource

GO

--Sincronizar la tabla TARGET con
--los datos actuales de la tabla SOURCE
MERGE UsuarioTarget AS TARGET
USING UsuarioSource AS SOURCE 
   ON (TARGET.Codigo = SOURCE.Codigo) 
--Cuandos los registros concuerdan por la llave
--se actualizan los registros si tienen alguna variación
 WHEN MATCHED AND (TARGET.Nombre <> SOURCE.Nombre 
			    OR TARGET.Puntos <> SOURCE.Puntos) THEN 
   UPDATE SET TARGET.Nombre = SOURCE.Nombre, 
              TARGET.Puntos = SOURCE.Puntos 
--Cuando los registros no concuerdan por la llave
--indica que es un dato nuevo, se inserta el registro
--en la tabla TARGET proveniente de la tabla SOURCE
 WHEN NOT MATCHED BY TARGET THEN 
   INSERT (Codigo, Nombre, Puntos) 
   VALUES (SOURCE.Codigo, SOURCE.Nombre, SOURCE.Puntos)
--Cuando el registro existe en TARGET y no existe en SOURCE
--se borra el registro en TARGET
 WHEN NOT MATCHED BY SOURCE THEN 
   DELETE
 
--Seccion opcional e informativa
--$action indica el tipo de accion
--en   retorna cualquiera de las 3 acciones 
--'INSERT', 'UPDATE', or 'DELETE', 
OUTPUT $action, 
DELETED.Codigo AS TargetCodigo, 
DELETED.Nombre AS TargetNombre, 
DELETED.Puntos AS TargetPuntos, 
INSERTED.Codigo AS SourceCodigo, 
INSERTED.Nombre AS SourceNombre, 
INSERTED.Puntos AS SourcePuntos; 
SELECT @@ROWCOUNT;
GO
 
SELECT * FROM UsuarioTarget
SELECT * FROM UsuarioSource
------------------------------------------------------
-- Clase 12 - Mege, otras formas de utilizar
------------------------------------------------------

USE Platzi

GO

CREATE OR ALTER PROCEDURE MerceUsuarioTarget
    @Codigo integer,
    @Nombre varchar(100),
    @Puntos integer
AS
BEGIN
    MERGE UsuarioTarget AS T
        USING (SELECT @Codigo, @Nombre, @Puntos) AS S 
					   (Codigo, Nombre, Puntos)
		ON (T.Codigo = S.Codigo)
    WHEN MATCHED THEN
        UPDATE SET T.Nombre = S.Nombre,
				   T.Puntos = S.Puntos
    WHEN NOT MATCHED THEN
        INSERT (Codigo, Nombre, Puntos)
        VALUES (S.Codigo, S.Nombre, S.Puntos) ;
END

GO 

select * from UsuarioTarget
exec MerceUsuarioTarget 3,'Roy Rojas', 9
select * from UsuarioTarget

------------------------------------------------------
-- Clase 13 - Trigger, qué es? como funciona?
------------------------------------------------------


CREATE OR ALTER TRIGGER t_insert 
   ON  UsuarioTarget
   AFTER INSERT
AS 
BEGIN

	IF (ROWCOUNT_BIG() = 0)
	RETURN;

	select Codigo, Nombre, Puntos from inserted

	Print 'Se realizó un insert'

END

GO

CREATE OR ALTER TRIGGER t_update 
   ON  UsuarioTarget
   AFTER UPDATE
AS 
BEGIN

	IF (ROWCOUNT_BIG() = 0)
	RETURN;
	
	select Codigo, Nombre, Puntos from inserted
	
	Print 'Se realizó un update'

END
GO

insert into UsuarioTarget values(11, 'Maria', 15)
update UsuarioTarget set Nombre = 'Carlos Soto Soto' where Codigo = 8

-- Podriamos tener un trigger que cuando se ingrese una venta, nos recalcule los valores de la tabla de inventario


------------------------------------------------------
-- Clase 14 - Trigger manejo de errores
------------------------------------------------------

USE Platzi
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   TRIGGER [dbo].[t_update] 
   ON  [dbo].[UsuarioTarget]
   AFTER INSERT, UPDATE
AS 
BEGIN

	IF (ROWCOUNT_BIG() = 0)
	RETURN;

	DECLARE @codigo int
	SELECT @codigo = codigo FROM inserted

	IF @codigo = 7
	BEGIN
		Print 'NO se realizó un update'
		ROLLBACK;
		RETURN;
	END
	
	-- SELECT Codigo, Nombre, Puntos from inserted
	
	Print 'Se realizó un update'

END


GO

select * from UsuarioTarget where Codigo = 8
update UsuarioTarget set Nombre = 'Andres Soto' where Codigo = 8
select * from UsuarioTarget where Codigo = 8

------------------------------------------------------
-- Clase 15 - Trigger - Administracion de SQL
------------------------------------------------------
 
-- trigger para creacion de tablas

CREATE OR ALTER TRIGGER safety   
ON DATABASE   
FOR DROP_TABLE, ALTER_TABLE   
AS   
   PRINT 'No es permitido modificar la estructura de las tablas, comuníquese con el DBA.'   
   ROLLBACK;  


ALTER TABLE UsuarioTarget
ALTER COLUMN Nombre VARCHAR(100)

DROP TABLE UsuarioTarget


-----------------------------------

-- trigger para cracion de base de datos.GO


CREATE TRIGGER ddl_trig_database   
ON ALL SERVER   
FOR CREATE_DATABASE   
AS   
    PRINT 'Base de datos NO creada.'  
	ROLLBACK; 
GO  
DROP TRIGGER ddl_trig_database  
ON ALL SERVER;  



CREATE DATABASE [prueba]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'prueba', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019DEV\MSSQL\DATA\prueba.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'prueba_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019DEV\MSSQL\DATA\prueba_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
GO


------------------------------------------------------
-- Clase 16 - Constraint
------------------------------------------------------

USE Platzi
GO

insert into UsuarioSource
values(17,'Vanesa Rojas','')


select * from UsuarioSource where Codigo in(16,17)

delete UsuarioSource where Codigo = 17

update UsuarioSource set Nombre = 'Andres Soto' where Codigo = 8
select * from UsuarioTarget where Codigo = 8

USE Platzi
GO

/****** Object:  Table [dbo].[UsuarioSource]    Script Date: 11/10/2020 12:26:13 AM ******/
SET ANSI_NULLS ON
GO

-- Valor default
ALTER TABLE UsuarioSource 
ADD CONSTRAINT [DF_UsuarioSource_Puntos]  DEFAULT ((0)) FOR [Puntos]
GO

-- Unico
ALTER TABLE UsuarioSource 
ADD CONSTRAINT UC_Nombre UNIQUE (Nombre)
GO

ALTER TABLE UsuarioSource 
ADD CONSTRAINT CHK_Nombre_Puntos Check (Puntos >=0 AND Nombre <> 'Maria Solis')
GO


INSERT UsuarioSource
VALUES(8,'Maria Solis','')


------------------------------------------------------
-- Clase 16 - Tablas Versionadas
------------------------------------------------------

USE PlatziSQL

GO
 
-------------------------------------
-- Creacion de tabla versionada desde el inicio

CREATE TABLE Usuario
(
  [UsuarioID] int NOT NULL PRIMARY KEY CLUSTERED
  , Nombre nvarchar(100) NOT NULL
  , Twitter varchar(100) NOT NULL
  , Web varchar(100) NOT NULL
  , ValidFrom datetime2 GENERATED ALWAYS AS ROW START
  , ValidTo datetime2 GENERATED ALWAYS AS ROW END
  , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
 )
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsuarioHistory));

GO


-------------------------------------
-- Inserts de pruebas

INSERT INTO [dbo].[Usuario]
           ([UsuarioID]
           ,[Nombre]
           ,[Twitter]
           ,[Web])
     VALUES
           (1
           ,'Roy Rojas'
           ,'@royrojasdev'
           ,'www.dotnetcr.com')

INSERT INTO [dbo].[Usuario]
           ([UsuarioID]
           ,[Nombre]
           ,[Twitter]
           ,[Web])
     VALUES
           (2
           ,'Maria Ramirez'
           ,'@maria'
           ,'www.mariaramitez.com')

GO


-------------------------------------
-- Actualizar un registro

UPDATE Usuario
SET Nombre = 'Roy Rojas Rojas'
WHERE UsuarioID = 1

GO


-------------------------------------
-- Consultas a los datos historicos

-- Puedes hacer consultas directamente a la tabla histórita
SELECT * FROM UsuarioHistory WHERE UsuarioID = 1

-- Consulta todos los cambios por rango de fechas
SELECT * FROM Usuario
  FOR SYSTEM_TIME
    BETWEEN '2020-01-01 00:00:00.0000000' AND '2021-01-01 00:00:00.0000000'
  ORDER BY ValidFrom;

GO

-- Consulta un usuario por rango de fechas
SELECT * FROM Usuario
  FOR SYSTEM_TIME
    BETWEEN '2020-01-01 00:00:00.0000000' AND '2021-01-01 00:00:00.0000000'
      WHERE UsuarioID = 1 ORDER BY ValidFrom;

GO

-- Consulta un usuario por fecha pero solo en la tabla historial
SELECT * FROM Usuario FOR SYSTEM_TIME
    CONTAINED IN ('2020-01-01 00:00:00.0000000', '2021-01-01 00:00:00.0000000')
        WHERE UsuarioID = 1 ORDER BY ValidFrom;

GO

-- Consulta un usuario por ID
SELECT * FROM Usuario
    FOR SYSTEM_TIME ALL WHERE
        UsuarioID = 2 ORDER BY ValidFrom;


-------------------------------------
-- Para borrar las tablas versionadas

ALTER TABLE [dbo].[Usuario] SET ( SYSTEM_VERSIONING = OFF  )
GO

DROP TABLE [dbo].[Usuario]
GO

DROP TABLE [dbo].[UsuarioHistory]
GO


-------------------------------------
-- Crear tabla versionada para tablas ya existentes

CREATE TABLE Usuario2
(
  [UsuarioID] int NOT NULL PRIMARY KEY CLUSTERED
  , Nombre nvarchar(100) NOT NULL
  , Twitter varchar(100) NOT NULL
  , Web varchar(100) NOT NULL
 )

 GO

ALTER TABLE Usuario2
ADD
    ValidFrom datetime2 (2) GENERATED ALWAYS AS ROW START HIDDEN
        constraint DF_ValidFrom DEFAULT DATEADD(second, -1, SYSUTCDATETIME())  
    , ValidTo datetime2 (2) GENERATED ALWAYS AS ROW END HIDDEN
        constraint DF_ValidTo DEFAULT '9999.12.31 23:59:59.99'
    , PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);

ALTER TABLE Usuario2
    SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Usuario2_History));


	------------------------------------------------------
-- Clase 17 - Full text search
------------------------------------------------------
 
-- Creamos el catalogo con la herramienta grafica.

-- En en el Management Studio buscamos en la base de datos 
-- Storage / Full Text Catalogs / Click derecho New

------------------------
-- Cómo lo utilizamos
------------------------

-- IMPORTANTE
-- Para hacer coincidir palabras y frases, use CONTAINS y CONTAINSTABLE.
-- Para hacer coincidir el significado, aunque no con la redacción exacta, use FREETEXT y FREETEXTTABLE

USE AdventureWorks2012  
GO  
  
SELECT Name, ListPrice  
FROM Production.Product  
WHERE ListPrice = 80.99  
   AND Name like '%Mountain%'
GO  

SELECT Name, ListPrice  
FROM Production.Product  
WHERE ListPrice = 80.99  
   AND CONTAINS(Name, 'Mountain')  
GO  


-- Ejemplo 02
---------------------------------
-- Busqueda en documentos word


USE [Platzi]
GO


CREATE TABLE [dbo].[Documentos](
	[id] [int] NOT NULL,
	[NombreArchivo] [nvarchar](40) NULL,
	[Contenido] [varbinary](max) NULL,
	[extension] [varchar](5) NULL,
 CONSTRAINT [PK_Documentos] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


INSERT INTO Documentos
SELECT 3,N'Prueba-01-2', BulkColumn,'.doc'
FROM OPENROWSET(BULK  N'C:\Temp\1.doc', SINGLE_BLOB) blob


INSERT INTO Documentos
SELECT 4,N'Prueba-02-2', BulkColumn,'.doc'
FROM OPENROWSET(BULK  N'C:\Temp\2.doc', SINGLE_BLOB) blob

select * from Documentos


--select * from Documentos where DocContent like '%Roy%'

SELECT *
FROM Documentos  
WHERE FREETEXT (DocContent, 'Roy')  
GO  




----


USE AdventureWorks2019

SELECT Name, ListPrice  
FROM Production.Product  
WHERE CONTAINS(Name, 'Mountain') 

SELECT Title, *  
FROM Production.Document  
WHERE FREETEXT (Document, 'important bycycle guidelines')  

SELECT Title  
FROM Production.Document  
WHERE FREETEXT (Document, 'vital safety components') 


select * from Production.ProductDescription 
where CONTAINS(Description, 'NEAR((lightweight, aluminum), 10)')


-- haciendo join con el catalogo
SELECT KEY_TBL.RANK, FT_TBL.Description  
FROM Production.ProductDescription AS FT_TBL   
     INNER JOIN  
     FREETEXTTABLE(Production.ProductDescription, Description,  
                    'perfect all-around bike') AS KEY_TBL  
     ON FT_TBL.ProductDescriptionID = KEY_TBL.[KEY]  
WHERE KEY_TBL.RANK >= 10  
ORDER BY KEY_TBL.RANK DESC  


------------------------------------------------------
-- Clase 18 - Funciones
------------------------------------------------------

USE WideWorldImporters

GO

SELECT I.StockItemID,
	   I.StockItemName,
	   SUM(O.Quantity * O.UnitPrice) as Vendido
  FROM Warehouse.StockItems I INNER JOIN	
	   Sales.OrderLines O ON I.StockItemID = O.StockItemID
 WHERE I.StockItemID = 45
 GROUP BY I.StockItemID,
	   I.StockItemName
GO
SELECT I.StockItemID,
	   I.StockItemName,
	   dbo.f_TotalVendidoXProducto(I.StockItemID) as Vendido
  FROM Warehouse.StockItems I
 WHERE I.StockItemID = 45

 GO
 
-- Funcion con retorno de un valor
CREATE FUNCTION f_TotalVendidoXProducto
(
	@StockItemID int
)
RETURNS decimal
AS
BEGIN

	DECLARE @total decimal

	SELECT @total = SUM(Quantity * UnitPrice)
	  FROM  Sales.OrderLines
	 WHERE StockItemID = @StockItemID

	RETURN @total

END

GO

SELECT dbo.f_TotalVendidoXProducto(45)

GO

------------------------------------------------------
-- Clase 19 - Funciones Tabla
------------------------------------------------------

USE WideWorldImporters

GO

-- Funcion con retorno de una tabla

	SELECT s.StockItemID, s.StockItemName, SUM(l.Quantity) as Cantidad
	  FROM Warehouse.StockItems s INNER JOIN
		   Sales.InvoiceLines l ON s.StockItemID = l.StockItemID INNER JOIN
		   Sales.Invoices i ON l.InvoiceID = i.InvoiceID INNER JOIN
		   Sales.Customers c ON i.CustomerID = c.CustomerID
	 WHERE c.CustomerID = 832
	 GROUP BY s.StockItemID, s.StockItemName

GO
 

CREATE or ALTER FUNCTION f_TotalComprasXCliente
(	
	@CustomerID int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT s.StockItemID, s.StockItemName, SUM(l.Quantity) as Cantidad
	  FROM Warehouse.StockItems s INNER JOIN
		   Sales.InvoiceLines l ON s.StockItemID = l.StockItemID INNER JOIN
		   Sales.Invoices i ON l.InvoiceID = i.InvoiceID INNER JOIN
		   Sales.Customers c ON i.CustomerID = c.CustomerID
	 WHERE c.CustomerID = @CustomerID
	 GROUP BY s.StockItemID, s.StockItemName
)

GO

SELECT * FROM dbo.f_TotalComprasXCliente(832)

GO


-- Funciones con recursividad

USE AdventureWorks2019

GO

CREATE OR ALTER FUNCTION dbo.ufn_FindReports (@InEmpID INTEGER)
RETURNS @retFindReports TABLE
(
    EmployeeID int primary key NOT NULL,
    FirstName nvarchar(255) NOT NULL,
    LastName nvarchar(255) NOT NULL,
    JobTitle nvarchar(50) NOT NULL,
    RecursionLevel int NOT NULL
)
--Returns a result set that lists all the employees who report to the
--specific employee directly or indirectly.*/
AS
BEGIN
WITH EMP_cte(EmployeeID, OrganizationNode, FirstName, LastName, JobTitle, RecursionLevel) -- CTE name and columns
    AS (
        -- Get the initial list of Employees for Manager n
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, 0
        FROM HumanResources.Employee e INNER JOIN 
		     Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
        WHERE e.BusinessEntityID = @InEmpID
        UNION ALL
        -- Join recursive member to anchor
        SELECT e.BusinessEntityID, e.OrganizationNode, p.FirstName, p.LastName, e.JobTitle, RecursionLevel + 1
        FROM HumanResources.Employee e INNER JOIN
			 EMP_cte ON e.OrganizationNode.GetAncestor(1) = EMP_cte.OrganizationNode INNER JOIN 
			 Person.Person p ON p.BusinessEntityID = e.BusinessEntityID
        )
	
	-- Copiamos los valores en la tabla resultado
    INSERT @retFindReports
    SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel
    FROM EMP_cte
    RETURN

END;
GO
-- Example invocation
SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel
FROM dbo.ufn_FindReports(2);

------------------------------------------------------
-- Clase 20 - Vistas y Vista indexada
------------------------------------------------------

USE WideWorldImporters

-- Consultas a la tabla que vamos a utilizar
SELECT * FROM Sales.OrderLines
GO
SELECT COUNT(1) FROM Sales.OrderLines

GO

-- Query que vamos a implementar en la vista
SELECT StockItemID, 
    COUNT_BIG(*) as TotalLineas, 
	SUM(Quantity) as CantidadProductos,
	SUM(Quantity * UnitPrice)
FROM  Sales.OrderLines
GROUP BY StockItemID

GO

-- Creación de la vista
CREATE VIEW v_VentasXProducto
AS
     SELECT StockItemID, 
		    Description,
            COUNT_BIG(*) as TotalLineas, 
			SUM(Quantity) as CantidadProductos,
			SUM(Quantity * UnitPrice) Total
      FROM  Sales.OrderLines	  
      GROUP BY StockItemID, Description

GO

-- Ejecutando la vista
SELECT * FROM v_VentasXProducto
WHERE StockItemID = 105

GO

-- Creación de la vista indexada

-- Indispensable en la configuracion
SET ANSI_NULLS ON 
GO 
SET ANSI_PADDING ON 
GO 
SET ANSI_WARNINGS ON 
GO 
SET CONCAT_NULL_YIELDS_NULL ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 
SET NUMERIC_ROUNDABORT OFF 
GO

-- Indexada
-- Creación vista con SCHEMABINDING
CREATE VIEW v_VentasXProducto_Indexada
WITH SCHEMABINDING 
AS
     SELECT StockItemID, 
            COUNT_BIG(*) as TotalLineas, 
			SUM(Quantity) as CantidadProductos,
			SUM(ISNULL(Quantity * UnitPrice,0)) Total
      FROM  Sales.OrderLines	  
      GROUP BY StockItemID 

GO

-- Creación del índice de la vista
CREATE UNIQUE CLUSTERED INDEX IX_v_VentasXProducto_Indexada
ON v_VentasXProducto_Indexada ([StockItemID])

-- Ejecutando la vista
SELECT * FROM v_VentasXProducto_Indexada


-- Comparando las dos vístas

SELECT * FROM v_VentasXProducto
WHERE StockItemID = 105

SELECT * FROM v_VentasXProducto_Indexada
WHERE StockItemID = 105

GO

-- Recomendación creación del índice para la tabla Sales
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[OrderLines] ([StockItemID])
INCLUDE ([Description],[Quantity],[UnitPrice])

------------------------------------------------------
-- Clase 21 - Procedimientos almacenados
------------------------------------------------------
 

	SELECT I.StockItemName,
		   dbo.f_TotalVendidoXProducto(I.StockItemID)
	  FROM Warehouse.StockItems I INNER JOIN	
		   Sales.OrderLines O ON I.StockItemID = O.StockItemID
	 WHERE I.StockItemID = 45
	 GROUP BY I.StockItemID,
		   I.StockItemName

CREATE or ALTER PROCEDURE msp_retornaItem(
@StockItemID int,
@StockItemName NVARCHAR(100) output,
@Vendido decimal output
)
AS 
BEGIN

	SELECT @StockItemName = I.StockItemName,
		   @Vendido = dbo.f_TotalVendidoXProducto(I.StockItemID)
	  FROM Warehouse.StockItems I INNER JOIN	
		   Sales.OrderLines O ON I.StockItemID = O.StockItemID
	 WHERE I.StockItemID = @StockItemID
	 GROUP BY I.StockItemID,
		   I.StockItemName

END

GO

CREATE or ALTER PROCEDURE msp_retornaItem01(
@StockItemID int
)
AS 
	SET NOCOUNT ON
BEGIN

	SELECT I.StockItemID ,
		   I.StockItemName,
		   SUM(O.Quantity * O.UnitPrice) as Vendido
	  FROM Warehouse.StockItems I INNER JOIN	
		   Sales.OrderLines O ON I.StockItemID = O.StockItemID
	 WHERE I.StockItemID = @StockItemID
	 GROUP BY I.StockItemID,
		   I.StockItemName

END

exec msp_retornaItem01 45
GO
declare @StockItemName nvarchar(100)
declare @vendido decimal
exec msp_retornaItem 45, @StockItemName output, @vendido output
select @StockItemName, @vendido


-----------------------------------------------
--- Retorna Json or XML

USE Platzi

select * from UsuarioSource
FOR XML AUTO, ELEMENTS,  ROOT('Usuarios')

select * from UsuarioSource
FOR XML PATH('Usuario'), ELEMENTS, ROOT('UsuarioSource')


USE AdventureWorks2012
GO
SELECT Cust.CustomerID,
       OrderHeader.CustomerID,
       OrderHeader.SalesOrderID,
       OrderHeader.Status
FROM Sales.Customer Cust 
INNER JOIN Sales.SalesOrderHeader OrderHeader
ON Cust.CustomerID = OrderHeader.CustomerID
FOR XML PATH('Ordenes'), Root ('OrdenesCliente');



-------------------------
-- Retorna Json

USE AdventureWorks2019

SELECT * FROM Person.Person
WHERE BusinessEntityID = 1
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

SELECT PhoneNumber, PhoneNumberTypeID FROM Person.PersonPhone
WHERE BusinessEntityID = 1

select EmailAddress from Person.EmailAddress
WHERE BusinessEntityID = 1


SELECT BusinessEntityID,
		FirstName,
		LastName
		,
		(SELECT E.EmailAddress,
			    Ph.PhoneNumber
		   FROM Person.EmailAddress E INNER JOIN
			    Person.PersonPhone Ph ON E.BusinessEntityID = P.BusinessEntityID
									 AND E.BusinessEntityID = PH.BusinessEntityID
		  WHERE E.BusinessEntityID = P.BusinessEntityID
		 FOR JSON PATH) [DatosPersonales]
FROM Person.Person P
WHERE BusinessEntityID = 1
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

SET @jsonOutput = 



USE Platzi

SELECT codigo, 
	   nombre as 'usuario.nombre', 
	   puntos as 'usuario.puntos' 
  FROM usuariosource
FOR JSON PATH


, WITHOUT_ARRAY_WRAPPER


-------




USE Platzi

DECLARE @jsonVariable NVARCHAR(MAX);

SET @jsonVariable = N'[
  {
    "Order": {  
      "Number":"SO43659",  
      "Date":"2011-05-31T00:00:00"  
    },  
    "AccountNumber":"AW29825",  
    "Item": {  
      "Price":2024.9940,  
      "Quantity":1  
    }  
  },  
  {  
    "Order": {  
      "Number":"SO43661",  
      "Date":"2011-06-01T00:00:00"  
    },  
    "AccountNumber":"AW73565",  
    "Item": {  
      "Price":2024.9940,  
      "Quantity":3  
    }  
  }
]';

-- INSERT INTO <sampleTable>  
SELECT SalesOrderJsonData.Number, 
	   SalesOrderJsonData.Customer 
FROM OPENJSON (@jsonVariable, N'$')
  WITH (
    Number VARCHAR(200) N'$.Order.Number',
    Date DATETIME N'$.Order.Date',
    Customer VARCHAR(200) N'$.AccountNumber',
    Quantity INT N'$.Item.Quantity'
  ) AS SalesOrderJsonData
  WHERE SalesOrderJsonData.Number = N'SO43659';


  ------------------------------------------------------
-- Clase 22 - Tablas Temporales y Tablas Variables
------------------------------------------------------


USE Platzi

SELECT * FROM UsuarioSource

CREATE TABLE #UsuarioSource
(Codigo int, Nombre varchar(100))

INSERT INTO #UsuarioSource
SELECT Codigo, Nombre 
  FROM UsuarioSource
 WHERE Codigo < 4
 
SELECT * FROM #UsuarioSource

DROP TABLE #UsuarioSource

-- Tabla GLOBAL ##
-- Tablas las puede ver cualquier usuario en SQL
--- Recomendacion no usarlas
SELECT * FROM ##UsuarioSource

EXEC msp_prueba

CREATE PROCEDURE msp_prueba
AS 
BEGIN
	SELECT * FROM #UsuarioSource
END


DROP TABLE #UsuarioSource
DROP PROCEDURE msp_prueba


-----
-- Tablas variales

DECLARE @VariableTabla 
TABLE (Codigo int, Nombre varchar(100))

INSERT INTO @VariableTabla
SELECT Codigo, Nombre 
  FROM UsuarioSource
 --WHERE Codigo < 4

SELECT * FROM @VariableTabla


sp_configure 'show advanced', 1
GO
RECONFIGURE
GO
sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO

------------------------------------------------------
-- Clase 28 - Querys de monitoreo
------------------------------------------------------


-- Muestra el estado de las consultas y procesos en el servidor
-- se va a servir para ver si hay bloqueos o cual usuario ejecuta X proceso
USE master 

GO

CREATE PROCEDURE [dbo].[sp_who3]
(
    @SessionID int = NULL
)
AS
BEGIN
SELECT
    SPID                = er.session_id
    ,Status             = ses.status
    ,[Login]            = ses.login_name
    ,Host               = ses.host_name
    ,BlkBy              = er.blocking_session_id
    ,DBName             = DB_Name(er.database_id)
    ,CommandType        = er.command
    ,SQLStatement       =
        SUBSTRING
        (
            qt.text,
            er.statement_start_offset/2,
            (CASE WHEN er.statement_end_offset = -1
                THEN LEN(CONVERT(nvarchar(MAX), qt.text)) * 2
                ELSE er.statement_end_offset
                END - er.statement_start_offset)/2
        )
    ,ObjectName         = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
    ,ElapsedMS          = er.total_elapsed_time
    ,CPUTime            = er.cpu_time
    ,IOReads            = er.logical_reads + er.reads
    ,IOWrites           = er.writes
    ,LastWaitType       = er.last_wait_type
    ,StartTime          = er.start_time
    ,Protocol           = con.net_transport
    ,transaction_isolation =
        CASE ses.transaction_isolation_level
            WHEN 0 THEN 'Unspecified'
            WHEN 1 THEN 'Read Uncommitted'
            WHEN 2 THEN 'Read Committed'
            WHEN 3 THEN 'Repeatable'
            WHEN 4 THEN 'Serializable'
            WHEN 5 THEN 'Snapshot'
        END
    ,ConnectionWrites   = con.num_writes
    ,ConnectionReads    = con.num_reads
    ,ClientAddress      = con.client_net_address
    ,Authentication     = con.auth_scheme
FROM sys.dm_exec_requests er
LEFT JOIN sys.dm_exec_sessions ses
ON ses.session_id = er.session_id
LEFT JOIN sys.dm_exec_connections con
ON con.session_id = ses.session_id
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) as qt
WHERE @SessionID IS NULL OR er.session_id = @SessionID
AND er.session_id > 50
ORDER BY
    er.blocking_session_id DESC
    ,er.session_id
 
END

GO

------------------------------------------------------
-- Clase 29 - Querys de monitoreo 2
------------------------------------------------------

-- Objetos en modificarse
---------------------------------
-- ultimos objetos en modificarse
SELECT name
FROM sys.objects
WHERE type = 'P'
AND DATEDIFF(D,modify_date, GETDATE()) < 7
----Change 7 to any other day value

SELECT name, modify_date, create_date
FROM sys.objects
WHERE type = 'P'
AND DATEDIFF(D,modify_date, GETDATE()) < 7

-- muestra el script que muestra la fecha de creación y modificación de cualquier procedimiento almacenado específico en SQL Server.
USE AdventureWorks;
GO
SELECT name, create_date, modify_date
FROM sys.objects
WHERE type = 'P' -- P = procedimiento almacenado
AND name = 'nombre del objeto'
---------------------------------


-- enumerar todos los desencadenadores DML creados o modificados en los últimos N días en SQL Server.
SELECT
o.name as [Trigger Name],
CASE WHEN o.type = 'TR' THEN 'SQL DML Trigger'
     WHEN o.type = 'TA' THEN 'DML Assembly Trigger' END
     AS [Trigger Type],
sc.name AS [Schema_Name],
OBJECT_NAME(parent_object_id) as [Table Name],
o.create_date [Trigger Create Date], 
o.modify_date [Trigger Modified Date] 
FROM sys.objects o
INNER JOIN sys.schemas sc ON o.schema_id = sc.schema_id
WHERE (type = 'TR' OR type = 'TA')
AND ( DATEDIFF(D,create_date, GETDATE()) < 7 OR
    DATEDIFF(D,modify_date, GETDATE()) < 7) -- Last 7 days


-- reconstruye indices
	GO
EXEC sp_MSforeachtable @command1="print '?' DBCC DBREINDEX ('?', ' ', 80)"
GO
EXEC sp_updatestats


-- ver avances de procesos
SELECT session_id as SPID, command, a.text AS Query, start_time, 
percent_complete, dateadd(second,estimated_completion_time/1000, 
getdate()) as estimated_completion_time 
FROM sys.dm_exec_requests r CROSS APPLY 
     sys.dm_exec_sql_text(r.sql_handle) a 
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE',
                    'BACKUP LOG','DbccFilesCompact',
                    'DbccSpaceReclaim','DBCC')


-- espacio usado en una base de datos
sp_spaceused

select db_name() as dbname,
name as filename,
size/128.0 as currentsize,
size/128.0 - cast(fileproperty(name,'SpaceUsed') as int)/128.0 as freespace
from sys.database_files