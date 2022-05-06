--ASSIGNMENT 1
--Upskilling Program: SQL for Devs 
--Nico Solitana 

--Create Database
CREATE DATABASE SQL4DevsDb;

--On Question 1
--a.Use [dbo].[Order] table to query the result 
SELECT *
FROM dbo.[Order]

--b.List of customer ids with total number of orders for the year 2017 and 2018. 
SELECT O.CustomerId,
	COUNT([OrderId]) OrderCount 
FROM dbo.[Order] O
INNER JOIN dbo.[Customer] C
ON C.CustomerId = O.CustomerId
WHERE YEAR(O.OrderDate) BETWEEN 2017 AND 2018
GROUP BY O.CustomerId

--c.Customer’s orders should be at least 2 
SELECT O.CustomerId,
	COUNT(O.[OrderId]) OrderCount 
FROM dbo.[Order] O
INNER JOIN dbo.[Customer] C
ON C.CustomerId = O.CustomerId
WHERE (YEAR(O.OrderDate) BETWEEN 2017 AND 2018)
GROUP BY O.CustomerId
HAVING COUNT(O.[OrderId]) >= 2


--d.Orders should not have been shipped yet 
SELECT O.CustomerId,
	COUNT(O.[OrderId]) OrderCount 
FROM dbo.[Order] O
INNER JOIN dbo.[Customer] C
ON C.CustomerId = O.CustomerId
WHERE (YEAR(O.OrderDate) BETWEEN 2017 AND 2018) AND
	(O.[ShippedDate] > GETDATE() OR O.[ShippedDate] = NULL)
GROUP BY O.CustomerId
HAVING COUNT(O.[OrderId]) >= 2

--FINAL ANSWER:
SELECT O.CustomerId,
	COUNT(O.[OrderId]) OrderCount 
FROM dbo.[Order] O
INNER JOIN dbo.[Customer] C
ON C.CustomerId = O.CustomerId
WHERE (YEAR(O.OrderDate) BETWEEN 2017 AND 2018) AND
	(O.[ShippedDate] > GETDATE() OR O.[ShippedDate] = NULL)
GROUP BY O.CustomerId


--On Question 2
--a.Create a backup of dbo.Product table with this format: <table name>_<yyyymmdd> and exclude records with Model Year of 2016 
DECLARE @TableName AS NVARCHAR(50)
DECLARE @sql AS NVARCHAR(100)
SET @TableName = 'dbo.Product_' + CONVERT(char(10), GetDate(),112)
SET @sql = N'SELECT * INTO ' + @TableName + ' FROM dbo.[Product] WHERE [ModelYear] != 2016' 
EXEC (@sql) 

--b.Using the backup table, raise the list price of each product by 20% for “Heller” and “Sun Bicycles” brands while 10% for the other brands. 
DECLARE @Table AS NVARCHAR(50)
DECLARE @query AS NVARCHAR(300)
SET @Table = 'dbo.Product_' + CONVERT(char(10), GetDate(),112)
SET @query = N'UPDATE ' + @Table + ' SET ListPrice = (CASE
				WHEN ProductName LIKE ''Heller%''
					THEN (ListPrice *.20) + ListPrice
				WHEN ProductName LIKE ''Sun%''
					THEN (ListPrice *.20) + ListPrice
				ELSE (ListPrice *.10) + ListPrice
				END)'
EXEC (@query)

--FINAL ANSWER:
DECLARE @TableName AS NVARCHAR(50)
DECLARE @sql AS NVARCHAR(100)
SET @TableName = 'dbo.Product_' + CONVERT(char(10), GetDate(),112)
SET @sql = N'SELECT * INTO ' + @TableName + ' FROM dbo.[Product] WHERE [ModelYear] != 2016' 
EXEC (@sql) 
DECLARE @Table AS NVARCHAR(50)
DECLARE @query AS NVARCHAR(300)
SET @Table = 'dbo.Product_' + CONVERT(char(10), GetDate(),112)
SET @query = N'UPDATE ' + @Table + ' SET ListPrice = (CASE
				WHEN ProductName LIKE ''Heller%''
					THEN (ListPrice *.20) + ListPrice
				WHEN ProductName LIKE ''Sun%''
					THEN (ListPrice *.20) + ListPrice
				ELSE (ListPrice *.10) + ListPrice
				END)'
EXEC (@query)
