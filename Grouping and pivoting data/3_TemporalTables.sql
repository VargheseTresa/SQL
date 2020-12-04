


--========================================================================================
--	Description: Demonstratets use of temporal tables
--	Author: Tresa Varghese
--========================================================================================

USE TSQL2016;
Go



-------------------------------------------------------------------------
--			Create temporal tables
-------------------------------------------------------------------------


--      1. Create brand new temporal table

CREATE TABLE dbo.Products
(
     productid INT NOT NULL 
      CONSTRAINT PK_dboProducts PRIMARY KEY(productid)
   , productname NVARCHAR(40) NOT NULL
   , supplierid INT NOT NULL
   , categoryid INT NOT NULL
   , unitprice MONEY NOT NULL
   -- below are additions related to temporal table
   , validfrom DATETIME2(3)
      GENERATED ALWAYS AS ROW START HIDDEN NOT NULL -- HIDDEN option!!!
   , validto DATETIME2(3)
      GENERATED ALWAYS AS ROW END HIDDEN NOT NULL -- HIDDEN option for this one as well!!!
   , PERIOD FOR SYSTEM_TIME (validfrom, validto)
)
WITH 
( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.ProductsHistory ) );



-- clean up

-- Drop existing...
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
   BEGIN
      IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Products', N'U'), N'TableTemporalType') = 2
      ALTER TABLE dbo.Products SET ( SYSTEM_VERSIONING = OFF );
      DROP TABLE IF EXISTS dbo.ProductsHistory, dbo.Products;
   END;

-- ...and create a new, regular table
CREATE TABLE dbo.Products
(
     productid INT NOT NULL 
      CONSTRAINT PK_dboProducts PRIMARY KEY(productid)
   , productname NVARCHAR(40) NOT NULL
   , supplierid INT NOT NULL
   , categoryid INT NOT NULL
   , unitprice MONEY NOT NULL
);


--		2. Create temporal table by altering existing table

--The above created regular table can be changed to temporal table as follows

BEGIN TRAN;

   -- First add columns for start and end of validity
   ALTER TABLE dbo.Products 
   ADD
        validfrom DATETIME2(3) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL
         CONSTRAINT DFT_Products_validfrom DEFAULT('19000101')
      , validto DATETIME2(3) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL
         CONSTRAINT DFT_Products_validto DEFAULT('99991231 23:59:59.999')
      , PERIOD FOR SYSTEM_TIME (validfrom, validto);

   -- Now make it system-versioning table
   ALTER TABLE dbo.Products
   SET ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.ProductsHistory ) );
   

   ALTER TABLE dbo.Products DROP CONSTRAINT DFT_Products_validfrom, DFT_Products_validto;
COMMIT TRAN;


----------------------------------------------------------------
--			Altering Temporal Table
----------------------------------------------------------------

--		1. Adding a column

-- Along with the column, add a default constraint to add values to 
-- existing rows.

ALTER TABLE dbo.Products
	ADD discontinued BIT NOT NULL                    -- New column with default value is also added to history table by SQL Server
	CONSTRAINT DFT_Products_discontinued DEFAULT(0); -- Constraint is NOT added to the history table


--		2. Dropping a column

-- If you remove (delete) column from a temporal table
-- same columns will be removed from the history table as well


ALTER TABLE dbo.Products
DROP CONSTRAINT DFT_Products_discontinued; -- First we drop default constraint 

-- Now remove column
ALTER TABLE dbo.Products
DROP COLUMN discontinued;


----------------------------------------------------------------------
--			Modifying Data
----------------------------------------------------------------------

--		1. Insert some data into temporal table

INSERT INTO dbo.Products
(
     productid
   , productname
   , supplierid
   , categoryid
   , unitprice
)
SELECT
     productid
   , productname
   , supplierid
   , categoryid
   , unitprice
FROM Production.Products
WHERE productid <= 10;

SELECT *
FROM dbo.Products;

-- Validity columns got to be explicitly 
-- specified in select statement

SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

-- Now check a content of history table
SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;

-- No rows are inserted into history table when data is inserted



--		2. Delete data from temporal table

-- Deletion will be logged in history table by SQL server

DELETE FROM dbo.Products
WHERE productid = 10;

-- Check the content of both tables
SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;


--		3. Updating data in the temporal table


UPDATE dbo.Products
   SET unitprice *= 1.05
WHERE supplierid = 3;

-- Products 6, 7 and 8 are affected
-- Check the content of both tables again
SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;




------------------------------------------------------------------------
--		Multiple modifications within same transaction with delays
------------------------------------------------------------------------

-- Even with some delays within transaction, 
-- actual transaction date/time is recorded

BEGIN TRAN;
   -- Check a current date/time (in UTC)
   PRINT CAST(SYSUTCDATETIME() AS DATETIME2(3));

   -- First update
   UPDATE dbo.Products
      SET unitprice *= 0.95
   WHERE productid = 1;

   -- Wait 5 seconds
   WAITFOR DELAY '00:00:05.000';

   -- Second update
   UPDATE dbo.Products
      SET unitprice *= 0.90
   WHERE productid = 2;

   -- Wait yet another 5 seconds
   WAITFOR DELAY '00:00:05.000';

   -- Third one
   UPDATE dbo.Products
      SET unitprice *= 0.85
   WHERE productid = 3;

COMMIT TRAN;

-- Let's see what do we have in tables
SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;

/* 
For all updates within the same transaction, same time is recorded 
*/


------------------------------------------------------------------------
--		Update same row multiple times within a transaction with delays
------------------------------------------------------------------------

BEGIN TRAN;

   -- Check a current date/time (in UTC)
   PRINT CAST(SYSUTCDATETIME() AS DATETIME2(3));

   -- First update
   UPDATE dbo.Products
      SET unitprice = 1.0
   WHERE productid = 9;

   -- 5 seconds delay
   WAITFOR DELAY '00:00:05.000';

   -- Second one
   UPDATE dbo.Products
      SET unitprice = 2.0
   WHERE productid = 9;

   -- yet another delay
   WAITFOR DELAY '00:00:05.000';

   -- and a third one
   UPDATE dbo.Products
      SET unitprice = 3.0
   WHERE productid = 9;

COMMIT TRAN;

-- Now check what do we have in tables
SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;

/*
2020-12-03 23:34:02.286
The same validfrom and validto values for intermediate updates
*/


-------------------------------------------------------------------------
--				Querying data
--------------------------------------------------------------------------


-- To query both main and history table in a single statement 
-- we need to:

-- 1. Drop tables if exist
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
   BEGIN
      IF OBJECTPROPERTY(OBJECT_ID(N'dbo.Products', N'U'), N'TableTemporalType') = 2
         ALTER TABLE dbo.Products SET ( SYSTEM_VERSIONING = OFF );
      DROP TABLE IF EXISTS dbo.ProductsHistory, dbo.Products;
   END;
-- End IF...
GO

-- 2. Create and populate Products table
CREATE TABLE dbo.Products
(
     productid INT NOT NULL
      CONSTRAINT PK_dboProducts PRIMARY KEY(productid)
   , productname NVARCHAR(40) NOT NULL
   , supplierid INT NOT NULL
   , categoryid INT NOT NULL
   , unitprice MONEY NOT NULL
   , validfrom DATETIME2(3) NOT NULL
   , validto DATETIME2(3) NOT NULL
);

INSERT INTO dbo.Products
(productid, productname, supplierid, categoryid, unitprice, validfrom, validto)
VALUES
(1, 'Product HHYDP', 1, 1, 17.10, '20161101 14:10:43.470', '99991231 23:59:59.999'),
(2, 'Product RECZE', 1, 1, 17.10, '20161101 14:10:43.470', '99991231 23:59:59.999'),
(3, 'Product IMEHJ', 1, 2, 8.50, '20161101 14:10:43.470', '99991231 23:59:59.999'),
(4, 'Product KSBRM', 2, 2, 22.00, '20161101 14:07:26.263', '99991231 23:59:59.999'),
(5, 'Product EPEIM', 2, 2, 21.35, '20161101 14:07:26.263', '99991231 23:59:59.999'),
(6, 'Product VAIIV', 3, 2, 26.25, '20161101 14:09:18.584', '99991231 23:59:59.999'),
(7, 'Product HMLNI', 3, 7, 31.50, '20161101 14:09:18.584', '99991231 23:59:59.999'),
(8, 'Product WVJFP', 3, 2, 42.00, '20161101 14:09:18.584', '99991231 23:59:59.999'),
(9, 'Product AOZBW', 4, 6, 3.00, '20161101 14:11:38.113', '99991231 23:59:59.999');

-- 3. Create and populate ProductsHistory table
CREATE TABLE dbo.ProductsHistory
(
     productid INT NOT NULL
   , productname NVARCHAR(40) NOT NULL
   , supplierid INT NOT NULL
   , categoryid INT NOT NULL
   , unitprice MONEY NOT NULL
   , validfrom DATETIME2(3) NOT NULL
   , validto DATETIME2(3) NOT NULL
   , INDEX ix_ProductsHistory CLUSTERED(validto, validfrom)
      WITH (DATA_COMPRESSION = PAGE)
);

INSERT INTO dbo.ProductsHistory
(productid, productname, supplierid, categoryid, unitprice, validfrom, validto)
VALUES
( 1, 'Product HHYDP', 1, 1, 18.00, '20161101 14:07:26.263', '20161101 14:10:43.470'),
( 2, 'Product RECZE', 1, 1, 19.00, '20161101 14:07:26.263', '20161101 14:10:43.470'),
( 3, 'Product IMEHJ', 1, 2, 10.00, '20161101 14:07:26.263', '20161101 14:10:43.470'),
( 6, 'Product VAIIV', 3, 2, 25.00, '20161101 14:07:26.263', '20161101 14:09:18.584'),
( 7, 'Product HMLNI', 3, 7, 30.00, '20161101 14:07:26.263', '20161101 14:09:18.584'),
( 8, 'Product WVJFP', 3, 2, 40.00, '20161101 14:07:26.263', '20161101 14:09:18.584'),
( 9, 'Product AOZBW', 4, 6, 97.00, '20161101 14:07:26.263', '20161101 14:11:38.113'),
( 9, 'Product AOZBW', 4, 6, 1.00, '20161101 14:11:38.113', '20161101 14:11:38.113'),
( 9, 'Product AOZBW', 4, 6, 2.00, '20161101 14:11:38.113', '20161101 14:11:38.113'),
(10, 'Product YHXGE', 4, 8, 31.00, '20161101 14:07:26.263', '20161101 14:08:41.758');

-- 4. Enable system versioning
ALTER TABLE dbo.Products ADD PERIOD FOR SYSTEM_TIME (validfrom, validto);
ALTER TABLE dbo.Products ALTER COLUMN validfrom ADD HIDDEN;
ALTER TABLE dbo.Products ALTER COLUMN validto ADD HIDDEN;
ALTER TABLE dbo.Products
   SET ( SYSTEM_VERSIONING = ON ( HISTORY_TABLE = dbo.ProductsHistory ) );

-- Now we can retrieve data from the main...
SELECT 
     productid
   , supplierid
   , unitprice
   , validfrom
   , validto
FROM dbo.Products;

-- ...and from history table
SELECT 
     productid
   , unitprice
   , validfrom
   , validto
FROM dbo.ProductsHistory;

SELECT productid, supplierid, unitprice
FROM dbo.Products FOR SYSTEM_TIME AS OF '20161101 14:06:00.000';

-- Same query, getting data after first and before next insertation
SELECT productid, supplierid, unitprice
FROM dbo.Products FOR SYSTEM_TIME AS OF '20161101 14:07:55.000';

-- You can also combine multiple instances from the same table
SELECT 
     T1.productid
   , T1.productname
   , pct = CAST( (T2.unitprice / T1.unitprice - 1.0) * 100.0 AS NUMERIC(10, 2) )
FROM dbo.Products FOR SYSTEM_TIME AS OF '20161101 14:08:55.000' AS T1
   INNER JOIN dbo.Products FOR SYSTEM_TIME AS OF '20161101 14:10:55.000' AS T2
      ON T1.productid = T2.productid
      AND T2.unitprice > T1.unitprice;

