


-- List all products with name starting with letter “B”

USE [A1_Data]
GO

SELECT prod_name
FROM tbl_Products
WHERE prod_name LIKE 'B%';

