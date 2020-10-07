

-- List all records in original order


USE [A1_Data]
GO

SELECT prod_id,prod_name,unit_price,prod_category
FROM tbl_Products;


SELECT transaction_id, transaction_date,prod_id,invoice_number,quantity,amount
FROM tbl_Sales;

SELECT cust_id, first_name,last_name,street,city, province, phone
FROM TBL_Customers;
