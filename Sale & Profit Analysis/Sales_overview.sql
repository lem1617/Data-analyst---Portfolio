-- Overview sale data and order by date
SELECT * 
FROM AdventureWorks_Sales_2016 
ORDER BY 1

-- Union with 2016 sale data 
SELECT * 
FROM AdventureWorks_Sales_2016
UNION (
        SELECT * 
		FROM AdventureWorks_Sales_2017 
		)
ORDER BY 1 DESC

-- Looking at number of order by productkey
SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS order_number
FROM (
       SELECT * FROM AdventureWorks_Sales_2016
	   UNION 
	   SELECT * FROM AdventureWorks_Sales_2017
	   ) AS sale
GROUP BY sale.ProductKey, sale.TerritoryKey

-- Join Return to get return quality

SELECT sa.OrderDate, sa.StockDate, sa.ProductKey, sa.CustomerKey, sa.OrderQuantity, re.ReturnDate, re.ReturnQuantity
FROM AdventureWorks_Sales_2016 sa
LEFT JOIN AdventureWorks_Returns re 
		ON sa.ProductKey=re.ProductKey
		AND sa.TerritoryKey=re.TerritoryKey

-- Calculate return rate by productkey

WITH product_summary(ProductKey, TerritoryKey, order_number, return_number, return_qty)
AS
(
SELECT 
		order_groupby.*, r.return_number,
		CASE 
		WHEN r.return_number IS NOT NULL THEN r.return_number ELSE 0 END AS return_qty -- Replace null value by 0
FROM (
		
		SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS order_number -- Get number of order by productkey
		FROM (
				SELECT * FROM AdventureWorks_Sales_2016
				UNION 
				SELECT * FROM AdventureWorks_Sales_2017
				) AS sale
		GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
LEFT JOIN (
				SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS return_number
				FROM AdventureWorks_Returns re 
				GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
			)

SELECT ps.ProductKey, ps.order_number, ps.return_qty,
				(ps.return_qty/ps.order_number)*100 AS return_rate, -- Calculate return rate
				p.ProductSKU, p.ProductName, p.ModelName, p.ProductCost, p.ProductPrice
FROM product_summary ps
LEFT JOIN AdventureWorks_Products p
	ON ps.ProductKey = p.ProductKey
ORDER BY 4 DESC


-- Create Temp Table

DROP TABLE IF EXISTS #Summary_order_return_of_product
CREATE TABLE #Summary_order_return_of_product
(
product_key numeric,
terri_key numeric,
order_qty numeric,
return_number numeric,
return_qty numeric
)
INSERT INTO #Summary_order_return_of_product
SELECT 
		order_groupby.*, r.return_number,
		CASE 
		WHEN r.return_number IS NOT NULL THEN r.return_number ELSE 0 END AS return_qty -- Replace null value by 0
FROM (
		
		SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS order_number -- Get number of order by productkey
		FROM (
				SELECT * FROM AdventureWorks_Sales_2016
				UNION 
				SELECT * FROM AdventureWorks_Sales_2017
				) AS sale
		GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
LEFT JOIN (
				SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS return_number
				FROM AdventureWorks_Returns re 
				GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
			
SELECT * FROM #Summary_order_return_of_product

-- Create view

CREATE VIEW product_summary AS
WITH product_summary(ProductKey, TerritoryKey, order_number, return_number, return_qty)
AS
(
SELECT 
		order_groupby.*, r.return_number,
		CASE 
		WHEN r.return_number IS NOT NULL THEN r.return_number ELSE 0 END AS return_qty -- Replace null value by 0
FROM (
		
		SELECT sale.ProductKey, sale.TerritoryKey, SUM(sale.OrderQuantity) AS order_number -- Get number of order by productkey
		FROM (
				SELECT * FROM AdventureWorks_Sales_2016
				UNION 
				SELECT * FROM AdventureWorks_Sales_2017
				) AS sale
		GROUP BY sale.ProductKey, sale.TerritoryKey
		) AS order_groupby
LEFT JOIN (
				SELECT re.ProductKey, re.TerritoryKey, SUM(re.ReturnQuantity) AS return_number
				FROM AdventureWorks_Returns re 
				GROUP BY re.ProductKey, re.TerritoryKey ) AS r
			ON order_groupby.ProductKey = r.ProductKey
			AND order_groupby.TerritoryKey = r.TerritoryKey
			)

SELECT ps.ProductKey, ps.order_number, ps.return_qty,
				(ps.return_qty/ps.order_number)*100 AS return_rate, -- calculate return rate
				p.ProductSKU, p.ProductName, p.ModelName, p.ProductCost, p.ProductPrice
FROM product_summary ps
LEFT JOIN AdventureWorks_Products p
	ON ps.ProductKey = p.ProductKey