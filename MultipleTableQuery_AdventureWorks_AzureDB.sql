/* Exploring SQL Queries using Multi-Table and Data Relationships

Overview:
In real-world databases, data is often distributed across multiple tables. The challenge lies in efficiently combining and analyzing this data to derive meaningful insights. 

This project demonstrates how SQL databases:
* Handle many-to-many relationships.
* Utilize entity relationship diagrams (ERDs).
* Apply various types of joins and unions.
* Use bridge tables for complex relationships.
* Implement reusable views.
* Using subqueries to enhance query flexibility and improve data retrieval.

Technology Used
1) SQL
2) Azure SQL Database
3) AdventureWorks Database: A Microsoft sample db representing a fictional bicycle manufacturing company, containing sales, customer, product, employee, and financial data
for learning SQL queries and database relationships.

*/

--Queries and Insights

-- Task 1. Identifying Top 100 Customers by Sales
--Retrieve the highest spending customers along with their email addresses.

SELECT TOP(100)
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
    DC.EmailAddress AS EmailAddress,
    SUM(FS.SalesAmount) AS AmountSpent
FROM FactInternetSales AS FS
INNER JOIN DimCustomer AS DC ON FS.CustomerKey = DC.CustomerKey
GROUP BY DC.FirstName, DC.LastName, DC.EmailAddress
ORDER BY AmountSpent DESC;

-- Task 2. Filtering Customers Who Paid in US Dollars
-- Refining the previous query to include only payments made in USD.

SELECT TOP(100)
    CONCAT(DC.FirstName, ' ', DC.LastName) AS CustomerName,
    DC.EmailAddress AS EmailAddress,
    SUM(FS.SalesAmount) AS AmountSpent
FROM FactInternetSales AS FS
INNER JOIN DimCustomer AS DC ON FS.CustomerKey = DC.CustomerKey
INNER JOIN DimCurrency AS DCy ON FS.CurrencyKey = DCy.CurrencyKey
WHERE DCy.CurrencyName = N'US Dollar'
GROUP BY DC.FirstName, DC.LastName, DC.EmailAddress, DCy.CurrencyName
ORDER BY AmountSpent DESC;

-- Task 3. Current Products and Their Sales Revenue
-- Identify all current products for internet sales, including those without any sales revenue.

SELECT
    DP.EnglishProductName AS ProductName,
    DP.Color AS ProductColor,
    ISNULL(DP.Size, 'Unknown') AS ProductSize,
    ISNULL(SUM(FS.SalesAmount), 0) AS Revenue
FROM FactInternetSales AS FS
RIGHT JOIN DimProduct AS DP ON FS.ProductKey = DP.ProductKey
WHERE DP.Status = N'Current'
GROUP BY DP.EnglishProductName, DP.Color, DP.Size
ORDER BY Revenue DESC;

-- Task 4. Top 5 Best-Selling Product Subcategories in the US
-- Ensuring only internet sales from the US, paid in USD, are included.

SELECT TOP (5)
    DPS.EnglishProductSubcategoryName AS SubcategoryName,
    SUM(FS.SalesAmount) AS TotalSales
FROM FactInternetSales AS FS
JOIN DimProduct AS DP ON FS.ProductKey = DP.ProductKey
JOIN DimProductSubcategory AS DPS ON DP.ProductSubcategoryKey = DPS.ProductSubcategoryKey
JOIN DimCurrency AS DCy ON FS.CurrencyKey = DCy.CurrencyKey
JOIN DimSalesTerritory AS DST ON FS.SalesTerritoryKey = DST.SalesTerritoryKey
WHERE DCy.CurrencyName = 'US Dollar' AND DST.SalesTerritoryCountry = 'United States'
GROUP BY DPS.EnglishProductSubcategoryName
ORDER BY TotalSales DESC;

-- Task 5. Sales and Promotions Summary (2012-2013)
-- A combined summary of sales and promotions from internet and reseller sales.

SELECT
    'Internet' AS Source,
    FS.SalesOrderNumber AS InvoiceNo,
    FS.OrderDate AS OrderDate,
    FS.OrderQuantity AS Quantity,
    DP.EnglishProductName AS ProductName,
    DST.SalesTerritoryCountry AS Country,
    DPr.EnglishPromotionName AS PromotionName,
    DCy.CurrencyName AS Currency
FROM FactInternetSales AS FS
INNER JOIN DimProduct AS DP ON FS.ProductKey = DP.ProductKey
INNER JOIN DimSalesTerritory AS DST ON FS.SalesTerritoryKey = DST.SalesTerritoryKey
INNER JOIN DimPromotion AS DPr ON FS.PromotionKey = DPr.PromotionKey
INNER JOIN DimCurrency AS DCy ON FS.CurrencyKey = DCy.CurrencyKey
WHERE YEAR(FS.OrderDate) IN (2012, 2013)

UNION

SELECT
    DR.ResellerName AS Source,
    FS.SalesOrderNumber AS InvoiceNo,
    FS.OrderDate AS OrderDate,
    FS.OrderQuantity AS Quantity,
    DP.EnglishProductName AS ProductName,
    DST.SalesTerritoryCountry AS Country,
    DPr.EnglishPromotionName AS PromotionName,
    DCy.CurrencyName AS Currency
FROM FactResellerSales AS FS
INNER JOIN DimProduct AS DP ON FS.ProductKey = DP.ProductKey
INNER JOIN DimSalesTerritory AS DST ON FS.SalesTerritoryKey = DST.SalesTerritoryKey
INNER JOIN DimPromotion AS DPr ON FS.PromotionKey = DPr.PromotionKey
INNER JOIN DimCurrency AS DCy ON FS.CurrencyKey = DCy.CurrencyKey
INNER JOIN DimReseller AS DR ON FS.ResellerKey = DR.ResellerKey
WHERE YEAR(FS.OrderDate) IN (2012, 2013);

--6. Saving Query for Future Use
--Creating a view for easy retrieval of order data.

CREATE VIEW vwOrdersAll AS
SELECT ...  -- (Same query as above for combined sales summary)
GO;

--7. Fetching Latest Day’s Sales Transactions
--Using a subquery to dynamically fetch the most recent order date.

SELECT
    InvoiceNumber,
    InvoiceLineNumber,
    OrderDate,
    SalesAmount,
    ProductName,
    ProductSubCategory
FROM vwOrdersAll
WHERE OrderDate = (SELECT MAX(OrderDate) FROM vwOrdersAll);

-- Task 8. Identifying Sales Representatives in Europe
-- Retrieving sales representatives or managers based in Europe, along with their total sales.

SELECT
    CONCAT(DE.FirstName, ' ', DE.LastName) AS EmployeeName,
    DE.Title AS EmployeeTitle,
    DCy.CurrencyName AS Currency,
    SUM(SalesAmount) AS TotalAmountSales
FROM FactResellerSales AS FS
INNER JOIN DimEmployee AS DE ON FS.EmployeeKey = DE.EmployeeKey
INNER JOIN DimSalesTerritory AS DST ON FS.SalesTerritoryKey = DST.SalesTerritoryKey
INNER JOIN DimCurrency AS DCy ON FS.CurrencyKey = DCy.CurrencyKey
WHERE [Status] = N'Current' AND DST.SalesTerritoryGroup = N'Europe'
GROUP BY DE.FirstName, DE.LastName, DE.Title, DCy.CurrencyName
ORDER BY EmployeeName, TotalAmountSales DESC;


/* Conclusion:
This project showcases how SQL can be used to efficiently query and analyze data across multiple tables. 
By leveraging joins, unions, views and subqueries, businesses can extract critical insights for decision-making. 
The techniques demonstrated here are fundamental for database management, business intelligence, and data analysis roles.
*/

