



--========================================================================================
--	Description: Demonstratets examples of pivoting data
--	Author: Tresa Varghese
--========================================================================================


USE TSQL2016;
Go

--------------------------------------------------
--				Use of PIVOT
--------------------------------------------------

/*
   Getting list of all shippers (columns),
   customers (rows) and total freight for all of them
*/

WITH PivotData AS
(
	SELECT
        custid    -- grouping column
      , shipperid -- spreading column
      , freight   -- aggregation column
	FROM Sales.Orders
)
SELECT 
     custid
   , [1]
   , [2]
   , [3]
FROM PivotData
	PIVOT( SUM( freight ) FOR shipperid IN ( [1], [2], [3] ) ) AS P;

	
-- Where did we get these [1], [2] and [3]?
SELECT DISTINCT shipperid
FROM Sales.Orders;


-- How to provide meaningful number (0 in our case)
-- for shippers without any shipment
WITH PivotData AS
(
   SELECT
        custid    -- grouping column
      , shipperid -- spreading column
      , freight   -- aggregation column
FROM Sales.Orders
)
SELECT 
     custid
   , [1] = IsNull( [1], 0.00 )
   , [2] = IsNull( [2], 0.00 )
   , [3] = IsNull( [3], 0.00 )
FROM PivotData
PIVOT( SUM( freight ) FOR shipperid IN ( [1], [2], [3] ) ) AS P;



--------------------------------------------------
--				Use of UNPIVOT
--------------------------------------------------
DROP TABLE IF EXISTS Sales.FreightTotals;

WITH PivotData AS
(
   SELECT
        custid    -- grouping column
      , shipperid -- spreading column
      , freight   -- aggregation column
   FROM Sales.Orders
)
SELECT *
INTO Sales.FreightTotals
FROM PivotData
PIVOT( SUM( freight ) FOR shipperid IN ( [1], [2], [3] ) ) AS P;

-- This stores pivoted data into table Sales.FreightTotals

-- Let's see what do we have in this table
SELECT * 
FROM Sales.FreightTotals;

-- Now break (unpivot) it down
SELECT 
     custid
   , shipperid
   , freight
FROM Sales.FreightTotals
UNPIVOT( freight FOR shipperid IN( [1], [2], [3] ) ) AS U;