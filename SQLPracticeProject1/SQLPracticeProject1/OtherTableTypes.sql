

--========================================================================
--	Description: Various Examples of SQL commands for other table types
--	Author: Tresa Varghese
--========================================================================


-- ---------------------------------------------
-- local temporary table
-- ---------------------------------------------
IF OBJECT_ID('tempdb..#LocalTempTable') IS NOT NULL
  DROP TABLE #LocalTempTable
GO

CREATE TABLE #LocalTempTable
(
   id    INT NOT NULL,
   fname VARCHAR(20)
)

-- Note multirow insert notation, this is new to SQL Server 2008

INSERT INTO #LocalTempTable
VALUES (1, 'Donabel'), (2, 'John')

SELECT * 
FROM #LocalTempTable



-- ---------------------------------------------
-- global temporary table
-- ---------------------------------------------
IF OBJECT_ID('tempdb..##GlobalTempTable') IS NOT NULL
  DROP TABLE ##GlobalTempTable
GO

CREATE TABLE ##GlobalTempTable
(
   id    INT NOT NULL,
   fname VARCHAR(20)
)
INSERT INTO ##GlobalTempTable
VALUES (1, 'Donabel'), (2, 'John')

SELECT * 
FROM ##GlobalTempTable


-- ---------------------------------------------
-- table variable
-- ---------------------------------------------
DECLARE @MyTable TABLE
(
   id    INT NOT NULL,
   fname VARCHAR(20)
)

INSERT INTO @MyTable
VALUES (1, 'Donabel'), (2, 'John')

SELECT * FROM @MyTable



-- ---------------------------------------------
-- derived table (or subquery)
-- ---------------------------------------------

USE AdventureWorks

SELECT 
   DerivedTable.*
FROM 
   (
      SELECT 
         FirstName + ' ' + LastName AS FullName, 
         CompanyName
      FROM Sales.Customer
   ) DerivedTable


   -- ---------------------------------------------
-- Common Table Expression
-- ---------------------------------------------
;WITH CustomerCTE (FullName, CompanyName)
AS
(
   SELECT 
      FirstName + ' ' + LastName, 
      CompanyName
   FROM SalesLT.Customer
)

SELECT * 
FROM CustomerCTE

-- ---------------------------------------------
-- view
-- ---------------------------------------------
IF OBJECT_ID('vCustomerInfo') IS NOT NULL
DROP VIEW vCustomerInfo
GO
CREATE VIEW vCustomerInfo
AS
   SELECT 
      FirstName + ' ' + LastName AS FullName, 
      CompanyName
   FROM SalesLT.Customer
GO

SELECT * 
FROM vCustomerInfo


-- ---------------------------------------------
-- Clean up
-- ---------------------------------------------
IF OBJECT_ID('tempdb..#LocalTempTable') IS NOT NULL
  DROP TABLE #LocalTempTable
GO

IF OBJECT_ID('tempdb..##GlobalTempTable') IS NOT NULL
  DROP TABLE ##GlobalTempTable
GO
