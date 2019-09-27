-- to work, need to add more variables to join on

/*WITH A AS (
SELECT 
	symbol, date,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) ORDER BY date) AS rn 
FROM prices 
), 
B AS ( 
SELECT 
	symbol, date,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT count(*) from A
INNER JOIN B ON A.symbol = B.symbol AND A.date = B.date
WHERE A.rn = 1;*/


-- Note  this does a full outer join and will probably take forever to execute!
/*
WITH first AS (
SELECT 
	symbol,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) ORDER BY date) AS rn 
FROM prices 
), last AS (
SELECT 
	symbol,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT prices.symbol as S, first.symbol as M, last.symbol as L from prices 
INNER JOIN first ON prices.symbol = first.symbol 
INNER JOIN last ON prices.symbol = first.symbol
WHERE first.rn = 1; */
/*
SELECT 
	*,
	date_part('year', date) as year,
	first_value(close) OVER 
	(PARTITION BY symbol, date_part('year', date) 
		ORDER BY date) AS rn 
FROM prices;
*/


--Why do  I need a triple Join... just makes computations insane....
/*
WITH first AS (
SELECT 
	*,
	date_part('year', date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) 
		ORDER BY date) AS rn 
FROM prices 
), last AS (
SELECT 
	*,
	date_part('year', date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) 
		ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT ((last.close/first.close) - 1) as annual_return, first.close, last.close, last.date, prices.date) as year, first.symbol as M, last.symbol as L from prices 
INNER JOIN first ON prices.symbol = first.symbol and first.year = date_part('year', prices.date)
INNER JOIN last ON first.symbol = last.symbol and first.rn = last.rn;*/


/*

--- Okay I am getting closer.... LOL --
-- What I need to do is filter by row number being only 1? i don't care for the other values. 
-- Second, male sure we are getting the right years/calculations.

----- This gets us what we need. 
WITH first AS (
	---What this does: First just take all the information, who knows we may need it
	-- Then we want to take out the year from each row (because here we care about the year, not theday)
	-- Then we want to divide everything/group them ==> Get all the symbols together then get them together by year
	-- Then we want to sort everything by their date.

SELECT 
	*,
	date_part('year', date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) 
		ORDER BY date) AS rn 
FROM prices 
), last AS (
SELECT 
	---What this does: First just take all the information, who knows we may need it
	-- Then we want to take out the year from each row (because here we care about the year, 
	-- not the day)
	-- Then we want to divide everything/group them ==> 
	-- Get all the symbols together then get them together by year
	-- Then we want to sort everything by their date BACKWARDS meaning december to january.

	*,
	date_part('year', date) as year,
	ROW_NUMBER() OVER 
	(PARTITION BY symbol, date_part('year', date) 
		ORDER BY date DESC) AS rn 
FROM prices 
)
SELECT 

-- Finally, we want to select the coorespoding row number 
-- (which should be 1!!!! bc we are doing the last/first date of each symbol by each year)
-- Then we want each year
-- Then we want to perform our calculation
-- Then we want to just see what where the opening price of the very first date 
-- and the closing price of the very last date
-- then we want the dates just to see
-- then we want the symbols to make sure we are getting the correct data.

-- note we join on the same symbol, year, 
-- and row number and only care about the first row number, nothing else.
	first.rn as RN, 
	first.year as YEAR,
	((last.close/first.open) - 1) as annual_return, 
	first.open as FC, 
	last.close as LC,
	first.date as FD,
	last.date as LD, 
	first.symbol as FS, 
	last.symbol as LS
FROM first
INNER JOIN last ON 
	first.symbol = last.symbol AND first.rn = last.rn AND first.rn = 1 AND first.year = last.year;

*/




WITH first AS (
SELECT 
	*,
	--date_part('year', date) as year,
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
	first.symbol = last.symbol AND first.rn = last.rn AND first.rn = 1 AND first.year = last.year
ORDER BY annual_return DESC
LIMIT 2; 

-- Then, we just want tto sort by annual return so we know which symbols we want to invest in





--- Okay, now we create a table which holds all this information:

DROP TABLE IF EXISTS annual_return_60; 


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
	first.symbol as symbol --NOTICE HERE I TOOK OUT THE last.symbol because it wasn't doing much for me. 
INTO annual_return_60
FROM first
INNER JOIN last ON 
	first.symbol = last.symbol AND first.rn = last.rn AND first.rn = 1 AND first.year = last.year
ORDER BY annual_return DESC
LIMIT 60; 
