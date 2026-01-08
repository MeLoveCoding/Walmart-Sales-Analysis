SELECT * FROM walmart_sales
LIMIT 10;
-- How many weekly records are in the datasets?
 SELECT COUNT(Date) FROM walmart_sales;
-- How many unique stores are included?
SELECT COUNT(DISTINCT(Store)) AS number_of_stores FROM walmart_sales;
-- What is the earliest and latest date in the dataset?
SELECT MAX(Date) as start_date, MIN(Date) as end_date FROM walmart_sales;
-- Are there any missing value in critical columns?
SELECT * FROM walmart_sales
WHERE Date IS NULL 
OR Weekly_Sales IS NULL;
-- What is the total sales amount for each store?
SELECT Store, ROUND(SUM(Weekly_Sales),2) AS total_sales FROM walmart_sales
GROUP BY Store
ORDER BY 2 DESC;
-- Average weekly sales per store ?
SELECT Store, ROUND(AVG(Weekly_Sales),2) AS average_sales FROM walmart_sales
GROUP BY Store
ORDER BY 2 DESC;
-- top 10 stores by total_sales
SELECT Store, ROUND(SUM(Weekly_Sales),2) AS total_sales FROM walmart_sales
GROUP BY Store
ORDER BY 2 DESC
LIMIT 10;
-- bottom 10 stores by average sales
SELECT Store, ROUND(AVG(Weekly_Sales),2) AS average_sales FROM walmart_sales
GROUP BY Store
ORDER BY 2 ASC
LIMIT 10;
-- How do average sales varies between holidays and non-holidays?
SELECT ROUND(AVG(Weekly_Sales)) AS non_holiday_sales 
FROM walmart_sales
WHERE Holiday_Flag = 0; 
SELECT ROUND(AVG(Weekly_Sales)) AS holiday_sales
FROM walmart_sales
WHERE Holiday_Flag = 1;
-- On average, holiday sales are higher than non-holiday sales of about 81632$

-- Which store is affected the most by the holidays?
SELECT Store, ROUND(AVG(Weekly_Sales)) AS non_holiday_sales 
FROM walmart_sales
WHERE Holiday_Flag = 0
GROUP BY Store
ORDER BY 2 DESC;
SELECT Store, ROUND(AVG(Weekly_Sales)) AS holiday_sales
FROM walmart_sales
WHERE Holiday_Flag = 1
GROUP BY Store
ORDER BY 2 DESC;
SELECT
    Store,
    ROUND(AVG(CASE WHEN Holiday_flag = 1 THEN Weekly_sales END)) AS avg_holiday_sales,
    ROUND(AVG(CASE WHEN Holiday_flag = 0 THEN Weekly_Sales END)) AS avg_non_holiday_sales
FROM walmart_sales
GROUP BY Store;
SELECT
    Store,
    ROUND(
        (AVG(CASE WHEN holiday_flag = 1 THEN weekly_sales END)
        - AVG(CASE WHEN holiday_flag = 0 THEN weekly_sales END))
        / AVG(CASE WHEN holiday_flag = 0 THEN weekly_sales END)
        * 100, 2
    ) AS holiday_uplift_pct
FROM walmart_sales
GROUP BY Store
ORDER BY holiday_uplift_pct DESC;
-- The Sales of Store 21 has the most uplift during the holidays, with a 19.77% increase in Sales. 
-- Recommed increasing staffing and inventory levels during the holidays

-- Calculating correlation between Sales and temprature
SELECT 
(
AVG(Weekly_Sales * Temperature) - AVG(Weekly_Sales) * AVG(Temperature)
)
/ 
(
STDDEV_POP(Weekly_Sales) * STDDEV_POP(Temperature)
) AS correlation
FROM walmart_sales;
-- The correlation is -0.06, suggesting that the sales quantity is not considerably affected by temperature

-- Calculating correlation between Sales and Fuel
SELECT 
(
AVG(Weekly_Sales * Fuel_Price) - AVG(Weekly_Sales) * AVG(Fuel_Price)
)
/ 
(
STDDEV_POP(Weekly_Sales) * STDDEV_POP(Fuel_Price)
) AS correlation
FROM walmart_sales;
-- The correlation is 0.009, suggesting that the sales quantity is not considerably affected by fuel prices

-- Calculating correlation between Sales and Consumer Price Index
SELECT 
(
AVG(Weekly_Sales * CPI) - AVG(Weekly_Sales) * AVG(CPI)
)
/ 
(
STDDEV_POP(Weekly_Sales) * STDDEV_POP(CPI)
) AS correlation
FROM walmart_sales;
-- The correlation is -0.07, suggesting that the sales quantity is not considerably affected by CPI Index

-- Calculating correlation between Sales and Unemployment
SELECT 
(
AVG(Weekly_Sales * Unemployment) - AVG(Weekly_Sales) * AVG(Unemployment)
)
/ 
(
STDDEV_POP(Weekly_Sales) * STDDEV_POP(Unemployment)
) AS correlation
FROM walmart_sales;
-- The correlation is -0.1, suggesting that the sales quantity is not considerably affected by Unemployment rate

-- Categorizing Stores based on sales performances
WITH store_avg_sales AS (
	SELECT 
		Store,
        AVG(Weekly_Sales) AS avg_weekly_sales
	FROM 
    walmart_sales
    GROUP BY Store
    ),
    store_rank AS (
		SELECT Store, avg_weekly_sales,
        NTILE(3) over (ORDER BY avg_weekly_sales DESC) AS sale_tier
	FROM store_avg_sales
    )
SELECT 
	Store,
    avg_weekly_sales,
    CASE
		WHEN sale_tier = 1 THEN "High"
        WHEN sale_tier = 2 THEN "Medium"
        WHEN sale_tier = 3 THEN "Low"
	END AS sales_category
FROM store_rank
ORDER BY avg_weekly_sales DESC;
-- The board divided 45 stores into 3 groups based on their overall sale performance
