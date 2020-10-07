


-- List all customers from Vancouver


USE [A1_Data]
GO


SELECT CustomerName = first_name + ' ' + last_name, city
FROM tbl_Customers
WHERE city = 'Vancouver';

