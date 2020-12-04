


--========================================================================================
--	Description: Demonstratets the use of USER DEFINED FUNCTIONS
--
--	Author: Tresa Varghese
--========================================================================================


USE TSQL2016;
Go

-- We will use a new table for UDFs
SET NOCOUNT ON;

DROP TABLE IF EXISTS dbo.Employees;
GO
CREATE TABLE dbo.Employees
(
     empid INT NOT NULL CONSTRAINT PK_Employees PRIMARY KEY
   , mgrid INT NULL 
      CONSTRAINT FK_Employees_Employees REFERENCES dbo.Employees
   , empname VARCHAR(25) NOT NULL
   , salary MONEY NOT NULL
   , CHECK (empid <> mgrid)
);

-- Populate data
INSERT INTO dbo.Employees
(
     empid
   , mgrid
   , empname
   , salary
)
VALUES
     ( 1, NULL, 'David', $10000.00)
   , ( 2, 1, 'Eitan', $7000.00)
   , ( 3, 1, 'Ina', $7500.00)
   , ( 4, 2, 'Seraph', $5000.00)
   , ( 5, 2, 'Jiru', $5500.00)
   , ( 6, 2, 'Steve', $4500.00)
   , ( 7, 3, 'Aaron', $5000.00)
   , ( 8, 5, 'Lilach', $3500.00)
   , ( 9, 7, 'Rita', $3000.00)
   , ( 10, 5, 'Sean', $3000.00)
   , ( 11, 7, 'Gabriel', $3000.00)
   , ( 12, 9, 'Emilia' , $2000.00)
   , ( 13, 9, 'Michael', $2000.00)
   , ( 14, 9, 'Didi', $1500.00);

-- Add index
CREATE UNIQUE INDEX idx_unc_mgr_emp_i_name_sal 
ON dbo.Employees( mgrid, empid )
INCLUDE( empname, salary );
GO

--------------------------------------------------------------------
--							1. Scalar UDF
--------------------------------------------------------------------


CREATE OR ALTER FUNCTION dbo.myf_SubtreeTotalSalaries( @mgr AS INT )
   RETURNS MONEY
   WITH SCHEMABINDING
AS
   BEGIN
      DECLARE @totalsalary AS MONEY;

      WITH EmpsCTE AS
      (
         SELECT empid, salary
         FROM dbo.Employees
         WHERE empid = @mgr
         UNION ALL
         SELECT S.empid, S.salary
         FROM EmpsCTE AS M
            INNER JOIN dbo.Employees AS S
               ON S.mgrid = M.empid
      )
      SELECT @totalsalary = SUM(salary)
      FROM EmpsCTE;
      RETURN @totalsalary;
   END;
GO


-- Now try it, with schema name
SELECT dbo.myf_SubtreeTotalSalaries(8) AS subtreetotal;


--The code fails without schema name
SELECT myf_SubtreeTotalSalaries(8) AS subtreetotal;

-- Use it within the query
SELECT
     empid
   , mgrid
   , empname
   , salary
   , dbo.myf_SubtreeTotalSalaries(empid) AS subtreetotal
FROM dbo.Employees;
GO

-----------------------------------------------------------------------------
--					2. Inline table-valued UDF
-----------------------------------------------------------------------------


-- Note that it does NOT have BEGIN-END block

CREATE OR ALTER FUNCTION dbo.myf_GetPage(@pagenum AS BIGINT, @pagesize AS BIGINT)
   RETURNS TABLE
   WITH SCHEMABINDING
AS
   RETURN
   WITH C AS
   (
      SELECT 
           rownum = ROW_NUMBER() OVER(ORDER BY orderdate, orderid)
         , orderid
         , orderdate
         , custid
         , empid
      FROM Sales.Orders
   )
   SELECT 
        rownum
      , orderid
      , orderdate
      , custid
      , empid
   FROM C
   WHERE 
      rownum BETWEEN (@pagenum - 1) * @pagesize + 1 AND @pagenum * @pagesize;
GO

-- Use this one now
SELECT 
     rownum
   , orderid
   , orderdate
   , custid
   , empid
FROM dbo.myf_GetPage(3, 12) AS T;


-- A more complex example of in-line UDF

DROP FUNCTION IF EXISTS dbo.myf_GetSubtree;
GO

CREATE FUNCTION dbo.myf_GetSubtree(@mgr AS INT, @maxlevels AS INT = NULL)
   RETURNS TABLE
   WITH SCHEMABINDING
AS
   RETURN
   WITH EmpsCTE AS
   (
      SELECT
           empid
         , mgrid    = CAST( NULL AS INT )
         , empname
         , salary
         , lvl      = 0
         , sortpath = CAST( '.' AS VARCHAR(900) )
      FROM dbo.Employees
      WHERE empid = @mgr

      UNION ALL

      SELECT 
           S.empid
         , S.mgrid
         , S.empname
         , S.salary
         , lvl      = M.lvl + 1
         , sortpath = CAST( M.sortpath + CAST( S.empid AS VARCHAR(10) ) + '.' AS VARCHAR(900) )
      FROM EmpsCTE AS M
         INNER JOIN dbo.Employees AS S
            ON S.mgrid = M.empid
         AND ( M.lvl < @maxlevels OR @maxlevels IS NULL )
   )
   SELECT 
        empid
      , mgrid
      , empname
      , salary
      , lvl
      , sortpath
   FROM EmpsCTE;
Go

-- Now we we will generate an employee tree

SELECT 
     empid
   , emp = REPLICATE(' | ', lvl) + empname
   , mgrid
   , salary
   , lvl
   , sortpath
FROM dbo.myf_GetSubtree(3, NULL) AS T
ORDER BY sortpath;

select * from  dbo.Employees;

----------------------------------------------------------------
--			Multistatement table-valued UDF
----------------------------------------------------------------



-- We cannot use CREATE OR ALTER to change the function type
DROP FUNCTION IF EXISTS dbo.myf_GetSubtree;
GO

CREATE FUNCTION dbo.myf_GetSubtree ( @mgrid AS INT, @maxlevels AS INT = NULL )
   RETURNS @Tree TABLE
   (
        empid INT NOT NULL PRIMARY KEY
      , mgrid INT NULL
      , empname VARCHAR(25) NOT NULL
      , salary MONEY NOT NULL
      , lvl INT NOT NULL
      , sortpath VARCHAR(892) NOT NULL 
      , INDEX idx_lvl_empid_sortpath NONCLUSTERED( lvl, empid, sortpath )
   )
   WITH SCHEMABINDING
AS
   BEGIN
      -- Container for levels
      DECLARE @lvl AS INT = 0;
      -- insert subtree root node into @Tree
      INSERT INTO @Tree
      (
           empid
         , mgrid
         , empname
         , salary
         , lvl
         , sortpath
      )
      SELECT 
           empid
         , mgrid    = NULL
         , empname
         , salary
         , lvl      = @lvl
         , sortpath = '.'
      FROM dbo.Employees
      WHERE empid = @mgrid;

      WHILE @@ROWCOUNT > 0 AND ( @lvl < @maxlevels OR @maxlevels IS NULL )
      BEGIN
         SET @lvl += 1;
         -- insert children of nodes from prev level into @Tree
         INSERT INTO @Tree
         (
              empid
            , mgrid
            , empname
            , salary
            , lvl
            , sortpath
         )
         SELECT 
              S.empid
            , S.mgrid
            , S.empname
            , S.salary
            , lvl      = @lvl
            , sortpath = M.sortpath + CAST(S.empid AS VARCHAR(10)) + '.'
         FROM dbo.Employees AS S
            INNER JOIN @Tree AS M
               ON S.mgrid = M.empid AND M.lvl = @lvl - 1;
      END;
   RETURN;
   END;
GO

-- ...and try it
SELECT 
     empid
   , emp = REPLICATE( ' | ', lvl ) + empname
   , mgrid
   , salary
   , lvl
   , sortpath
FROM dbo.myf_GetSubtree( 3, NULL ) AS T
ORDER BY sortpath;


-- And now clear the mess
DROP TABLE IF EXISTS dbo.T1;

DROP VIEW IF EXISTS dbo.v_VRAND;
DROP FUNCTION IF EXISTS 
     dbo.myf_SubtreeTotalSalaries
   , dbo.myf_GetPage
   , dbo.myf_GetSubtree;

DROP TABLE IF EXISTS dbo.Employees;