


--========================================================================================
--	Description: Demonstratets grouping queries
--	Author: Tresa Varghese
--========================================================================================




USE TSQL2016;
Go

-----------------------------------------------------------------------------------------
--									Single Grouping set
-- This can be achieved by 
--		1. using GROUP BY clause
--		2. using any group function
--		3. using both
-----------------------------------------------------------------------------------------


-- 1. use of GROUP BY clause

SELECT COUNT(*) AS numorders
FROM Sales.Orders;

-- list number of orders for each shipper

SELECT 
     shipperid
   , numorders = COUNT(*)
FROM Sales.Orders
GROUP BY shipperid;

-- using multiple columns for grouping

SELECT 
     shipperid
   , shipyear  = YEAR(shippeddate)
   , numorders = COUNT(*)
FROM Sales.Orders
GROUP BY 
     shipperid
   , YEAR(shippeddate);


--Applying filters

SELECT 
     shipperid
   , shipyear  = YEAR(shippeddate)
   , numorders = COUNT(*)
FROM Sales.Orders
WHERE shippeddate IS NOT NULL
GROUP BY shipperid, YEAR(shippeddate)
HAVING COUNT(*) < 100;

/*
	Here, WHERE clause applies filter before grouping and
	HAVING applies filter on grouped data.
*/

-- Use of multiple grouping functions

SELECT 
     shipperid
   , numorders     = COUNT(*)
   , shippedorders = COUNT(shippeddate)
   , firstshipdate = MIN(shippeddate)
   , lastshipdate  = MAX(shippeddate)
   , totalvalue    = SUM(val)
FROM Sales.OrderValues
GROUP BY shipperid;

-- counting DISTINCT values

SELECT 
     shipperid
   , numshippingdates = COUNT(DISTINCT shippeddate)
FROM Sales.Orders
GROUP BY shipperid;



-----------------------------------------------------------------------------------------
--									Multiple Grouping set
-- This can be achieved by using
--		1. GROUPING SETS
--		2. CUBE
--		3. ROLLUP
-----------------------------------------------------------------------------------------


-- Use of GROUPING SETS

SELECT 
     shipperid
   , shipyear  = YEAR(shippeddate)
   , numorders = COUNT(*)
FROM Sales.Orders
WHERE shippeddate IS NOT NULL -- exclude unshipped orders
GROUP BY GROUPING SETS
(
     ( shipperid, YEAR(shippeddate) )
   , ( shipperid                    )
   , ( YEAR(shippeddate)            )
   , (                              )
);


-- Use of CUBE

SELECT 
     shipperid
   , shipyear  = YEAR(shippeddate)
   , numorders = COUNT(*)
FROM Sales.Orders
WHERE shippeddate IS NOT NULL
GROUP BY CUBE( shipperid, YEAR(shippeddate) );

-- use of ROLLUP

SELECT shipcountry, shipregion, shipcity, COUNT(*) AS
numorders
FROM Sales.Orders
GROUP BY ROLLUP( shipcountry, shipregion, shipcity );


