

--========================================================================================
--	Description: Various Examples of SQL commands with subqueries and table expressions
--	Author: Tresa Varghese
--========================================================================================


----------------------------------------------------------
-- Example: Self contained subquery with scalar result
----------------------------------------------------------

USE TSQL2016;
GO

SELECT 
     productid
   , productname
   , unitprice
FROM Production.Products
WHERE unitprice =
(
   SELECT MIN(unitprice)
   FROM Production.Products
);



--------------------------------------------------------------------------------------
-- Example: Self contained subquery with multiple values in the form of single column
--------------------------------------------------------------------------------------


SELECT 
     productid
   , productname
   , unitprice
FROM Production.Products
WHERE supplierid IN
(
   SELECT supplierid
   FROM Production.Suppliers
   WHERE country = N'Japan'
);

-- An alternate solution using "esoteric" ALL clause 
--  returns details of product with min unitprice

SELECT 
     productid
   , productname
   , unitprice
FROM Production.Products
WHERE unitprice <= ALL 
(
   SELECT unitprice 
   FROM Production.Products
);

-- return all products with unitprice greater than minimum unit price

SELECT 
     productid
   , productname
   , unitprice
FROM Production.Products
WHERE unitprice > ANY 
(
   SELECT unitprice 
   FROM Production.Products
);


--------------------------------------------------------------------------------------
-- Example: correlated subquery
-------------------------------------------------------------------------------------

-- return products with min unit price per category

SELECT 
     categoryid
   , productid
   , productname
   , unitprice
FROM Production.Products AS P1
WHERE unitprice =
(
   SELECT MIN(unitprice)
   FROM Production.Products AS P2
   WHERE P2.categoryid = P1.categoryid
);

-- customers who placed order on 20070212

SELECT
     custid
   , companyname
FROM Sales.Customers AS C
WHERE EXISTS
(
   SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
   AND O.orderdate = '20070212'
);


-- customers who did not place orders on February 12, 2016


SELECT 
     custid
   , companyname
FROM Sales.Customers AS C
WHERE NOT EXISTS
(
   SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
   AND O.orderdate = '20160212'
);


-- Example where subquery is better than join

INSERT INTO Sales.Shippers(companyname, phone)
VALUES('Shipper XYZ', '(123) 456-7890');


SELECT S.shipperid
FROM Sales.Shippers AS S
WHERE NOT EXISTS
(	
	SELECT *
	FROM Sales.Orders AS O
	WHERE O.shipperid = S.shipperid
);


SELECT S.shipperid
FROM Sales.Shippers AS S
	LEFT OUTER JOIN Sales.Orders AS O
	ON S.shipperid = O.shipperid
WHERE O.orderid IS NULL;


-- Example where join is better than subquery

SELECT orderid, custid, freight,
	freight / ( SELECT SUM(O2.freight)
				FROM Sales.Orders AS O2
				WHERE O2.custid = O1.custid ) AS pctcust,
	freight - ( SELECT AVG(O3.freight)
				FROM Sales.Orders AS O3
				WHERE O3.custid = O1.custid ) AS diffavgcust
FROM Sales.Orders AS O1;


SELECT O.orderid, O.custid, O.freight,
		freight / totalfreight AS pctcust,
		freight - avgfreight AS diffavgcust
FROM Sales.Orders AS O
	INNER JOIN (	SELECT custid, SUM(freight) AS
						totalfreight, AVG(freight) AS avgfreight
					FROM Sales.Orders
					GROUP BY custid ) AS A
	ON O.custid = A.custid;



--------------------------------------------------------------------------------------
-- Practice examples
-------------------------------------------------------------------------------------

-- Write a statement to return first invoice for each customer

USE Chinook;
GO


SELECT *
FROM dbo.Invoice;

SELECT CustomerId, InvoiceId, InvoiceDate
FROM DBO.Invoice AS I1
WHERE InvoiceDate IN 
(
	SELECT MIN(InvoiceDate)
	FROM dbo.Invoice AS I2
	WHERE I1.CustomerId = I2.CustomerId
);

