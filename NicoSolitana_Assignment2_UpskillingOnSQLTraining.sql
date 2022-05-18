
/****** 1.	Display the total number of items sold per PRODUCT 
from orders in the database with the following requirements:  ******/
SELECT P.ProductName,						-- d) Return columns should include: ProductName, TotalQuantity
	   SUM(O.Quantity) AS TotalQuantity		-- a) Only count orders from TX state
FROM [dbo].[OrderItem] O
INNER JOIN [dbo].[Product] P
ON O.ProductId = P.ProductId
GROUP BY P.ProductId, P.ProductName
HAVING SUM(O.Quantity) > 10					-- b) Total items sold per product should be greater than 10
ORDER BY SUM(O.Quantity) DESC				-- c) Sort by total units sold from highest to lowest


/****** 2. Display the total number of items sold per CATEGORY from 
orders in the database with the following requirements:  ******/
SELECT REPLACE(C.CategoryName, 'Bikes','Bicycles'),   -- a) For categories with "Bikes" on the name, make it Bicycle instead (ex. "Road Bikes" will be "Road Bicycles" instead)
	SUM(O.Quantity) AS TotalQuantity				  -- c)	Return columns should include: CategoryName, TotalQuantity
FROM [dbo].[Product] P
INNER JOIN [dbo].[OrderItem] O
ON P.ProductId = O.ProductId
INNER JOIN [SQL4DevsDb].[dbo].[Category] C
ON P.CategoryId = C.CategoryId
GROUP BY C.CategoryName
ORDER BY SUM(O.Quantity) DESC						 -- b) Sort by total units sold from highest to lowest


/****** 3.	Merge the results of items #1 and #2:  ******/
SELECT P.ProductName,						
	   SUM(O.Quantity) AS TotalQuantity		
FROM [dbo].[OrderItem] O
INNER JOIN [dbo].[Product] P
ON O.ProductId = P.ProductId
GROUP BY P.ProductId, P.ProductName
HAVING SUM(O.Quantity) > 10					
UNION
SELECT REPLACE(C.CategoryName, 'Bikes','Bicycles'),  
	SUM(O.Quantity) AS TotalQuantity				 
FROM [dbo].[Product] P
INNER JOIN [dbo].[OrderItem] O
ON P.ProductId = O.ProductId
INNER JOIN [SQL4DevsDb].[dbo].[Category] C
ON P.CategoryId = C.CategoryId
GROUP BY C.CategoryName
ORDER BY SUM(O.Quantity) DESC			-- a) Sort by total units sold from highest to lowest		


/****** 4.	For all orders in the database, retrieve the top selling 
      product per month year with the following requirements:  ******/
SELECT DENSE_RANK() OVER(PARTITION BY MONTH(O.[OrderDate])				-- c) In cases where there are more than 1 top-selling product in a month, we should display ALL products in TOP 1 position
						 ORDER BY SUM(OI.Quantity) DESC) AS Rank,
	YEAR(O.[OrderDate]) AS OrderYear,									-- a) Return columns should include: OrderYear, OrderMonth, ProductName, TotalQuantity
	MONTH(O.[OrderDate]) AS OrderMonth,
	P.ProductName,
	SUM(OI.Quantity) AS TotalQuantity
FROM [dbo].[OrderItem] OI
INNER JOIN [dbo].[Product] P
ON OI.OrderId = P.ProductId
INNER JOIN [dbo].[Order] O
ON OI.OrderId = O.OrderId
GROUP BY MONTH(O.[OrderDate]), YEAR(O.[OrderDate]), P.ProductName
ORDER BY  YEAR(O.[OrderDate]), MONTH(O.[OrderDate]) ASC				-- b) Sort the result by Year and Month in ascending order