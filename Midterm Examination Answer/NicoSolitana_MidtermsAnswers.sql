--MIDTERM EXAM ANSWERS
--SUBMITTED BY: NICO SOLITANA

--1.Write a script that would return the id and name of the store that does NOT have any Order record 
SELECT S.StoreId, S.StoreName									-- return the id and name of the store
FROM [dbo].[Store] S
WHERE S.StoreId NOT IN (SELECT O.StoreId FROM [dbo].[Order] O)  -- does NOT have any Order record 


 -- 2.Write a script with the following criteria (4 pts):
SELECT  P.ProductId,												-- b. Query should return the following fields: Product Id, 
		P.ProductName,												-- Product Name, Brand Name, Category Name and Quantity
		B.BrandName,
		C.CategoryName,
		S.Quantity
FROM [SQL4DevsDb].[dbo].[Stock] S
INNER JOIN [dbo].[Product] P
ON S.ProductId = P.ProductId
INNER JOIN [dbo].[Brand] B
ON P.BrandId = B.BrandId
INNER JOIN [dbo].[Category] C
ON P.CategoryId = C.CategoryId
WHERE S.StoreId = 2 AND (P.ModelYear = 2017 OR P.ModelYear = 2018)   -- a. Query all Products from Baldwin Bikes store with the model year of 2017 to 2018
ORDER BY S.Quantity DESC, P.ProductName ASC, B.BrandName ASC, C.CategoryName ASC -- c. Result set should be sorted from the highest quantity, Product Name, Brand Name and Category Name


 -- 3. Write a script with the following criteria (3 pts):
SELECT  S.StoreName,									-- a. Return the total number of orders per year and store name
		YEAR(O.OrderDate) AS OrderYear,					-- b. Query should return the following fields: Store Name, Order Year and the Number of Orders of that year
		COUNT(O.OrderDate) AS OrderCount
FROM [dbo].[Order] O
INNER JOIN [dbo].[Store] S
ON O.StoreId = S.StoreId
GROUP BY YEAR(O.OrderDate), S.StoreName
ORDER BY S.StoreName ASC, YEAR(O.OrderDate) DESC		-- c. Result set should be sorted by Store Name and most recent order year


 -- 4.Write a script with the following criteria (4 pts):
WITH
  TopFivePerBrand (BrandName, ProductId, ProductName, ListPrice, RowNo)
AS
(
	SELECT * FROM 
	(
		SELECT  B.BrandName,
				P.ProductId,
				P.ProductName,
				P.ListPrice,
				ROW_NUMBER() OVER (PARTITION BY B.BrandName Order by P.ListPrice DESC) AS RowNo
		FROM [dbo].[Product] P
		INNER JOIN [dbo].[Brand] B
		ON P.BrandId = B.BrandId
	)RNK 
	WHERE RowNo <=5						-- a. Using a CTE and Window function, select the top 5 most expensive products per brand
)
SELECT BrandName, ProductId, ProductName, ListPrice
FROM TopFivePerBrand
ORDER BY ListPrice DESC, ProductName    -- b. Data should be sorted by the most expensive product and product name


 -- 5.	Using the script from #3, use a cursor to print the records following the format below (3 pts):
DECLARE @StoreName VARCHAR(128);
DECLARE @OrderYear VARCHAR(128);
DECLARE @OrderCount INT;
DECLARE data_cursor CURSOR FOR 
SELECT  S.StoreName,									
		YEAR(O.OrderDate) AS OrderYear,					
		COUNT(O.OrderDate) AS OrderCount
FROM [dbo].[Order] O
INNER JOIN [dbo].[Store] S
ON O.StoreId = S.StoreId
GROUP BY YEAR(O.OrderDate), S.StoreName
ORDER BY S.StoreName ASC, YEAR(O.OrderDate) DESC

OPEN data_cursor;
FETCH NEXT FROM data_cursor INTO @StoreName, @OrderYear, @OrderCount;
WHILE @@FETCH_STATUS = 0
    BEGIN
    PRINT CONCAT(@StoreName, ' ', @OrderYear, ' ', @OrderCount);
    FETCH NEXT FROM data_cursor INTO @StoreName, @OrderYear, @OrderCount;
    END;
CLOSE data_cursor;
DEALLOCATE data_cursor;


 -- 6. Create a script with one loop is nested within another to output the multiplication tables for the numbers one to ten
DECLARE @i INT 
SET @i = 0
DECLARE @j INT 
WHILE (@i < 10) 
BEGIN
	SET @i = @i + 1
	SET @j = 0
	WHILE (@j < 10) 
	BEGIN
		SET @j = @j + 1
		PRINT CONVERT(VARCHAR, @i) + ' * ' + CONVERT(VARCHAR, @j) + ' = ' + CONVERT(VARCHAR, @i*@j)
	END
END


 -- 7.	Create a script using a PIVOT operator to get the monthly sales
SELECT * FROM 
(
	SELECT
	  YEAR(O.OrderDate) AS SaleYear,
	  DATENAME(MONTH, O.OrderDate) AS SaleMonth,
	  SUM(OI.ListPrice) AS Sales
	FROM [dbo].[Order] O								-- a. Use Order and OrderItem table
	INNER JOIN [dbo].[OrderItem] OI
	ON O.OrderId = OI.OrderId
	GROUP BY YEAR(O.OrderDate), DATENAME(MONTH, O.OrderDate) 
) SalesResults
PIVOT
(
	SUM(Sales) FOR SaleMonth IN (January, February,March, April, June, July, August, September, October, November, December )
)AS PivotTable  