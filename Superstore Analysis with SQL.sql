USE projects;

SELECT *
FROM superstore
ORDER BY OrderDate
;

DESCRIBE superstore;

ALTER TABLE superstore
MODIFY COLUMN OrderDate TEXT,
MODIFY COLUMN ShipDate TEXT
;
UPDATE superstore
SET OrderDate = str_to_date(OrderDate, '%d/%m/%Y')
;
UPDATE superstore
SET ShipDate = str_to_date(ShipDate, '%d/%m/%Y')
;

SELECT EXTRACT(YEAR FROM OrderDate) AS YearOrder, COUNT(OrderDate) AS NumOrder
FROM superstore
GROUP BY EXTRACT(YEAR FROM OrderDate) 
ORDER BY EXTRACT(YEAR FROM OrderDate)
;

SELECT EXTRACT(YEAR FROM OrderDate) AS YearOrder, EXTRACT(MONTH FROM OrderDate) AS MonthOrder, COUNT(OrderDate) AS NumOrder
FROM superstore
GROUP BY EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)
ORDER BY EXTRACT(YEAR FROM OrderDate), EXTRACT(MONTH FROM OrderDate)
;

SELECT ShipMode, COUNT(*) as NumShip
FROM superstore
GROUP BY ShipMode
ORDER BY NumShip DESC
;

SELECT CustomerID, COUNT(*) as NumOrder
FROM superstore
GROUP BY CustomerID
HAVING COUNT(*) > 10
ORDER BY NumOrder DESC
;

SELECT EXTRACT(YEAR FROM OrderDate) AS YearOrder, Segment, COUNT(*) as NumOrder
FROM superstore
GROUP BY EXTRACT(YEAR FROM OrderDate), Segment
ORDER BY EXTRACT(YEAR FROM OrderDate), NumOrder DESC
;

WITH percent AS(
SELECT Country, ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM superstore),2) AS Percentage
FROM superstore
GROUP BY Country
ORDER BY Percentage
)
SELECT Country, CONCAT(Percentage, '%') AS PercentageNumOrder
FROM percent
;

WITH percent AS(
SELECT State, ROUND(100.0*COUNT(*)/(SELECT COUNT(*) FROM superstore),2) AS Percentage
FROM superstore
GROUP BY State
ORDER BY Percentage
)
SELECT State, CONCAT(Percentage, '%') AS PercentageNumOrder
FROM percent
WHERE Percentage >= 5
ORDER BY Percentage DESC
;

SELECT Category, COUNT(*) as NumOrder, SUM(Quantity) as QuantityNum
FROM superstore
GROUP BY Category
ORDER BY NumOrder DESC
;

WITH 
cat AS(
SELECT Category, COUNT(*) as NumOrder
FROM superstore
GROUP BY Category
),
maxcatorder as (
SELECT Category as MaxCatOrder
FROM cat
WHERE NumOrder = (SELECT MAX(NumOrder) FROM cat)
)
SELECT superstore.SubCategory, COUNT(*) as NumOrder
FROM superstore
JOIN maxcatorder ON superstore.Category = maxcatorder.MaxCatOrder
GROUP BY superstore.SubCategory
ORDER BY NumOrder DESC;
;

WITH 
cat AS(
SELECT Category, SUM(Quantity) as QuantityNum
FROM superstore
GROUP BY Category
),
maxcatquantity as (
SELECT Category as MaxCatQuantity
FROM cat
WHERE QuantityNum = (SELECT MAX(QuantityNum) FROM cat)
)
SELECT superstore.SubCategory, SUM(superstore.Quantity) as QuantityNum
FROM superstore
JOIN maxcatquantity ON superstore.Category = maxcatquantity.MaxCatQuantity
GROUP BY superstore.SubCategory
ORDER BY QuantityNum DESC;
;

SELECT ProductName, SUM(Quantity) as QuantityNum
FROM superstore
GROUP BY ProductName
HAVING SUM(Quantity) > 20
ORDER BY QuantityNum DESC
;

SELECT Category, SUM(Quantity) as QuantityNum, ROUND(SUM(Sales),2) as TotalSales, ROUND(100.0*SUM(Sales)/(SELECT SUM(Sales) FROM superstore),2) as Percentage
FROM superstore
GROUP BY Category
ORDER BY TotalSales DESC
;

SELECT State, 
ROUND(SUM(CASE WHEN Category = 'Furniture' THEN Profit ELSE 0 END),2) as FurnitureProfit,
ROUND(SUM(CASE WHEN Category = 'Office Supplies' THEN Profit ELSE 0 END),2) as OfficeSuppliesProfit,
ROUND(SUM(CASE WHEN Category = 'Technology' THEN Profit ELSE 0 END),2) as TechnologyProfit,
ROUND(SUM(Profit),2) as TotalProfit
FROM superstore
GROUP BY State
ORDER BY TotalProfit DESC
;

SELECT EXTRACT(YEAR FROM OrderDate) as YearOrder, State, ROUND(SUM(Profit),2) TotalProfit
FROM superstore
GROUP BY EXTRACT(YEAR FROM OrderDate), State
ORDER BY EXTRACT(YEAR FROM OrderDate), State
;
