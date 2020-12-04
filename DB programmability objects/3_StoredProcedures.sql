

USE TSQL2016;
Go

------------------------------------------------------
-- Simple SP 
------------------------------------------------------


-- Simple sproc with four parameters
CREATE OR ALTER PROC dbo.bcitsp_GetOrders
     @orderid AS INT = NULL
   , @orderdate AS DATE = NULL
   , @custid AS INT = NULL
   , @empid AS INT = NULL
AS
   SET 
        XACT_ABORT  -- Force any error to roll back transaction
      , NOCOUNT ON; -- Supress returning of number of affected rows

   SELECT 
        orderid
      , orderdate
      , shippeddate
      , custid
      , empid
      , shipperid
   FROM Sales.Orders
   WHERE 
          ( orderid   = @orderid   OR @orderid IS NULL )
      AND ( orderdate = @orderdate OR @orderdate IS NULL )
      AND ( custid    = @custid    OR @custid IS NULL )
      AND ( empid     = @empid     OR @empid IS NULL );
GO


-- Note that there is no BEGIN-END block in stored procedure
-- It is good coding practice to use it all the time
-- Modify new sproc by adding BEGIN-END block
CREATE OR ALTER PROC dbo.bcitsp_GetOrders
     @orderid AS INT = NULL
   , @orderdate AS DATE = NULL
   , @custid AS INT = NULL
   , @empid AS INT = NULL
AS
   BEGIN
      SET 
           XACT_ABORT
         , NOCOUNT ON;

      SELECT 
           orderid
         , orderdate
         , shippeddate
         , custid
         , empid
         , shipperid
      FROM Sales.Orders
      WHERE 
             ( orderid   = @orderid   OR @orderid IS NULL )
         AND ( orderdate = @orderdate OR @orderdate IS NULL )
         AND ( custid    = @custid    OR @custid IS NULL )
         AND ( empid     = @empid     OR @empid IS NULL );
   END
GO


-- Execute it
EXEC dbo.bcitsp_GetOrders DEFAULT, '20151111', 85, DEFAULT;
GO


------------------------------------------------------
-- SP with dynamic SQL
------------------------------------------------------

-- Build a sproc with dynamic SQL
CREATE OR ALTER PROC dbo.bcitsp_GetOrders
     @orderid AS INT = NULL
   , @orderdate AS DATE = NULL
   , @custid AS INT = NULL
   , @empid AS INT = NULL
AS
   SET XACT_ABORT, NOCOUNT ON;
   
   DECLARE @sql AS NVARCHAR(MAX)
   SET @sql = N'SELECT orderid, orderdate, shippeddate, custid, empid, shipperid
   FROM Sales.Orders
   WHERE 1 = 1'
   + CASE WHEN @orderid IS NOT NULL THEN N' AND orderid = @orderid ' ELSE N'' END
   + CASE WHEN @orderdate IS NOT NULL THEN N' AND orderdate = @orderdate' ELSE N'' END
   + CASE WHEN @custid IS NOT NULL THEN N' AND custid = @custid' ELSE N'' END
   + CASE WHEN @empid IS NOT NULL THEN N' AND empid = @empid ' ELSE N'' END
   + N';'

   EXEC sys.sp_executesql
        @stmt = @sql
      , @params = N'@orderid AS INT, @orderdate AS DATE, @custid AS INT, @empid AS INT'
      , @orderid = @orderid
      , @orderdate = @orderdate
      , @custid = @custid
      , @empid = @empid;
GO

-- Execute it
EXEC dbo.bcitsp_GetOrders @orderdate = '20060704', @custid = 85;

