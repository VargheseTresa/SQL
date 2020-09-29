

--===================================================================
--	Description: Various Examples of SQL commands for altering table
--	Author: Tresa Varghese
--===================================================================


-----------------------------------------------------
-- create a Temporary Table
-----------------------------------------------------


IF OBJECT_ID('tempdb..#Student') IS NOT NULL 
DROP TABLE #Student
GO

CREATE TABLE #Student
(
   StudentID INT NOT NULL,
   FName VARCHAR(30),
   LName VARCHAR(30) 
);


-- add a column

ALTER TABLE #Student 
ADD Birthdate DATE;


-- add a PK
ALTER TABLE #Student 
ADD CONSTRAINT PK_Student
   PRIMARY KEY(StudentID);


-- add a DEFAULT
ALTER TABLE #Student
ADD CONSTRAINT DF_Birthdate
DEFAULT '1900-01-01' 
FOR Birthdate
GO


-- Test default by inserting a row
INSERT INTO #Student
(StudentID, FName, LName)
VALUES 
(1, 'John', 'Doe')


SELECT * 
FROM #Student


-- add a CHECK
ALTER TABLE #Student
ADD CONSTRAINT CK_Birthdate
CHECK(Birthdate >= '1900-01-01')
GO

-- Test
INSERT INTO #Student
(StudentID, FName, LName, Birthdate)
VALUES 
(2, 'John', 'Doe', '1899-12-31')


-- add a UNIQUE
ALTER TABLE #Student
ADD CONSTRAINT UQ_Birthdate
UNIQUE(Birthdate)
GO

-- Test
INSERT INTO #Student
(StudentID, FName, LName, Birthdate)
VALUES 
(3, 'John', 'Doe', DEFAULT)


-- drop constraints and column
ALTER TABLE #Student
DROP CONSTRAINT DF_Birthdate

ALTER TABLE #Student
DROP CONSTRAINT CK_Birthdate

ALTER TABLE #Student
DROP CONSTRAINT UQ_Birthdate

ALTER TABLE #Student
DROP COLUMN Birthdate

SELECT * 
FROM #Student




-- Clean up step
DROP TABLE #Student