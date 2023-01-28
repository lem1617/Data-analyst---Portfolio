-- 1- Average selling price by buyer country
SELECT country, AVG(price_sold) AS avg_selling_price
FROM dim_country AS d
	JOIN fct_prodcut_sold AS f
		ON d.id_country = f.ID_DELIVERY_COUNTRY
GROUP BY country;

-- 2- YTD number of products sold by sellers from EMEA to buyers from APAC
SELECT COUNT(ID_PRODUCT)
FROM fct_prodcut_sold AS f
	JOIN dim_country AS d1
		ON f.ID_DELIVERY_COUNTRY = d1.id_country
	JOIN dim_country AS d2
		ON f.id_seller_country = d2.id_country
WHERE d2.region = 'APAC' AND d1.region = 'EMEA';

-- 3- Number of products with more than 1000 pageviews in 2020
SELECT ID_PRODUCT, SUM(NB_PAGEVIEWS) AS pageviews
FROM sum_product_pageviews
WHERE YEAR(DATE_SESSION) = 2020
GROUP BY ID_PRODUCT
HAVING pageviews > 1000;

-- 4- Number of sellers whose last sale is a bag
SELECT COUNT(DISTINCT ID_SELLER)
FROM ( -- nested table: last sale of every sellers
	SELECT *
	FROM dim_category AS d
		JOIN fct_prodcut_sold AS f
			ON d.id_category = f.ID_CATEGORY
	GROUP BY ID_SELLER
	ORDER BY DATE_PAYMENT DESC
	LIMIT 1
)
WHERE category = 'BAGS';