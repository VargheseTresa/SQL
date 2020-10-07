USE [master]
GO
/****** Object:  Database [A1_Data]    Script Date: 2020-10-01 5:10:58 PM ******/
CREATE DATABASE [A1_Data]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'A1_Data', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\A1_Data.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'A1_Data_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\A1_Data_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [A1_Data] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [A1_Data].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [A1_Data] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [A1_Data] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [A1_Data] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [A1_Data] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [A1_Data] SET ARITHABORT OFF 
GO
ALTER DATABASE [A1_Data] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [A1_Data] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [A1_Data] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [A1_Data] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [A1_Data] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [A1_Data] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [A1_Data] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [A1_Data] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [A1_Data] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [A1_Data] SET  DISABLE_BROKER 
GO
ALTER DATABASE [A1_Data] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [A1_Data] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [A1_Data] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [A1_Data] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [A1_Data] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [A1_Data] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [A1_Data] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [A1_Data] SET RECOVERY FULL 
GO
ALTER DATABASE [A1_Data] SET  MULTI_USER 
GO
ALTER DATABASE [A1_Data] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [A1_Data] SET DB_CHAINING OFF 
GO
ALTER DATABASE [A1_Data] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [A1_Data] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [A1_Data] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'A1_Data', N'ON'
GO
ALTER DATABASE [A1_Data] SET QUERY_STORE = OFF
GO
USE [A1_Data]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
USE [A1_Data]
GO
/****** Object:  Table [dbo].[tbl_Customers]    Script Date: 2020-10-01 5:10:58 PM ******/
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
/****** Object:  Table [dbo].[tbl_Products]    Script Date: 2020-10-01 5:10:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Products](
	[prod_id] [int] NOT NULL,
	[prod_name] [nvarchar](50) NOT NULL,
	[unit_price] [decimal](6, 2) NOT NULL,
	[prod_category] [nvarchar](20) NULL,
 CONSTRAINT [PK_Student] PRIMARY KEY CLUSTERED 
(
	[prod_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Sales]    Script Date: 2020-10-01 5:10:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Sales](
	[transaction_id] [int] NOT NULL,
	[transaction_date] [date] NOT NULL,
	[prod_id] [int] NOT NULL,
	[invoice_number] [int] NOT NULL,
	[quantity] [int] NULL,
	[amount] [decimal](9, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (520, N'Tony ', N'Thomas', N'635 E 55th ', N'Vancouver', N'BC', 7788960490)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (521, N'Amal', N'Mathew', N'820 W 63', N'Abbotsford', N'BC', 7785231090)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (522, N'Vicky', N'Valsan', N'9557 96 E', N'Surrey', N'BC', 6045230491)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (523, N'Rocky', N'Bhai', N'1995 W 5', N'Aldergroove', N'BC', 1235469203)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (524, N'Pazhassi', N'Raja', N'6258 W 98', N'Revelstoke', N'BC', 3964586214)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (525, N'Garuda ', N'Vardhanan', N'369 E 45', N'Whistler', N'BC', 2652354656)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (526, N'Adheera', N'A', N'2365 E 56', N'Richmond', N'BC', 9652301456)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (527, N'Jifi ', N'Mahesh', N'684 E 55th', N'Vancouver', N'BC', 7788560263)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (528, N'Ted', N'Mosby', N'325 W 5th', N'Delta', N'BC', 6043202654)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (529, N'Barney ', N'Stinson', N'520 66th ', N'Squamish', N'BC', 2356042356)
INSERT [dbo].[tbl_Customers] ([cust_id], [first_name], [last_name], [street], [city], [province], [phone]) VALUES (530, N'Marshal', N'Erikson', N'689 1 Ave', N'Hope', N'BC', 6047789604)
GO
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (100, N'Tetly', CAST(5.23 AS Decimal(6, 2)), N'Beverages')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (101, N'Sunlight', CAST(2.26 AS Decimal(6, 2)), N'Detergent')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (102, N'Club Soda', CAST(1.00 AS Decimal(6, 2)), N'Beverage')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (103, N'Meat Balls', CAST(7.66 AS Decimal(6, 2)), N'Food')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (104, N'Tylenol', CAST(3.99 AS Decimal(6, 2)), N'Medicine')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (105, N'Banana', CAST(1.00 AS Decimal(6, 2)), N'Food')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (106, N'Lenova Legion', CAST(1200.00 AS Decimal(6, 2)), N'Electronics')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (107, N'Blender', CAST(35.00 AS Decimal(6, 2)), N'Electronics')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (108, N'UA Shoes', CAST(49.99 AS Decimal(6, 2)), N'Footwear')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (109, N'Puma Hoodie', CAST(20.69 AS Decimal(6, 2)), N'Clothing')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (110, N'Dyson Vaccum Cleaner', CAST(369.99 AS Decimal(6, 2)), N'Electronics')
INSERT [dbo].[tbl_Products] ([prod_id], [prod_name], [unit_price], [prod_category]) VALUES (111, N'Anker Soundcore 2', CAST(86.45 AS Decimal(6, 2)), N'Entertainment')
GO
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (220, CAST(N'2020-01-25' AS Date), 101, 2351, 6, CAST(656.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (221, CAST(N'2020-01-26' AS Date), 100, 2456, 2, CAST(123.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (222, CAST(N'2020-01-25' AS Date), 101, 2351, 1, CAST(103.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (223, CAST(N'2020-03-05' AS Date), 103, 2989, 30, CAST(500.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (224, CAST(N'2020-03-05' AS Date), 103, 2989, 6, CAST(36.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (225, CAST(N'2020-04-30' AS Date), 110, 3695, 22, CAST(222.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (226, CAST(N'2020-04-30' AS Date), 110, 3695, 1, CAST(11.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (227, CAST(N'2020-06-06' AS Date), 108, 5384, 23, CAST(230.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (228, CAST(N'2020-02-28' AS Date), 104, 4631, 90, CAST(9000.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (229, CAST(N'2020-02-28' AS Date), 104, 4631, 20, CAST(2000.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (230, CAST(N'2020-01-01' AS Date), 106, 3593, 15, CAST(90.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (231, CAST(N'2020-01-01' AS Date), 106, 3593, 1, CAST(6.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (232, CAST(N'2020-09-08' AS Date), 107, 8523, 20, CAST(1000.00 AS Decimal(9, 2)))
INSERT [dbo].[tbl_Sales] ([transaction_id], [transaction_date], [prod_id], [invoice_number], [quantity], [amount]) VALUES (233, CAST(N'2020-03-30' AS Date), 102, 7561, 31, CAST(310.00 AS Decimal(9, 2)))
GO
ALTER TABLE [dbo].[tbl_Customers] ADD  CONSTRAINT [DF_Province]  DEFAULT ('BC') FOR [province]
GO
ALTER TABLE [dbo].[tbl_Sales]  WITH CHECK ADD FOREIGN KEY([prod_id])
REFERENCES [dbo].[tbl_Products] ([prod_id])
GO
USE [master]
GO
ALTER DATABASE [A1_Data] SET  READ_WRITE 
GO
