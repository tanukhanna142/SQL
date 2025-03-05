/* Exploring SQL Queries using Single Table  

Overview: 
The project focuses on leveraging SQL and Azure SQL Database to optimize data retrieval, transformation and aggregation using the AdventureWorks Database.

This project specifically works on individual tables in AdventureWorks DB, demonstrating SQL capabilities in:
* Selecting and filtering relevant data efficiently
* Standardizing and transforming data formats
* Aggregating and summarizing business insights
* Sorting, limiting, and optimizing large datasets
* Using advanced SQL techniques for structured querying

AdventureWorks Database is a  Microsoft sample DB representing a fictional bicycle manufacturing company, 
containing sales, customer, product, employee and financial data for learning SQL queries and Database relationships.

By applying these SQL techniques, the project enhances data-driven decision-making and showcases best practices in query optimization.
*/

--Queries and Insights

-- Task 1. Retrieving only the most relevant data
-- To ensure efficiency, only the necessary columns—SalesOrderNumber, OrderDate, SalesAmount, TaxAmt, and OrderQuantity—were selected, eliminating unnecessary data retrieval.

SELECT 
	SalesOrderNumber, 
	OrderDate, 
	SalesAmount, 
	TaxAmt, 
	OrderQuantity

FROM FactInternetSales;

-- Task 2. Improving query readability
-- To enhance clarity, aliases were used to rename SalesOrderNumber to InvoiceNumber for better understanding.

SELECT 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate, 
	SalesAmount, 
	TaxAmt, 
	OrderQuantity

FROM FactInternetSales;

-- Task 3. Standardizing data formats for consistency
-- OrderDate was formatted to remove the time component, and SalesAmount was converted to whole numbers for uniform reporting.

SELECT 
	SalesOrderNumber AS InvoiceNumber,
    	CAST(OrderDate AS DATE) AS OrderDateFormatted,
    	CAST(SalesAmount AS INT) AS SalesAmountRounded
	
FROM FactInternetSales;

-- Task 4. Filtering data for specific market insights
-- By narrowing the dataset to sales in Canada (SalesTerritoryKey = 6), region-specific insights were gained.

SELECT 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate, 
	SalesAmount, 
	TaxAmt, 
	OrderQuantity

FROM FactInternetSales
WHERE SalesTerritoryKey = 6;

-- Task 5. Summarizing business data efficiently
-- Sales data per invoice was aggregated to analyze revenue contributions from different orders.

SELECT 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate,
	SUM(SalesAmount) AS InvoiceSubTotal, 
	SUM(TaxAmt) AS TotalTax, 
	SUM(OrderQuantity) AS TotalOrderQuantity
	
FROM FactInternetSales
WHERE SalesTerritoryKey = 6
GROUP BY SalesOrderNumber, OrderDate;

-- Task 6. Filtering aggregated data for better insights
-- To identify high-value orders, invoices where total sales exceeded $1,000 were filtered.

SELECT 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate,
	SUM(SalesAmount) AS InvoiceSubTotal, 
	SUM(TaxAmt) AS TotalTax, 
	SUM(OrderQuantity) AS TotalOrderQuantity
	
FROM FactInternetSales
WHERE SalesTerritoryKey = 6
GROUP BY SalesOrderNumber, OrderDate
HAVING SUM(SalesAmount) > 1000;

-- Task 7. Sorting data to highlight top-performing sales
--Sorting invoices by total sales in descending order helped prioritize key transactions.

SELECT TOP(10) 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate,
	SUM(SalesAmount) AS InvoiceSubTotal, 
	SUM(TaxAmt) AS TotalTax, 
	SUM(OrderQuantity) AS TotalOrderQuantity
	
FROM FactInternetSales
WHERE SalesTerritoryKey = 6
GROUP BY SalesOrderNumber, OrderDate
HAVING SUM(SalesAmount) > 1000
ORDER BY InvoiceSubTotal DESC;

-- Task 8. Optimizing data retrieval for large datasets
-- Using OFFSET FETCH enabled pagination, and DISTINCT helped in retrieving unique customer records.
-- Retrieve the top 10 invoices after skipping the first 2

SELECT 
	SalesOrderNumber AS InvoiceNumber, 
	OrderDate,
    	SUM(SalesAmount) AS InvoiceSubTotal, 
	SUM(TaxAmt) AS TotalTax, 
	SUM(OrderQuantity) AS TotalOrderQuantity

FROM FactInternetSales
WHERE SalesTerritoryKey = 6
GROUP BY SalesOrderNumber, OrderDate
HAVING SUM(SalesAmount) > 1000
ORDER BY InvoiceSubTotal DESC
OFFSET 2 ROWS FETCH NEXT 10 ROWS ONLY;

-- Retrieve unique customer keys

SELECT 
	DISTINCT CustomerKey

FROM FactInternetSales
ORDER BY CustomerKey DESC;

-- Task 9. Aggregates and Filtering Data
-- Count customers and summarize income

SELECT 
	COUNT(*) AS TotalCustomers, 
	AVG(YearlyIncome) 
	
FROM DimCustomer;

-- Retrieve finished goods products

SELECT * 
FROM DimProduct 
WHERE FinishedGoodsFlag = 1;

-- Task 10. Date & Time Functions
-- Retrieve current timestamp along with due and ship dates

SELECT 
	GETDATE() AS DateTimeStamp, 
	DueDate, 
	ShipDate 
	
FROM FactInternetSales;

-- Calculate days between ship date and due date

SELECT 
	DueDate, 
	ShipDate, 
	DATEDIFF(day, ShipDate, DueDate) AS DaysGap 

FROM FactInternetSales;

-- Task 11. Text Manipulation and Data Formatting
-- Extract month name and number from DueDate

SELECT 
	DueDate, 
	MONTH(DueDate) AS MonthNumerical, 
	DATENAME(MONTH, DueDate) AS MonthName 
	
FROM FactInternetSales;

-- Retrieve customer names starting with 'R' for promotions

SELECT 
	CONCAT(FirstName, ' ', LastName) AS CustomerName, 
	EmailAddress 

FROM DimCustomer WHERE FirstName LIKE 'R%';

-- Categorizing income as Above or Below Average

SELECT 
	CONCAT(FirstName, ' ', LastName) AS CustomerName, 
	EmailAddress, 
	YearlyIncome, 
	IIF (YearlyIncome > 50000, 'Above Average', 'Below Average') AS IncomeCategory 

FROM DimCustomer;

-- Categorizing number of children at home
SELECT 
    CONCAT(FirstName, 
       CASE WHEN MiddleName IS NOT NULL THEN CONCAT(' ', MiddleName) 
       ELSE '' 
       END, 
       ' ', LastName) AS CustomerName,
    EmailAddress,
    YearlyIncome,
    IIF (YearlyIncome > 50000, 
        'Above Average', 
        'Below Average') AS IncomeCategory,
    NumberChildrenAtHome AS ActualChildren,
    CASE
        WHEN NumberChildrenAtHome = 0 THEN '0'
        WHEN NumberChildrenAtHome = 1 THEN '1'
        WHEN NumberChildrenAtHome BETWEEN 2 AND 4 THEN '2-4'
        WHEN NumberChildrenAtHome >=5 THEN '5+'
        ELSE 'Unkwn'
    END AS NumberChildrenCategory
FROM DimCustomer;

/* Conclusion: 
This project demonstrates fundamental and advanced SQL techniques using the AdventureWorks Database.
Focuses on data selection, transformation, aggregation and optimization.
Essential for data analysis, reporting, and decision-making in real-world business scenarios.
/*
