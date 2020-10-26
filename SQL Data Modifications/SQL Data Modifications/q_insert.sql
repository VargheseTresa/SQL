

USE TSQL2016;
Go

/*-
There are 4 ways to insert values into tables in SQL
	1. INSERT VALUES
	2. INSERT SELECT
	3. INSERT EXEC
	4. SELECT INTO

*/


----------------------------
-- INSERT VALUES
----------------------------

-- Providing values for all (but identity) columns

INSERT INTO Sales.MyOrders
(
     custid
   , empid
   , orderdate
   , shipcountry
   , freight
)
VALUES( 2, 19, '20170620', N'USA', 30.00 );