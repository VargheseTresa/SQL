

-- List 5 most recent invoices

USE [A1_Data]
GO



SELECT TOP(5) invoice_number, transaction_date, InvoiceAmount = SUM(amount)
FROM tbl_Sales
GROUP BY invoice_number,transaction_date
ORDER BY transaction_date DESC;