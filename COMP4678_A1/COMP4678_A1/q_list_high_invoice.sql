


-- List 10 invoices with the highest amount

USE [A1_Data]
GO




SELECT TOP(10) invoice_number, InvoiceAmount = SUM(amount)
FROM tbl_Sales
GROUP BY invoice_number, transaction_date
ORDER BY InvoiceAmount DESC;