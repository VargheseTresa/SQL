

--===================================================================
--	Description: Various Examples of SQL commands for creating table
--	Author: Tresa Varghese
--===================================================================


-----------------------------------------------------
-- Example: CREATE TABLE all defaults
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price    DECIMAL(9,2)
)


-----------------------------------------------------
-- Example: CREATE TABLE with unnamed constraints
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50) DEFAULT 'Unnamed',
   categoryName   VARCHAR(50)
      CHECK (categoryName IN ('Plastic', 'Metal', 'Paper')),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2),
      CHECK (price > 0.0)
)


-----------------------------------------------------
-- Example: CREATE TABLE with named constraints
-----------------------------------------------------

IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50) 
      CONSTRAINT Default_Product DEFAULT 'Unnamed',
   categoryName   VARCHAR(50)
      CONSTRAINT CK_Product_categoryName CHECK (categoryName IN ('Plastic', 'Metal', 'Paper')),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2)
      CONSTRAINT CK_Product_Price CHECK (price > 0.0)
)


-----------------------------------------------------
-- Example: CREATE TABLE with table-level named constraints
-----------------------------------------------------

IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

-- table with column-level and table-level constraints
CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50)
     CONSTRAINT Default_Product 
    DEFAULT 'Unnamed',
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2),
   CONSTRAINT CK_Product_Price 
     CHECK (price > 0.0),
   CONSTRAINT CK_Product_categoryName 
     CHECK (categoryName IN ('Plastic', 'Metal', 'Paper'))
)

-----------------------------------------------------
-- CREATE TABLE with IDENTITY PK
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT IDENTITY(1,1) PRIMARY KEY,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2)
)


-----------------------------------------------------
-- CREATE TABLE with UNIQUEIDENTIFIER PK
-- not really recommended, unless it's automatically
-- created by SQL Server for replication purposes
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   UNIQUEIDENTIFIER PRIMARY KEY,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2)
)



-----------------------------------------------------
-- CREATE TABLE with table level PK
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2),
   PRIMARY KEY(productID)
)



-----------------------------------------------------
-- CREATE TABLE with composite PK
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Product' 
     AND     type = 'U')
    DROP TABLE Product
GO

CREATE TABLE Product 
(
   productID   INT,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2),
   CONSTRAINT PK_Product PRIMARY KEY(productID, productName)
)




-----------------------------------------------------
-- CREATE TABLE with column-level FK
-----------------------------------------------------

-- assume you have the following tables
-- Product with PK ProductID
-- Orders with PK OrderID

IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'Orders' 
     AND     type = 'U')
    DROP TABLE Orders
GO

CREATE TABLE Orders 
(
   orderID       int NOT NULL PRIMARY KEY,
   unitPrice     decimal(4,2) NOT NULL,
   quantity      int   
)

IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'OrderedProduct' 
     AND     type = 'U')
    DROP TABLE OrderedProduct
GO

CREATE TABLE OrderedProduct 
(
   orderID       int NOT NULL
      REFERENCES Orders (OrderID),
   productID     int NOT NULL
      REFERENCES Product (productID),
   quantity      int,
   price         decimal(9,2),
   PRIMARY KEY (orderID, productID)
)


-----------------------------------------------------
-- CREATE TABLE with table-level FK
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'OrderedProduct' 
     AND     type = 'U')
    DROP TABLE OrderedProduct
GO

-- with PK and FK
CREATE TABLE OrderedProduct 
(
   orderID       int NOT NULL,
   productID     int NOT NULL,
   quantity      int,
   price         decimal(9,2),
   PRIMARY KEY (orderID, productID),
   FOREIGN KEY (orderID)  REFERENCES Orders (orderID),
   FOREIGN KEY (productID)  REFERENCES Product (productID)
)



-----------------------------------------------------
-- CREATE TABLE with table-level FK
-----------------------------------------------------
IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'OrderedProduct' 
     AND     type = 'U')
    DROP TABLE OrderedProduct
GO

-- with PK and FK
CREATE TABLE OrderedProduct 
(
   orderID       int NOT NULL,
   productID     int NOT NULL,
   quantity      int,
   price         decimal(9,2),
   PRIMARY KEY (orderID, productID),
   CONSTRAINT FK_OrderedProduct_Orders 
     FOREIGN KEY (orderID)  REFERENCES Orders (orderID),
   CONSTRAINT FK_OrderedProduct_Product 
     FOREIGN KEY (productID)  REFERENCES Product (productID)
)



-----------------------------------------------------
-- CREATE TEMPORARY TABLE 
-----------------------------------------------------
IF OBJECT_ID('tempdb..#Product') IS NOT NULL
   DROP TABLE #Product
GO

CREATE TABLE #Product 
(
   productID   INT,
   productName VARCHAR(50),
   categoryName   VARCHAR(50),
   packageDesc VARCHAR(50),
   price DECIMAL(9,2)
   CONSTRAINT PK_Product PRIMARY KEY(productID, productName)
)

-- list temp tables
SELECT [name] 
FROM tempdb.sys.objects
WHERE [name] LIKE '#%'