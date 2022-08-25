Select *
From [PortfolioProject1.0]..Orders 
Order by Profit DESC

-- CALCULATE THE HOW LONG FOR SHIPPING THE ORDERS EXECUTED TO DETERMINE DELAYED SHIPPING 

SELECT
DATEDIFF (DAY,[Order_date],[Shiping_date]) Shiping_duration
From [PortfolioProject1.0]..Orders 

-- CREATE A NEW COLUMN FOR SHIPPING DURATION

 ALTER TABLE [PortfolioProject1.0]..Orders 
 ADD Shiping_duration INT

  UPDATE  [PortfolioProject1.0]..Orders 
 SET Shiping_duration = DATEDIFF (DAY,[Order_date],[Shiping_date])

 -- CONVERT THE ORDER AND SHIPPING DATE FROM DATETIME TO DATE FORMAT

SELECT 
    CAST([Order Date] AS DATE) [Order_Date]
From [PortfolioProject1.0]..Orders

ALTER TABLE [PortfolioProject1.0]..Orders 
 ADD [Order_date] DATE

  UPDATE  [PortfolioProject1.0]..Orders 
 SET [Order_Date] = CAST([Order Date] AS DATE)


SELECT 
    CAST([Ship Date] AS DATE) [Shiping_Date]
From [PortfolioProject1.0]..Orders

ALTER TABLE [PortfolioProject1.0]..Orders 
 ADD [Shiping_date] DATE


  UPDATE  [PortfolioProject1.0]..Orders 
 SET [Shiping_date] = CAST([Ship Date] AS DATE)


Select COUNT (*)
From [PortfolioProject1.0]..Orders 

Select 
AVG(Shiping_duration) avg_ship,
MAX(Shiping_duration) max_ship,
MIN(Shiping_duration) min_ship
From [PortfolioProject1.0]..Orders 

-- WE NEED TO INVESTIGATE FOR DUPLICATION OF DATA

Select [Order ID]
From [PortfolioProject1.0]..Orders


Select DISTINCT [Order ID]
From [PortfolioProject1.0]..Orders


--We found that there are 5009 distinct order IDs created, which mostly have multiple product IDs
--We found also that a total number of 9994 rows(transactions) are contained in the Order table.

----IDENTIFY DUPLICATES FROM ORDERS BY ASSIGNING ROW NUMBER

Select 
ROW_NUMBER ()OVER(Order by [Order ID])as Row_N, 
[Order ID], [Product Name],City,[Order_Date],[Shiping_date],[Customer Name],Region,Category,[Sub-Category],Quantity,Sales,Profit 
From [PortfolioProject1.0]..Orders

--From above result we can conclude that every row is unique and there are no duplicates.


 --- 1.0

 -- INVESTIGATE THE RETURNED ORDERS (POPULATE THE RETURNS TABLE (A) USING LEFT JOIN WITH THE ORDERS TABLE (B))
 
Select *
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Order by b.Profit DESC

----DETERMINE THE AVERAGE SHIPPING DURATION FOR RETURNED ORDERS GROUP BY SHIP MODE

Select AVG(b.Shiping_duration) avg_shiping_duration, [Ship Mode]
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Group by [Ship Mode]



--It is observed that there are 4 classes of shiping with their corresponding average shiping duration; Same day = 0, 
-- First class = 2 days, Second Class = 3 Days, Standard  = 5 days. Therefore we will investigate the shiping duration for returned
--Orders to verify if delayed shiping could be a factor.


-- GROUP RETURNED ORDERS BASED ON SHIPING DURATION AND SHIPING MODE

Select [Shiping_duration], COUNT([Shiping_duration]) Count, [Ship Mode] 
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Group by Cube ([Shiping_duration], [Ship Mode])


-- 2.0

--SORT RETURNED ORDER PER STATE AND REGION 

Select  [State], [Region],COUNT([State]) ReturnedOrder_Per_state_Region
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Group by cube ([State],REGION)
Order by ReturnedOrder_Per_state_Region DESC


--THE CODE BELOW IS CORRECT BUT ITS A LENGTHY ONE, A BETTER APPROACH ABOVE;

--Select  [State], [Region],COUNT([State]) ReturnedOrder_Per_state_Region
--From [PortfolioProject1.0]..Returns a
--RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
--ON a.[Order ID] = b.[Order ID]
--Where a.[Order ID] IS NOT NULL
--Group by cube ([State],REGION)
--Order by ReturnedOrder_Per_state_Region DESC



-- 3.0

--RETURNED PER CATEGORY

Select  [Category],[Sub-Category],COUNT([Product Name]) ReturnedOrder
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Group by cube ([Sub-Category],Category)
Order by ReturnedOrder DESC
--Order by [Sales] DESC


--- 4.0

--- SORT BY THE ACTUAL PRODUCT NAME AND SALES RETURNED
 
Select  [Product Name],COUNT([Product Name]) ReturnedOrder,SUM([Sales])Revenue
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
LEFT JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Group by cube ([Product Name],[Sales])
Order by Revenue DESC,ReturnedOrder DESC


-- Since there are no Product ID on the return order sheet, it is assumed that all the product on the affected orders have been returned

--- 5.0

--Determine the successfully executed orders (Using Left anti join i.e NOT IN )

Select *
--a.[Order ID],b.[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
--AVG([Shiping_duration])
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns)

--USING SUBQUERY IN THE WHERE CLAUSE WITH EXISTS TO GROUP THE SHIPING DURATION FOR THE ORDER TABLE.

Select [Shiping_duration], COUNT(Shiping_duration)
From [PortfolioProject1.0]..Orders 
WHERE EXISTS
(Select [Order ID],[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns
))
Group by [Shiping_duration]

--GROUP THE SUCCESSFUL ORDERS BASED ON AVERAGE DURATIONS

Select [Order ID], AVG(Shiping_duration) shipingAvg
From [PortfolioProject1.0]..Orders 
WHERE EXISTS
(Select [Order ID],[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns
))
Group by [Order ID]
Order by shipingAvg DESC


--DETERMINE THE AVERAGE DURATION OF SUCCESSFUL ORDERS GROUP BY SHIP MODE

Select AVG(Shiping_duration) shipingAvg,[Ship Mode]
From [PortfolioProject1.0]..Orders 
WHERE EXISTS
(Select [Order ID],[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],
Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns)
)
Group by [Ship Mode]
--Group by a.[Order ID]
--Order by shipingAvg DESC

-- 7.0

--- GROUP SUCCESSFUL ORDERS BASED ON THE SHIP MODE AND SHIPING DURATION

Select [Shiping_duration], COUNT([Shiping_duration]) Count, [Ship Mode] 
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Orders
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns
)
Group by Cube ([Shiping_duration], [Ship Mode])

-- 8.0

-- TOTAL REVENUE PER REGION AND STATE

Select [Sales], SUM([Sales]) Revenue, [State],[Region]
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns
)
Group by Cube ([Sales], [State],[Region])
Order by Revenue DESC


Select [Product Name], SUM([Sales]) OVER(PARTITION BY [Product Name] ORDER BY [Sales]) Total_Revenue,
[Order ID],[Product ID],Category,[Sub-Category],
Region,City,[Ship Mode],Segment,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders 
Where [Order ID] NOT IN ( Select *
 From [PortfolioProject1.0]..Returns
)


--DELETE UNUSED COLUMNS

 Select *
 From [PortfolioProject1.0]..Orders 

 ALTER TABLE [PortfolioProject1.0]..Orders 
 DROP COLUMN [Order Date], [Ship Date]

 
