IF NOT EXISTS (SELECT name From sys.databases WHERE name = N'miniBD')
BEGIN
	CREATE DATABASE miniBD
	COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END
Go

USE miniBD;
go

--Creación de tablas
IF OBJECT_ID ('clientes', 'U') IS NOT NULL DROP TABLE clientes;

CREATE TABLE clientes(
 IdCliente INT NOT NULL,
 Nombre NVARCHAR(100),
 Edad INT,
 Ciudad NVARCHAR(100),
 CONSTRAINT pk_clientes
 PRIMARY KEY (idcliente)
);
go

IF OBJECT_ID ('productos', 'U') IS NOT NULL DROP TABLE productos;

CREATE TABLE productos(
 Idproducto int primary key,
 NombreProducto NVARCHAR(200),
 Categoria NVARCHAR(200),
 Precio DECIMAL(12,2)
);
GO

/*
 ====================== Inserción de regristros en las tablas =================
 */


 INSERT INTO clientes
 VALUES(1, 'Ana Torres', 25, 'Ciudad de México');

 INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
 VALUES(2, 'Luis Perez', 34, 'Guadalajara');

 INSERT INTO clientes (IdCliente, Edad, Nombre, Ciudad)
 VALUES (3, 29, 'Soyla Vaca', NULL);

 INSERT INTO clientes (IdCliente, Nombre, Edad)
 VALUES (4, 'Natacha', 41);

 INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
 VALUES (5, 'Sofia Lopez', 19, 'Chapulhuacan'),
		(6, 'Laura Hernandez', 38, NULL),
		(7, 'Victor Trujillo', 25, 'Zacualtipan');
GO

CREATE OR ALTER PROCEDURE sp_add_customer
@Id INT, @Nombre NVARCHAR (100), @edad INT, @ciudad NVARCHAR (100)
AS
BEGIN
	INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
	VALUES (@Id, @Nombre, @edad, @ciudad);
END;
GO

EXEC sp_add_customer 8, 'Carlos Ruiz', 41, 'Monterrey';
EXEC sp_add_customer 9, 'Jose Angel Perez', 41, 'Salte si Puedes';

SELECT * 
FROM clientes;

SELECT COUNT(*) AS [Numero de Clientes]
FROM clientes;

--Mostrar todos los clientes ordenados por edad de menor a mayor
SELECT UPPER (Nombre) AS [Cliente], edad, UPPER (Ciudad) AS [Ciudad]
FROM clientes
ORDER BY Edad DESC;

--Listar los clientes que viven en Guadalajara
SELECT UPPER (Nombre) AS [Cliente], edad, UPPER (Ciudad) AS [Ciudad]
FROM clientes
WHERE Ciudad = 'Guadalajara';

--Listar los clientes con una edad mayor o igual a 30
SELECT UPPER (Nombre) AS [Cliente], edad, UPPER (Ciudad) AS [Ciudad]
FROM clientes
WHERE Edad >= 30;

--Listar los clientes cuya ciudad sea nula
SELECT UPPER (Nombre) AS [Cliente], edad, UPPER (Ciudad) AS [Ciudad]
FROM clientes
WHERE Ciudad IS NULL;

--Reeplaxar en la consulta las ciudades nulas por la palabra DESCONOCIDA 
--(sin modificar los datos originales)
SELECT UPPER (Nombre) AS [Cliente], edad, 
ISNULL (UPPER (ciudad), 'DESCONOCIDO') AS [ciudad]
FROM clientes;

SELECT UPPER (Nombre) AS [Cliente], edad, 
ISNULL (UPPER (ciudad), 'DESCONOCIDO') AS [ciudad]
FROM clientes
WHERE Edad BETWEEN 20 AND 35
	  AND
	  Ciudad IN ('Guadalajara', 'Chapulguacan');

/*
==================== Actualización de Datos ===========================
*/

SELECT * 
FROM clientes;

UPDATE clientes
SET Ciudad = 'Xochitlan'
WHERE IdCliente = 5;

UPDATE clientes
SET Ciudad = 'Sin ciudad'
WHERE Ciudad IS NULL;

UPDATE clientes
SET Edad = 30
WHERE IdCliente BETWEEN 3 AND 6;

UPDATE clientes
SET Ciudad = 'Metropoli'
WHERE Ciudad IN ('ciudad de México', 'Guadalajara', 'Monterrey');

UPDATE clientes
SET Nombre = 'Juan Perez',
	Edad = 27,
	Ciudad = 'Ciudad Gotica'
WHERE IdCliente = 2;

UPDATE clientes
SET Nombre = 'Cliente Premiun'
WHERE Nombre LIKE 'A%';

UPDATE clientes
SET Nombre = 'Silver customer'
WHERE Nombre LIKE 'er%';

UPDATE clientes
SET Edad = (Edad * 2)
WHERE Edad >= 30 AND Ciudad = 'Metropili';

/*
==================== Eliminación de Datos ===========================
*/

SELECT * 
FROM clientes;

DELETE FROM clientes
WHERE Edad BETWEEN 25 AND 30;

DELETE clientes
WHERE Nombre LIKE '%r';

TRUNCATE TABLE clientes;

/*
=================== Store prosedures de update, delete y select ========================
*/

-- MODIFICA LOS DATOS POR ID
CREATE OR ALTER PROCEDURE sp_update_customers
	@id INT,
	@nombre NVARCHAR(100),
	@edad INT,
	@ciudad NVARCHAR(100)
AS
BEGIN
	UPDATE cliente 
	SET NombreCliente = @nombre,
		Edad = @edad,
		Ciudad = @ciudad
	WHERE IdCliente = @id;
END;
GO

EXEC sp_update_customers 
7, 'Benito Kano', 24, 'Lima los Pies'

EXEC sp_update_customers 
@ciudad = 'Martinez de la Torre', 
@edad = 56, @id = 3, 
@nombre = 'Toribio Trompudo';

-- Ejercicio completo donde se pueda insertar datos en una tabla 
-- principal (Encabezado) y una tabla detalle utilizando un sp.

-- Tabla principal
CREATE TABLE Ventas(
IdVenta INT IDENTITY (1,1) PRIMARY KEY,
FechaVenta DATETIME NOT NULL DEFAULT GETDATE(),
Cliente NVARCHAR (100) NOT NULL,
Total DECIMAL (10,2) NULL
);

--Tabla detalle
CREATE TABLE DetalleVenta(
IdDetalle INT IDENTITY (1,1) PRIMARY KEY,
IdVenta INT NOT NULL,
Producto NVARCHAR (100) NOT NULL,
Cantidad INT NOT NULL,
Precio DECIMAL (10,2) NOT NULL,
CONSTRAINT pk_Detalle_venta
FOREIGN KEY (IdVenta)
REFERENCES Ventas(IdVenta)
);

-- Crear un tio de tabla (Table Type)

-- Este tipo de tabla servirá como estructura para enviar los
-- detalles al sp

CREATE TYPE TipoDetalleVentas AS TABLE(
	Producto NVARCHAR (100),
	Cantidad INT,
	Precio DECIMAL (10,2)
);

GO
-- Crear el STORE PROCEDURE
-- El sp insertara el encabezado y luego todos los detalles
-- Utilizando el tipo de tabla

CREATE OR ALTER PROCEDURE InsertarVentasConDetalle
@Cliente nvarchar (100),
@Detalles TipoDetalleVentas READONLY
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IdVenta INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Insertaren la tabla principal
		INSERT INTO Ventas (Cliente)
		VALUES (@Cliente);

		-- Obtener el ID recien generado
		SET @IdVenta = SCOPE_IDENTITY();

		-- Insertar los detalles (Tabla detalles)
		INSERT INTO DetalleVenta (IdVenta, Producto, Cantidad, Precio)
		SELECT @IdVenta, Producto, Cantidad, Precio
		FROM @Detalles;

		-- Calcular el total de venta
		UPDATE Ventas
		SET Total = (SELECT SUM(Cantidad * Precio) FROM @Detalles)
		WHERE IdVenta = @IdVenta;

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH;
END;
GO

-- Ejecutar el sp con datos de prueba

-- Declarar una variable tipo tabla
DECLARE @MisDetalles AS TipoDetalleVentas

-- Insertar productos en el Type Table
INSERT INTO @MisDetalles (Producto, Cantidad, Precio)
VALUES
('Laptop', 1, 15000),
('Mause', 2, 300),
('Teclado', 1, 500),
('Pantalla', 5, 4500);

-- Ejecutar el SP
EXEC InsertarVentasConDetalle @Cliente = 'Uriel Edgar', @Detalles = @MisDetalles
GO

SELECT * FROM Ventas;
SELECT * FROM DetalleVenta;

-- Funciones integradas

-- Funciones de cadena
SELECT
Nombre AS [Nombre Fuente],
LTRIM(UPPER(Nombre)) AS Mayusculas,
LOWER(Nombre) AS Minusculas,
LEN(Nombre) AS Longitud,
SUBSTRING(Nombre, 1, 3) AS Prefijo,
LTRIM(Nombre) AS [Sin Espacios Izquierda],
CONCAT(Nombre, ' - ', Edad) AS [Nombre Edad],
UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Normal]
FROM clientes;

SELECT * FROM clientes

INSERT INTO clientes(IdCliente, Nombre, Edad, Ciudad)
VALUES (8, 'Luis López', 45, 'Achichilco');

INSERT INTO clientes(IdCliente, Nombre, Edad, Ciudad)
VALUES (9, ' German Galindo', 32, 'Achichilco 2 ');

INSERT INTO clientes(IdCliente, Nombre, Edad, Ciudad)
VALUES (10, ' Jael Porfirio', 19, 'Achichilco 3 ');

INSERT INTO clientes(IdCliente, Nombre, Edad, Ciudad)
VALUES (11, ' Roberto Estrada   ', 19, 'Chapulhuacan');

-- Crear una tabla apartir de una consulta
SELECT TOP 0
idCliente,
Nombre AS [Nombre Fuente],
LTRIM(UPPER(Nombre)) AS Mayusculas,
LOWER(Nombre) AS Minusculas,
LEN(Nombre) AS Longitud,
SUBSTRING(Nombre, 1, 3) AS Prefijo,
LTRIM(Nombre) AS [Sin Espacios Izquierda],
CONCAT(Nombre, ' - ', Edad) AS [Nombre Edad],
UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Normal]
INTO stage_clientes
FROM clientes;

-- Agrega un constraint a la tabla (primary key)
ALTER TABLE stage_clientes
ADD CONSTRAINT pk_stage_clientes
PRIMARY KEY(idCliente);

SELECT * FROM
stage_clientes;

-- Insertar datos a partir de una consulta
INSERT INTO stage_clientes (IdCliente,
							[Nombre Fuente],
							Mayusculas,
							Minusculas,
							Longitud,
							Prefijo,
							[Sin Espacios Izquierda],
							[Nombre Edad], [Ciudad Normal])
SELECT
idCliente,
Nombre AS [Nombre Fuente],
LTRIM(UPPER(Nombre)) AS Mayusculas,
LOWER(Nombre) AS Minusculas,
LEN(Nombre) AS Longitud,
SUBSTRING(Nombre, 1, 3) AS Prefijo,
LTRIM(Nombre) AS [Sin Espacios Izquierda],
CONCAT(Nombre, ' - ', Edad) AS [Nombre Edad],
UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Normal]
FROM clientes;

SELECT * FROM clientes;

-- Funciones de Fecha

SELECT * FROM Ventas;

/* USE NORTHWIND;
GO
SELECT
OrderDate,
GETDATE AS [Fecha Actual],
DATEADD (DAY, 10, Orderdate) AS [Fecha Actual],
DATEPART(QUEARTER, Orderdate) AS [Trimestre],
DATEPART(MONTH, Orderdate) AS [Mes con numero],
DATENAME(MONTH, Orderdate) AS [Mes con nombre],
DATENAME(WEEKDAY, Orderdate) AS [Nombre día],
DATEDIFF(DAY, Orderdate, GETDATE()) AS [Dias transcurriodos],
DATEDIFF(YEAR, Orderdate, GETDATE()) AS [Años transcurridos],
DATEFIFF(YEAR, '2003-07-13', GETDATE()) AS [EdadJaen],
DATEFIFF(YEAR, '1979-07-13', GETDATE()) AS [EdadJaen],
FROM Orders;
*/

-- Manejo de valores nulos
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    SecondaryEmail NVARCHAR(100),
    Phone NVARCHAR(20),
    Salary DECIMAL(10,2),
    Bonus DECIMAL(10,2)
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Email, SecondaryEmail,
					   Phone, Salary, Bonus)
VALUES (1, 'Ana', 'Lopez', 'ana.lopez@empresa.com',NULL,'555-2345', 12000, 100),
       (2, 'Carlos', 'Ramirez', NULL, 'c.ramirez@empresa.com', NULL, 9500, NULL),
       (3, 'Laura', 'Gomez', NULL, NULL, '555-8900', 0, 500),
       (4, 'Jorge', 'Diaz', 'jorge.diaz@empresa.com', NULL, NULL, 15000, 0);

-- Ejercicio 1 - ISNULL
-- Mostrar el nombre completo del empleado junto con su número de telefono,
-- si no tiene telefono, mostrar el texto "No disponible"

SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name],
	   ISNULL(phone, 'No disponible') AS [Phone] 
FROM Employees;

-- Ejercicio 2. Mostrar el nombre del empleado y su correo de contacto

SELECT CONCAT(FirstName, ' ', LastName) AS [Nombre Completo], 
	   email,
	   SecondaryEmail,
	   COALESCE(Email, SecondaryEmail, 'Sin correo') AS [Correo Contacto]
FROM Employees
;

-- Ejercicio 3. NULLIF
-- Mostrar el nombre del empleado, susalario y el resultado de 
-- NULLIF(salary, 0) para detectar quien tiene salario cero

SELECT 
	  CONCAT(FirstName, ' ', LastName) AS [Nombre Completo],
	  Salary,
	  NULLIF(Salary, 0) AS [Salario Evaluable]
FROM Employees;

-- Evita error de division por cero:

SELECT FirstName,
	   Bonus,
	   (Bonus/NULLIF(Salary, 0)) AS [Bonus Salario] 
FROM Employees;

-- Expreciones condcicionales Case

-- Permite crear condiciones dentro de una consulta

-- Sintaxis
SELECT
	UPPER(CONCAT(FirstName, ' ', LastName)) AS [Full Name],
	ROUND(Salary, 2) AS [Salario],
	CASE
		WHEN ROUND(Salary, 2) >= 10000 THEN 'Alto'
		WHEN ROUND(Salary, 2) BETWEEN 5000 AND 9999 THEN 'Medio'
		ELSE 'BAJO'
	END AS [Nivel Salarial]
FROM Employees;

-- Combinar funciones y CASE

-- Seleccionar el nombre del producto, la fecha de la orden, telefono
-- Nombre del cliente en mayusculas, validar si el telefono
-- es NULL, poner la palabra no disponible,
-- Comprobar la fecha de la orden restando los dias de la fecha de orden
-- con respecto al fecha de hoy, si estos dias son menores a 30 entonces,
-- mostrar la palabra recientes y si no auntiguo, el campo debe llamarse Estado de
-- pedido, utilisa la bd northwind.

use Northwind

SELECT UPPER(c.CompanyName) AS [Nombre Cliente],
ISNULL(c.Phone, 'No Disponible') AS [Telefono],
p.ProductName,
CASE
    WHEN DATEDIFF(day, o.OrderDate, GETDATE()) <  30 THEN 'Reciente'
    ELSE 'Antiguo'
END AS [Estado del Pedido]
INTO tablaformateada
FROM ( Select customerId, companyName, Phone From Customers) AS c
INNER JOIN ( SELECT OrderID, CustomerID ,OrderDate FROM Orders) AS o
ON c.CustomerID = o.CustomerID
INNER JOIN ( SELECT ProductID, OrderID FROM [Order Details] ) AS od
ON o.OrderID = od.OrderID
INNER JOIN ( SELECT ProductID, ProductName FROM Products) AS p
ON p.ProductID = od.ProductID;

CREATE OR ALTER VIEW v_pedidosAntiguos
AS

SELECT [Nombre Cliente], ProductName
FROM tablaformateada
WHERE [Estado del Pedido] = 'Antiguo';

-- Selecionar el nombre completo del empleado, seleccionar el correo disponible
-- utilizando un COALESCE, comprobar si el telefono es NULL si es asi
-- poner la palabra no disponible, tamien validar el bonus si es NULL obligarlo
-- a ser cero y si es creo poner la palabra sin bono, y si no es cero
-- concatenar el bonus anteponiendo el simbolo de $

