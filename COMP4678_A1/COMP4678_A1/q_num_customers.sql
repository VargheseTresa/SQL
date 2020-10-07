


-- List number of customers in each city

USE [A1_Data]
GO



SELECT city, 'Number of Customers' = COUNT(*)
FROM tbl_Customers
GROUP BY city;
