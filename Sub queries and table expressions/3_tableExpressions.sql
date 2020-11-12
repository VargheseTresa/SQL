



--========================================================================================
--	Description: Demonstratets the use of table expressions
--	Author: Tresa Varghese
--========================================================================================



------------------------------------------------------------------------------------------
--		DERIVED TABLES
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

