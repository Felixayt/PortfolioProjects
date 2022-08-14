Select *
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Orders 
Order by Profit DESC

-- Calculate the how long for shipping the Orders executed to determine Delayed Shipping 

SELECT
DATEDIFF (DAY,[Order_date],[Shiping_date]) Shiping_duration
From [PortfolioProject1.0]..Orders 


 ALTER TABLE [PortfolioProject1.0]..Orders 
 ADD Shiping_duration INT

  UPDATE  [PortfolioProject1.0]..Orders 
 SET Shiping_duration = DATEDIFF (DAY,[Order_date],[Shiping_date])


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


Select [Order ID]
From [PortfolioProject1.0]..Orders


Select DISTINCT [Order ID]
From [PortfolioProject1.0]..Orders


--We found that there are 5009 distinct order IDs created, which have in some cases multiple product IDs
--We found also that a total number of 9994 rows(transactions) are contained in the Order table, of which there 

----Identify duplicates from Orders by assigning Row number

Select 
ROW_NUMBER ()OVER(Order by [Order ID])as Row_N, 
[Order ID], [Product Name],City,[Order Date],[Ship Date],[Customer Name],Region,Category,[Sub-Category],Quantity,Sales,Profit 
From [PortfolioProject1.0]..Orders




  --- 1.0

 -- Investigate the Returned Orders
 
Select *
--a.[Order ID],b.[Product Name],b.[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],
--Segment,Sales,Profit,b.Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Order by b.Profit DESC

----DETERMINE THE AVERAGE SHIPPING DURATION FOR RETURNED ORDERS GROUP BY SHIP MODE

Select AVG(b.Shiping_duration) avg_shiping_duration, [Ship Mode]
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Group by [Ship Mode]

-- 6.0

--It is observed that there are 4 classes of shiping with their corresponding average shiping duration; Same day = 0, 
-- First class = 2 days, Second Class = 3 Days, Standard  = 5 days. Therefore we will investigate the shiping duration for returned
--Orders to verify if delayed shiping could be a factor.


-- Group Returned Orders based on Shiping duration and Shiping mode

Select [Shiping_duration], COUNT([Shiping_duration]) Count, [Ship Mode] 
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Group by Cube ([Shiping_duration], [Ship Mode])


-- 2.0

--SORT RETURNED ORDER PER STATE AND REGION 

Select  [State], [Region],COUNT([State]) ReturnedOrder_Per_state_Region
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Group by cube ([State],REGION)
Order by ReturnedOrder_Per_state_Region DESC

-- 3.0

--RETURNED PER CATEGORY

Select  [Category],[Sub-Category],COUNT([Product Name]) ReturnedOrder
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Group by cube ([Sub-Category],Category)
Order by ReturnedOrder DESC
--Order by [Sales] DESC



--- 4.0

--- SORT BY THE ACTUAL PRODUCT NAME AND SALES RETURNED
 
Select  [Product Name],COUNT([Product Name]) ReturnedOrder,SUM([Sales])Revenue
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Returns a
RIGHT OUTER JOIN [PortfolioProject1.0]..Orders b
ON a.[Order ID] = b.[Order ID]
Where a.[Order ID] IS NOT NULL
Group by cube ([Product Name],[Sales])
Order by Revenue DESC,ReturnedOrder DESC


--Since there are no Product ID on the return order sheet, it is assumed that all the product on the affected orders have been returned

---5.0

--Determine the successfully executed orders

Select *
--a.[Order ID],b.[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
--AVG([Shiping_duration])
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL
--Order by Profit DESC

--Using Subquery in the where clause with exists to group the shiping duration for the Order table.

Select [Shiping_duration], COUNT(Shiping_duration)
From [PortfolioProject1.0]..Orders a
WHERE EXISTS
(Select a.[Order ID],b.[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL)
Group by [Shiping_duration]

--Group the successful orders based on Average durations

Select a.[Order ID], AVG(Shiping_duration) shipingAvg
From [PortfolioProject1.0]..Orders a
WHERE EXISTS
(Select a.[Order ID],b.[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL)
Group by a.[Order ID]
Order by shipingAvg DESC


--Determine the average duration of successful orders group by ship Mode

Select AVG(Shiping_duration) shipingAvg,[Ship Mode]
From [PortfolioProject1.0]..Orders a
WHERE EXISTS
(Select a.[Order ID],b.[Order ID] Returned_Order,[Product Name],[Product ID],Category,[Sub-Category],
Region,City,[Ship Mode],Segment,Sales,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL)
Group by [Ship Mode]
--Group by a.[Order ID]
--Order by shipingAvg DESC

-- 7.0

--- Group Successful orders based on the ship mode and shiping duration

Select [Shiping_duration], COUNT([Shiping_duration]) Count, [Ship Mode] 
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL
Group by Cube ([Shiping_duration], [Ship Mode])

-- 8.0

-- Total Revenue per Region and state

Select [Sales], SUM([Sales]) Revenue, [State],[Region]
--DATEDIFF (DAY,[Order date],[Ship date]) Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL
Group by Cube ([Sales], [State],[Region])
Order by Revenue DESC


Select [Product Name], SUM([Sales]) OVER(PARTITION BY [Product Name] ORDER BY [Sales]) Total_Revenue,
a.[Order ID],[Product ID],Category,[Sub-Category],
Region,City,[Ship Mode],Segment,Profit,Shiping_duration
From [PortfolioProject1.0]..Orders a
LEFT OUTER JOIN [PortfolioProject1.0]..Returns b
ON a.[Order ID] = b.[Order ID]
Where b.[Order ID] IS NULL


--DELETE UNUSED COLUMNS

 Select *
 From [PortfolioProject1.0]..Orders 

 ALTER TABLE [PortfolioProject1.0]..Orders 
 DROP COLUMN [Order Date], [Ship Date]

 
