

USE [A1_Data]
GO

-- add a PK constraint
ALTER TABLE tbl_Products
ADD CONSTRAINT PK_Student
   PRIMARY KEY(prod_id)
GO


-- add a DEFAULT constraint
ALTER TABLE tbl_Customers
ADD CONSTRAINT DF_Province
DEFAULT 'BC' 
FOR province
GO


-- add a UNIQUE constraint
ALTER TABLE tbl_Customers
ADD CONSTRAINT UQ_Phone
UNIQUE(phone)
GO


-- add a column
ALTER TABLE tbl_Products 
ADD prod_category nvarchar(20)
GO

