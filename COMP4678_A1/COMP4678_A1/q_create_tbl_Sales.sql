
-- create tbl_Sales using T-SQL script


USE [A1_Data]
GO

IF EXISTS(SELECT name 
     FROM    sysobjects 
     WHERE  name = N'tbl_Sales' 
     AND     type = 'U')
    DROP TABLE tbl_Sales
GO

-- with PK and FK
CREATE TABLE tbl_Sales 
(
   transaction_id       int NOT NULL,
   transaction_date     date NOT NULL,
   prod_id				int NOT NULL,
   invoice_number		int NOT NULL,
   quantity      int,
   amount         decimal(9,2),
   PRIMARY KEY (transaction_id),
   FOREIGN KEY (prod_id)  REFERENCES tbl_Products (prod_id),   
)