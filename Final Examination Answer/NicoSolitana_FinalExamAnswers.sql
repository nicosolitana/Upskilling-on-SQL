-- FINAL EXAMINATION ANSWER ON UPSKILLING PROGRAM : SQL FOR DEVS
-- NICO SOLITANA


-- 1.  Implement a stored procedure that creates a new Brand 
-- and move all the Products of an existing brand (3 pts):

-- a. Implement a stored procedure that creates a new Brand and move all the Products of an existing brand (3 pts):
CREATE PROCEDURE [dbo].[CreateNewBrandAndMoveProducts]
	@NewBrandName	NVARCHAR(250),
	@OldBrandName	NVARCHAR(250),
	@Id				INT
AS
    -- d. Include transactions to catch errors
	BEGIN TRAN
	BEGIN TRY
	    -- b. Implement a stored procedure that creates a new Brand and move all the Products of an existing brand (3 pts):
		-- c. Delete the existing brand
		UPDATE [dbo].[Brand]
		SET [BrandName] = @NewBrandName
		WHERE [BrandId] = @Id And [BrandName] = @OldBrandName

		UPDATE [dbo].[Product]
		SET [ProductName] = REPLACE([ProductName], @OldBrandName, @NewBrandName)
		WHERE [BrandId] = @Id
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	    -- e. If there is an error – rollback the transaction
		ROLLBACK TRANSACTION
	END CATCH
GO


-- 2. Implement a stored procedure that returns a list of products with the following requirements (6pts):
CREATE PROCEDURE [dbo].[CreateNewBrandAndMoveProducts]
	@ProductName	NVARCHAR(250),
	@CategoryName	NVARCHAR(250),
	@BrandId		INT,
	@ModelYear		INT,
	@PageSize		INT,
	@Page			INT
AS
	DECLARE  @OffSetCount INT
	IF @PageSize = 0 or @PageSize is null
		SET @PageSize = 10								-- b. Supports pagination (Default page size: 10)
	SET @OffSetCount = (@Page-1) * @PageSize

	IF @ProductName is null 
		SET @ProductName = ''
	IF @CategoryName is null 
		SET @CategoryName = ''
	IF @BrandId is null 
		SET @BrandId = 0
	IF @ModelYear is null 
		SET @ModelYear = 0

	SELECT P.ProductId,
		   P.ProductName,
		   P.BrandId,
		   B.BrandName,
		   P.CategoryId,
		   C.CategoryName,
		   P.ModelYear,
		   P.ListPrice
	FROM [dbo].[Product] P
	LEFT JOIN [dbo].[Brand] B
	ON P.BrandId = B.BrandId
	LEFT JOIN [dbo].[Category] C
	ON P.CategoryId = C.CategoryId
	WHERE P.ProductName = @ProductName				-- a. Supports filtering, i. Filter products by product name
		  OR C.CategoryName = @CategoryName			-- ii.  Filter by brand id
		  OR P.BrandId = @BrandId					-- iii. Filter by category id 
		  OR P.ModelYear = @ModelYear				-- iv.  Filter by model year
	ORDER BY P.ModelYear DESC, P.ListPrice DESC, P.ProductName ASC   -- c. Result set should always be sorted by Latest Model Year, Highest List Price and Product Name
	OFFSET @OffSetCount ROWS						-- b. Supports pagination (Default page size: 10)
	FETCH NEXT @PageSize ROWS ONLY
GO


-- 3. Improve the slow running query below: (Pre-requisite - Create a backup of the dbo.Product
-- table) (3 pts). HINT: Do NOT use cursor
-- Declare variables to be used for looping and columns of Category Table
DECLARE @NumberRecords  INT, 
		@RowCounter		INT,
		@CategoryId		INT,
		@CategoryName	VARCHAR(250)

-- Create a Temporary Category Table with row ids
CREATE TABLE #CategoryTbl (
    RowID		 INT IDENTITY(1, 1),  -- used to replace cursor
    CategoryID	 INT,
    CategoryName VARCHAR(250)
 )

 -- Insert all data from Category table to the temporary Table CategoryTbl
INSERT INTO #CategoryTbl (CategoryID, CategoryName)
SELECT CategoryId, CategoryName
FROM [dbo].[Category] 

-- used to replace cursor : get number of rows to loop into
SET @NumberRecords = @@RowCount 
-- used to replace cursor : set initial counter
SET @RowCounter = 1


-- used to replace cursor: loop through each record using a while loop
WHILE @RowCounter <= @NumberRecords
BEGIN
	SELECT  @CategoryId = CategoryID, 
			@CategoryName = CategoryName
	FROM #CategoryTbl
	WHERE RowID = @RowCounter

	IF(@CategoryName = 'Children Bicycles'
			OR @CategoryName = 'Cyclocross Bicycles'
			OR @CategoryName = 'Road Bikes')
			BEGIN
				UPDATE [dbo].[Product20220623]
				SET ListPrice = (ListPrice * 1.2)
				WHERE CategoryId = @CategoryId;
		END;
		IF(@CategoryName = 'Comfort Bicycles'
			OR @CategoryName = 'Cruisers Bicycles'
			OR @CategoryName = 'Electric Bikes')
			BEGIN
				UPDATE [dbo].[Product20220623]
				SET ListPrice = (ListPrice * 1.7)
				WHERE CategoryId = @CategoryId;
		END;
		IF(@CategoryName = 'Mountain Bikes')
			BEGIN
				UPDATE [dbo].[Product20220623]
				SET ListPrice = (ListPrice * 1.4)
				WHERE CategoryId = @CategoryId;
		END;
	SET @RowCounter = @RowCounter + 1
END

-- used to replace cursor: drop temporary table
DROP TABLE #CategoryTbl


-- 4. Implement customer ranking (7 points)

-- a. Create a table called ‘Ranking’ with two columns – Id (primary key, identity), and Description
CREATE TABLE Ranking (
    Id				INT PRIMARY KEY IDENTITY(1, 1), 
    Description		VARCHAR(255)
);

-- b. Populate table Ranking with the following data
INSERT INTO Ranking (Description) VALUES ('Inactive');
INSERT INTO Ranking (Description) VALUES ('Bronze');
INSERT INTO Ranking (Description) VALUES ('Silver');
INSERT INTO Ranking (Description) VALUES ('Gold');
INSERT INTO Ranking (Description) VALUES ('Platinum');

-- c. Add a column to Customer table called RankingId and make it a foreign key to Ranking.Id
ALTER TABLE [dbo].[Customer]
ADD RankingId INT FOREIGN KEY REFERENCES Ranking(Id)

-- d. Add a column to Customer table called RankingId and make it a foreign key to Ranking.Id
CREATE PROCEDURE [dbo].[uspRankCustomers]
AS
	DECLARE @NumberRecords  INT, 
			@RowCounter		INT,
			@TotalAmount	INT,
			@CustomerID		INT,
			@RankingID		INT

	CREATE TABLE #CustomerTBL (
		RowID		 INT IDENTITY(1, 1), 
		CustomerID	 INT
	 )

	INSERT INTO #CustomerTBL (CustomerID)
	SELECT CustomerId
	FROM [dbo].[Customer] 

	-- Get the number of records in the temporary table
	SET @NumberRecords = @@RowCount 
	--You can use: SET @NumberRecords = SELECT COUNT(*) FROM #ActiveVisitors
	SET @RowCounter = 1


	-- loop through all records in the temporary table
	-- using the WHILE loop construct
	WHILE @RowCounter <= @NumberRecords
	BEGIN
		SELECT  @CustomerID = CustomerID
		FROM #CustomerTBL
		WHERE RowID = @RowCounter

		SELECT @TotalAmount = SUM((OI.Quantity * OI.ListPrice)/(1+OI.Discount))
		FROM [dbo].[Customer] C
		LEFT JOIN [dbo].[Order] O
		ON O.CustomerId = C.CustomerId
		LEFT JOIN [dbo].[OrderItem] OI
		ON OI.OrderId = O.OrderId
		WHERE C.CustomerId = @CustomerID

		IF @TotalAmount = 0
			SET @RankingID = 1
		ELSE IF @TotalAmount < 1000
			SET @RankingID = 2
		ELSE IF @TotalAmount < 2000
			SET @RankingID = 3
		ELSE IF @TotalAmount < 3000
			SET @RankingID = 4
		ELSE IF @TotalAmount >= 3000
			SET @RankingID = 5

		UPDATE [dbo].[Customer] 
		SET RankingId = @RankingID
		WHERE CustomerId = @CustomerID

		SET @RowCounter = @RowCounter + 1
	END

	-- drop the temporary table
	DROP TABLE #CustomerTBL
GO

-- To execute the stored procedure
EXEC [dbo].[uspRankCustomers]

-- e. Create a view vwCustomerOrders that will display
CREATE VIEW [vwCustomerOrders] AS
SELECT  C.CustomerId,
		C.FirstName,
		C.LastName,
		SUM((OI.Quantity * OI.ListPrice)/(1+OI.Discount)) As TotalAmount,
		R.Description
FROM [dbo].[Customer] C
LEFT JOIN [dbo].[Order] O
ON O.CustomerId = C.CustomerId
LEFT JOIN [dbo].[OrderItem] OI
ON OI.OrderId = O.OrderId
LEFT JOIN [dbo].[Ranking] R
ON C.RankingId = R.Id
GROUP BY C.CustomerId, C.FirstName, C.LastName, R.Description

-- To call the view
SELECT * FROM [vwCustomerOrders];


-- 5. Retrieve the Employee hierarchy under dbo.Staff. 
WITH CTE_STAFF_HIERARCHY AS    -- d. Use only recursive CTE
(
	SELECT  S.StaffId, 
			S.ManagerID, 
			CONCAT(S.FirstName, ' ', S.LastName) AS FullName, 
			CAST(
				CONCAT(S.FirstName, ' ', S.LastName)  AS NVARCHAR(MAX)
			) AS EmployeeHierarchy, 
			1 AS LEVEL
    FROM Staff AS S
    WHERE ManagerId IS NULL
    UNION ALL
    SELECT  E.StaffId, 
			E.ManagerID, 
			CONCAT(E.FirstName, ' ', E.LastName) AS FullName,    -- a. Select the staff’s full name (First Name + Last Name) plus the full name of its manager/s
			CONCAT(												 -- b.Display the top-level manager’s name first (comma separated)
				CAST(SH.EmployeeHierarchy AS NVARCHAR(MAX)),  N', ',      -- c. E.g. “Mireya Copeland” manager is “Fabiola Jackson“ so the result is “Fabiola Jackson,Mierya Copeland”
				CAST(CONCAT(E.FirstName, ' ', E.LastName)  AS NVARCHAR(MAX))), 
			LEVEL+1 
    FROM Staff AS E
    JOIN CTE_STAFF_HIERARCHY AS SH
    ON SH.StaffId = E.ManagerId 
)

SELECT  CSH.StaffId, 
		CSH.FullName, 
		CSH.EmployeeHierarchy
FROM CTE_STAFF_HIERARCHY CSH
ORDER BY CSH.StaffId ASC