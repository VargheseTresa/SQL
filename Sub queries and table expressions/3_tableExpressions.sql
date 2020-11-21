



--========================================================================================
--	Description: Demonstratets the use of table expressions
--	Author: Tresa Varghese
--========================================================================================



------------------------------------------------------------------------------------------
--		1. DERIVED TABLES
------------------------------------------------------------------------------------------

USE TSQL2016;
GO

-- List all products and their unit price, by category using ROW_NUMBER() function

SELECT
     rownum = ROW_NUMBER() 
      OVER
      (
         PARTITION BY categoryid
         ORDER BY 
              unitprice
            , productid
      ) 
   , categoryid
   , productid
   , productname
   , unitprice
FROM Production.Products;


-- get two cheapest products from each category

SELECT 
	categoryid,
	productid,
	productname,
	unitprice
FROM 
(
	SELECT 
	ROW_NUMBER()
		OVER
		(
		PARTITION BY categoryid
		ORDER BY
			unitprice,
			productid
		) AS rownum,
	categoryid,
	productid,
	productname,
	unitprice
	FROM Production.Products
) AS D
WHERE rownum<=2;

-- Here, inner query is specified in the FROM clause of outer query
-- The outer query can reference the column aliases used in inner query


------------------------------------------------------------------------------------------
--		2. COMMON TABLE EXPRESSIONS
------------------------------------------------------------------------------------------

WITH C AS
(
	SELECT 
		ROW_NUMBER()
		OVER
		(
		PARTITION BY categoryid
		ORDER BY
			unitprice,
			productid
		) AS rownum,
		categoryid,
		productid,
		productname,
		unitprice
	FROM Production.Products
)
SELECT 
	categoryid,
	productid,
	productname,
	unitprice
FROM C
WHERE rownum<=2;


-- Here, inner query is specified first, followed by outer query

------------------------------------------------------------------------------------------
--		3. VIEWS
------------------------------------------------------------------------------------------

-- Build a view first

DROP VIEW IF EXISTS Sales.v_RankedProducts;
GO

CREATE VIEW Sales.v_RankedProducts
AS
   SELECT
        rownum = ROW_NUMBER() 
         OVER
         (
            PARTITION BY categoryid
            ORDER BY 
                 unitprice
               , productid
         )
      , categoryid
      , productid
      , productname
      , unitprice
   FROM Production.Products
GO

-- Now use it
SELECT
     categoryid
   , productid
   , productname
   , unitprice
FROM Sales.v_RankedProducts
WHERE rownum <= 2; -- Filtering is outside of table expression


-- cleanup
DROP VIEW IF EXISTS Sales.v_RankedProducts;
GO

--------------------------------------------------------------------------------------
-- Practice examples
-------------------------------------------------------------------------------------

USE Chinook;
GO

-- Get a list of all orders by country (from Invoices table) with total amount (in descending order), include a ROW_NUMBER function

SELECT 
	ROW_NUMBER()
	OVER
	(
		PARTITION BY BillingCountry
		ORDER BY Total DESC
	) AS rownum,
	InvoiceId,
	CustomerId,
	InvoiceDate,
	BillingAddress,
	BillingCity,
	BillingState,
	BillingCountry,
	BillingPostalCode,
	Total
FROM dbo.Invoice;


-- Use above query to get three largest orders for each country.

-- 1. with derived table

SELECT InvoiceId,
	CustomerId,
	InvoiceDate,
	BillingAddress,
	BillingCity,
	BillingState,
	BillingCountry,
	BillingPostalCode,
	Total
FROM
(
	SELECT 
	ROW_NUMBER()
	OVER
	(
		PARTITION BY BillingCountry
		ORDER BY Total DESC
	) AS rownum,
	InvoiceId,
	CustomerId,
	InvoiceDate,
	BillingAddress,
	BillingCity,
	BillingState,
	BillingCountry,
	BillingPostalCode,
	Total
	FROM dbo.Invoice
) AS D
WHERE rownum<=3;

--2. Using CTE

WITH C AS
(
	SELECT 
	ROW_NUMBER()
	OVER
	(
		PARTITION BY BillingCountry
		ORDER BY Total DESC
	) AS rownum,
	InvoiceId,
	CustomerId,
	InvoiceDate,
	BillingAddress,
	BillingCity,
	BillingState,
	BillingCountry,
	BillingPostalCode,
	Total
	FROM dbo.Invoice
)
SELECT 
	InvoiceId,
	CustomerId,
	InvoiceDate,
	BillingAddress,
	BillingCity,
	BillingState,
	BillingCountry,
	BillingPostalCode,
	Total
FROM C
WHERE rownum<=3