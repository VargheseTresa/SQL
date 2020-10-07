

--Script generated after creating tbl_Customers

USE [A1_Data]
GO

/****** Object:  Table [dbo].[tbl_Customers]    Script Date: 2020-10-01 3:52:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbl_Customers](
	[cust_id] [int] NOT NULL,
	[first_name] [nvarchar](20) NOT NULL,
	[last_name] [nvarchar](20) NOT NULL,
	[street] [nvarchar](50) NOT NULL,
	[city] [nvarchar](20) NOT NULL,
	[province] [nchar](2) NOT NULL,
	[phone] [bigint] NULL,
 CONSTRAINT [PK_tbl_Customers] PRIMARY KEY CLUSTERED 
(
	[cust_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



