


--========================================================================================
--	Description: Demonstratets the use of VIEWS
--
--	Author: Tresa Varghese
--========================================================================================


USE TSQL2016;
GO

-------------------------------------
-- Create a view
-------------------------------------

CREATE OR ALTER VIEW Sales.v_OrderTotals
WITH SCHEMABINDING
AS
   SELECT
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate
      , qty = SUM(OD.qty)
      , val = CAST(SUM(OD.qty * OD.unitprice * (1 - OD.discount)) AS NUMERIC(12, 2))
   FROM Sales.Orders AS O
      INNER JOIN Sales.OrderDetails AS OD
         ON O.orderid = OD.orderid
   GROUP BY
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate;
GO

/* 
SCHEMABINDING prevents structural changes on underlying tables while the view exists
*/

-- now, select or read the contents of the VIEW

SELECT 
     orderid
   , orderdate
   , custid
   , empid
   , val
FROM Sales.v_OrderTotals;
GO

------------------------------------------------------------
--  Controling data access with a view
------------------------------------------------------------

--The following view only list customers from US

CREATE OR ALTER VIEW Sales.v_USACusts
	WITH SCHEMABINDING
AS
   SELECT
        custid
      , companyname
      , contactname
      , contacttitle
      , address
      , city
      , region
      , postalcode
      , country
      , phone
      , fax
   FROM Sales.Customers
   WHERE country = N'USA';
GO

-- Try it
SELECT *
FROM Sales.v_USACusts;

------------------------------------------
-- Use of SCHEMABINDING
------------------------------------------

-- Try with SCHEMABINDING
BEGIN TRAN;
   ALTER TABLE Sales.Customers DROP COLUMN address;
ROLLBACK TRAN; -- undo change
GO
/*
This leads to error as SCHEMABINDING in Sales.v_USACusts object prevents changes on underlying table
used in the view
*/

--Also try without schemabinding

CREATE OR ALTER VIEW Sales.v_USACusts
--WITH SCHEMABINDING
AS
   SELECT
        custid
      , companyname
      , contactname
      , contacttitle
      , address
      , city
      , region
      , postalcode
      , country
      , phone
      , fax
   FROM Sales.Customers
   WHERE country = N'USA';
GO

BEGIN TRAN;
   ALTER TABLE Sales.Customers DROP COLUMN address;
ROLLBACK TRAN; -- undo change
GO


------------------------------------------
-- Use of ENCRYPTION
------------------------------------------

-- Usually, we can get object's definition as follows:

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.v_USACusts'));
GO

-- To prevent object's definition being displayed like that, use ENCRYPTION attribute

CREATE OR ALTER VIEW Sales.v_USACusts
	WITH SCHEMABINDING, ENCRYPTION
AS
   SELECT
        custid
      , companyname
      , contactname
      , contacttitle
      , address
      , city
      , region
      , postalcode
      , country
      , phone
      , fax
   FROM Sales.Customers
   WHERE country = N'USA';
GO

--Now try to check definition. It returns NULL.

SELECT OBJECT_DEFINITION(OBJECT_ID(N'Sales.v_USACusts'));
GO


---------------------------------------------------------------
--				Modifying data through views
---------------------------------------------------------------

--	First, create view

CREATE OR ALTER VIEW Sales.v_USACusts
WITH SCHEMABINDING
AS
   SELECT
        custid
      , companyname
      , contactname
      , contacttitle
      , address
      , city
      , region
      , postalcode
      , country
      , phone
      , fax
   FROM Sales.Customers
   WHERE country = N'USA';
GO


-- Add new record in Sales.Customers table using a view
INSERT INTO Sales.v_USACusts
(
     companyname
   , contactname
   , contacttitle
   , address
   , city
   , region
   , postalcode
   , country
   , phone
   , fax
)
VALUES
(
     N'Customer AAAAA'
   , N'Contact AAAAA'
   , N'Title AAAAA'
   , N'Address AAAAA'
   , N'Redmond'
   , N'WA'
   , N'11111'
   , N'USA'
   , N'111-1111111'
   , N'111-1111111'
);

/*
 Now let's see the last inserted record
 Use SCOPE_IDENTITY() function to get  the last identity value inserted
 */


SELECT custid, companyname, country
FROM Sales.Customers
WHERE custid = SCOPE_IDENTITY();


-- Normally, we can add row through view that contradicts the inner query's filter.
-- Example, trying to add a Non US cx

INSERT INTO Sales.v_USACusts
(
     companyname
   , contactname
   , contacttitle
   , address
   , city
   , region
   , postalcode
   , country
   , phone
   , fax
)
VALUES
(
     N'Customer CCCCC'
   , N'Contact CCCCC'
   , N'Title CCCCC'
   , N'Address CCCCC'
   , N'London'
   , NULL
   , N'33333'
   , N'UK'
   , N'333-3333333'
   , N'333-3333333'
);

-- Check original table

SELECT custid, companyname, country
FROM Sales.Customers
WHERE custid = SCOPE_IDENTITY();

-- Check view

SELECT custid, companyname, country
FROM Sales.v_USACusts
WHERE custid = SCOPE_IDENTITY();



-------------------------------------------------------------------
--		Use of CHECK OPTION
-------------------------------------------------------------------

-- Alter the view to include CHECK OPTION and try

CREATE OR ALTER VIEW Sales.v_USACusts
WITH SCHEMABINDING
AS
   SELECT
        custid
      , companyname
      , contactname
      , contacttitle
      , address
      , city
      , region
      , postalcode
      , country
      , phone
      , fax
   FROM Sales.Customers
   WHERE country = N'USA'
   WITH CHECK OPTION;
GO

-- Let's break it
INSERT INTO Sales.v_USACusts
(
     companyname
   , contactname
   , contacttitle
   , address
   , city
   , region
   , postalcode
   , country
   , phone
   , fax
)
VALUES
(
     N'Customer CCCCC'
   , N'Contact CCCCC'
   , N'Title CCCCC'
   , N'Address CCCCC'
   , N'London'
   , NULL
   , N'33333'
   , N'UK'
   , N'333-3333333'
   , N'333-3333333'
);
GO
--The abve insert leads to error as it conflicts with the inner query's filter


-------------------------------------------------------------------------------
--						INDEXED VIEWS
-------------------------------------------------------------------------------

-- Create a view 

CREATE OR ALTER VIEW Sales.v_OrderTotals
WITH SCHEMABINDING
AS
   SELECT
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate
      , qty = SUM( OD.qty )
      , val = CAST( SUM( OD.qty * OD.unitprice * ( 1 - OD.discount ) ) AS NUMERIC(12, 2))
   FROM Sales.Orders AS O
      INNER JOIN Sales.OrderDetails AS OD
         ON O.orderid = OD.orderid
   GROUP BY
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate;
GO


-- First index on a view muct be unique and clustered
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid 
   ON Sales.v_OrderTotals(orderid);
GO

-- Since above doesn't like us, we will modify 
-- our view by adding missing COUNT_BIG function
CREATE OR ALTER VIEW Sales.v_OrderTotals
WITH SCHEMABINDING
AS
   SELECT
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate
      , qty           = SUM( OD.qty )
      , val           = CAST( SUM( OD.qty * OD.unitprice * ( 1 - OD.discount ) ) AS NUMERIC(12, 2))
      , numorderlines = COUNT_BIG(*) -- This one is needed
   FROM Sales.Orders AS O
      INNER JOIN Sales.OrderDetails AS OD
         ON O.orderid = OD.orderid
   GROUP BY
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate;
GO


-- Try to create an index, using the same code
CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid 
   ON Sales.v_OrderTotals(orderid);
GO
-- fix the other issue
CREATE OR ALTER VIEW Sales.v_OrderTotals
	WITH SCHEMABINDING
AS
   SELECT
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate
      , qty           = SUM( OD.qty )
      -- We need to remove casting to NUMERIC(12, 2))
      , val           = SUM(OD.qty * OD.unitprice * (1 - OD.discount))
      , numorderlines = COUNT_BIG(*)
   FROM Sales.Orders AS O
      INNER JOIN Sales.OrderDetails AS OD
         ON O.orderid = OD.orderid
   GROUP BY
        O.orderid
      , O.custid
      , O.empid
      , O.shipperid
      , O.orderdate
      , O.requireddate
      , O.shippeddate;
GO

CREATE UNIQUE CLUSTERED INDEX idx_cl_orderid 
   ON Sales.v_OrderTotals(orderid);
GO