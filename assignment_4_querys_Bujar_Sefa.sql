WITH first AS (
SELECT 
	*,
	EXTRACT(year from date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, EXTRACT(year from date)
		ORDER BY date) AS rn 
FROM prices 
), last AS (
SELECT 
	*,
	EXTRACT(year from date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, EXTRACT(year from date)
		ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT 
	first.rn as row_number, 
	first.year as year,
	((last.close/first.open) - 1) as annual_return, 
	first.open as first_open, 
	last.close as last_close,
	first.date as first_date,
	last.date as last_date, 
	first.symbol as first_symbol, 
	last.symbol as last_symbol -- NOTE, I do not need both, but can combine them
FROM first
INNER JOIN last ON 
	first.symbol = last.symbol 
	AND first.rn = last.rn 
	AND first.rn = 1 
	AND first.year = last.year
ORDER BY annual_return DESC; 

DROP TABLE IF EXISTS annual_returns; 


WITH first AS (
SELECT 
	*,
	EXTRACT(year from date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, EXTRACT(year from date)
		ORDER BY date) AS rn 
FROM prices 
), last AS (
SELECT 
	*,
	EXTRACT(year from date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, EXTRACT(year from date)
		ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT
	first.rn as row_number, 
	first.year as year,
	((last.close/first.open) - 1) as annual_return, 
	first.open as first_open, 
	last.close as last_close,
	first.date as first_date,
	last.date as last_date, 
	first.symbol as symbol
INTO annual_returns
FROM first
INNER JOIN last ON 
	first.symbol = last.symbol AND first.rn = last.rn AND first.rn = 1 AND first.year = last.year
ORDER BY annual_return DESC
LIMIT 60; 