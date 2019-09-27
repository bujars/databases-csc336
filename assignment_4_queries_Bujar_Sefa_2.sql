

-- Answer to Question 2: 
 WITH temp AS (
	SELECT 
		prices.*, 
		EXTRACT(year FROM date) AS year,
		ROW_NUMBER() OVER (
			PARTITION BY symbol, EXTRACT(year FROM date)
			ORDER BY DATE DESC
		) AS row_number
	FROM prices
)
SELECT 
	temp.symbol, 
	temp.date, 
	temp.close,
	temp.close / LAG(temp.close) OVER (PARTITION BY symbol) - 1 AS annual_return
FROM temp
WHERE row_number = 1
ORDER BY annual_return DESC NULLS LAST; 




-- Answer to Question 3: 
DROP TABLE IF EXISTS annual_returns;

WITH temp AS (
	SELECT 
		prices.*, 
		EXTRACT(year FROM date) AS year,
		ROW_NUMBER() OVER (
			PARTITION BY symbol, EXTRACT(year FROM date)
			ORDER BY DATE DESC
		) AS row_number
	FROM prices
)
SELECT 
	temp.symbol, 
	temp.date,
	temp.year,
	temp.close,
	temp.close / LAG(temp.close) OVER (PARTITION BY symbol) - 1 AS annual_return
INTO annual_returns
FROM temp
WHERE row_number = 1
ORDER BY annual_return DESC NULLS LAST
LIMIT 60;  

SELECT * FROM annual_returns;

