


--========================================================================================
--	Description: Demonstratets two different forms of APPLY operator
--		1. CROSS
--		2. OUTER
--
--	Author: Tresa Varghese
--========================================================================================

USE TSQL2016;
GO

-- Add a new supplier
INSERT INTO Production.Suppliers
(
     companyname
   , contactname
   , contacttitle
   , address
   , city
   , postalcode
   , country
   , phone
)
VALUES
(
     N'Supplier XYZ'
   , N'Jiru'
   , N'Head of Security'
   , N'42 Sekimai Musashino-shi'
   , N'Tokyo'
   , N'01759'
   , N'Japan'
   , N'(02) 4311-2609'
);

-------------------------------------------------
--		CROSS APPLY
-------------------------------------------------

--  Find 2 products with lowest unit price for supplier 1

SELECT TOP (2) 
     productid
   , productname
   , unitprice
FROM Production.Products
WHERE supplierid = 1
ORDER BY 
     unitprice
   , productid;

-- For each supplier in Japan, return two products with lowest unit prices


SELECT 
     S.supplierid
   , S.companyname AS supplier
   , A.*
FROM Production.Suppliers AS S
	CROSS APPLY 
	(
	SELECT TOP (2) 
        productid
      , productname
      , unitprice
	FROM Production.Products AS P
	WHERE P.supplierid = S.supplierid
	ORDER BY unitprice, productid
	) AS A
WHERE S.country = N'Japan';


/*
Here the newly added supplier with no assoicated product is not returned
as the right expression returns NULL for that supplier id.
*/



------------------------------------------------
--		OUTER APPLY
------------------------------------------------


SELECT 
     S.supplierid
   , S.companyname AS supplier
   , A.*
FROM Production.Suppliers AS S
	OUTER APPLY 
	(
	SELECT TOP (2) 
        productid
      , productname
      , unitprice
	FROM Production.Products AS P
	WHERE P.supplierid = S.supplierid
	ORDER BY unitprice, productid
	) AS A
WHERE S.country = N'Japan';

/*
Here the newly added supplier with no assoicated product is also returned.
NULL is used to fill the missing values in the right expression.
*/

