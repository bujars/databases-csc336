
-- My original attempt at this was to add a year column 
-- via common table expression and then join through that, 
-- however I beleive I can just call the EXTRACT 
-- function on the inner join. 


-- I think both require the same time, ie they both perform 
-- that extract function on all rows, 
-- regardless if we are just storing them or comparing them. 
-- In comparing it needs to do it to check, same thing with storing.

-- I don't know if doing it via join has some underlying complications, 
-- but i would say that way is better because we aren't storing an 
-- additional unnessary year column which will die out right after 
-- (sure it may be a little easier to read)

/*
WITH high_performers AS (
	SELECT 
	*,
	EXTRACT(year FROM date)

)
SELECT * FROM high_performers;

*/


-- To compute net worth: assets-liabilities,
-- Then we only want it for the 60 companies/years that we chose
	-- hence we join on symbol and the year (notice how I compute fundamental's year in join)
				--- Update: Changed to the year column found in the fundamentals table
-- and we just add in other information

/*
SELECT 
	fundamentals.total_assets-fundamentals.total_liabilities as net_worth,
	annual_return_60.*,
	fundamentals.*
FROM 
	annual_return_60
INNER JOIN fundamentals
	-- ON annual_return_60.year = EXTRACT(year FROM fundamentals.year_ending) 
	-- A year column exists....
	--ON annual_return_60.year = fundamentals.year
	ON annual_return_60.last_date = fundamentals.year_ending
	AND annual_return_60.symbol =	fundamentals.symbol
ORDER BY annual_return_60.symbol;
;*/
/*

SELECT 
	fundamentals.total_assets-fundamentals.total_liabilities as net_worth,
	annual_return_60.*--,
	-- fundamentals.*
FROM 
	annual_return_60
INNER JOIN fundamentals
	ON annual_return_60.year = fundamentals.year
	AND annual_return_60.symbol = fundamentals.symbol
--ORDER BY annual_return_60.symbol;
ORDER BY net_worth DESC NULLS LAST;
*/


/* NOTE this is a bad attempt at the net_income growth year over year, 
as it compares the symbol values, and not actualy the fundamnetal table value. 
See below answer*/

/*
SELECT 
	fundamentals.net_income, 
	LAG(fundamentals.net_income) 
		OVER (PARTITION BY fundamentals.symbol ORDER BY fundamentals.year),
	(fundamentals.net_income 
		- LAG(fundamentals.net_income) 
			OVER (PARTITION BY fundamentals.symbol ORDER BY fundamentals.year))
	/ (LAG(fundamentals.net_income) 
			OVER (PARTITION BY fundamentals.symbol ORDER BY fundamentals.year)::FLOAT) 
	* 100 AS new_income_growth,
	annual_return_60.*,
	fundamentals.*
FROM 
	annual_return_60
INNER JOIN fundamentals
	-- ON annual_return_60.year = EXTRACT(year FROM fundamentals.year_ending) 
	-- A year column exists....

	-- I think we need to match closing date to year_ending because some on the same year actually end much earlier. 
	ON annual_return_60.last_date = fundamentals.year_ending
	AND annual_return_60.symbol =	fundamentals.symbol
ORDER BY annual_return_60.symbol, new_income_growth DESC NULLS LAST; 
;

*/


/* Thoughts: 
-- As we can see from the data, we are only getting two values, because theres only data matching for these two values.
	-- Is this common?
-- Are we supposed to just compare them generally to every year?  
	-- (Ie on the fundamentals table then join in? cause that has more data, 
	-- ie join on just symbol...but this might not give what we want in terms of joining, 
	-- cause it will match on all the symbols only...)
-- Also are we supposed to match the closing date to the year_ending, or can we just stick to a year? 
	--(Notice how my initial table was set up differently)
		-- Might have to go back and change original table. 
*/


/* Updated thoughts, post conversation with Dough
i think i figured out the methodology for hw 5. 
So in hw 4 on the annual return table we will have some stocks which onlty have two rows, 
day 2015 and 2012. And we cant compute the yr to yr because we dont have ie 2014 or 2011. 
However, we only care about that value change, we don't exactly need the close price of 2014. 
So we compute the lag/lead crap on a temporary table for all the years, 
and then join it to the annual returns tables so that we have only the specific values for which we want!
*/







-- SIDE NOTE, the data already has a clustered index on date. So in our temp, 
-- it will be sorted, and allow us to call lag normally, but let us take the precations. 




-- Assets-Liabilities = net worth ==> Move towards year over year. 
SELECT 
	annual_returns.*,
	fundamentals.total_assets-fundamentals.total_liabilities AS net_worth
FROM 
	annual_returns
INNER JOIN fundamentals
	ON annual_returns.year = fundamentals.year
	AND annual_returns.symbol = fundamentals.symbol
ORDER BY net_worth DESC NULLS LAST;


-- Net Income growth year over year
WITH temp AS (
	SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.net_income AS current_net_income,
		LAG(fundamentals.net_income) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_net_income
	FROM fundamentals
)
SELECT 
	annual_returns.*, 
	temp.*,
	(( temp.current_net_income - temp.previous_net_income ) 
		/ temp.previous_net_income::FLOAT ) 
		* 100 AS net_income_growth
FROM temp
INNER JOIN annual_returns 
	ON annual_returns.symbol = temp.symbol 
		AND annual_returns.year = temp.year 
		AND previous_net_income IS NOT NULL
ORDER BY net_income_growth DESC NULLS LAST; 


-- Revenue Growth year over year
WITH temp AS (
	SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.total_revenue AS current_total_revenue,
		LAG(fundamentals.total_revenue) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_total_revenue
	FROM fundamentals
)
SELECT 
	annual_returns.*, 
	temp.*,
	(( temp.current_total_revenue - temp.previous_total_revenue ) 
		/ temp.previous_total_revenue::FLOAT ) 
		* 100 AS total_revenue_growth
FROM temp
INNER JOIN annual_returns 
	ON annual_returns.symbol = temp.symbol 
		AND annual_returns.year = temp.year 
		AND previous_total_revenue IS NOT NULL
ORDER BY total_revenue_growth DESC NULLS LAST; 


-- Just testing out my original theory for why I used CTES
/*
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY fundamentals.symbol
			ORDER BY fundamentals.year
			) AS previous_earnings_per_share,
	annual_returns.*,
	((fundamentals.earnings_per_share - LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY fundamentals.symbol
			ORDER BY fundamentals.year
			)) / LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY fundamentals.symbol
			ORDER BY fundamentals.year
			))
		* 100 AS earnings_per_share_growth
FROM annual_returns
INNER JOIN fundamentals ON fundamentals.symbol = annual_returns.symbol and fundamentals.year = annual_returns.year
ORDER BY earnings_per_share_growth DESC NULLS LAST; 
*/


-- Earnings per share year over year
WITH temp AS (
	SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_earnings_per_share 
	FROM fundamentals
)
SELECT 
	annual_returns.*, 
	temp.*,
	(( temp.current_earnings_per_share - temp.previous_earnings_per_share ) 
		/ temp.previous_earnings_per_share::FLOAT ) 
		* 100 AS earnings_per_share_growth
FROM temp
INNER JOIN annual_returns 
	ON annual_returns.symbol = temp.symbol 
		AND annual_returns.year = temp.year 
		AND previous_earnings_per_share IS NOT NULL
ORDER BY earnings_per_share_growth DESC NULLS LAST; 


/*
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		annual_returns.close,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY fundamentals.symbol
			ORDER BY fundamentals.year
			) AS previous_earnings_per_share ,
		annual_returns.close / fundamentals.earnings_per_share AS price_to_earnings_ratio
FROM annual_returns
INNER JOIN fundamentals ON fundamentals.symbol = annual_returns.symbol and fundamentals.year = annual_returns.year
ORDER BY price_to_earnings_ratio ASC NULLS LAST; 
*/


-- Closing price / EPS 
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		annual_returns.close AS stock_price,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		annual_returns.close / fundamentals.earnings_per_share AS price_to_earnings_ratio
FROM annual_returns
INNER JOIN fundamentals 
	ON fundamentals.symbol = annual_returns.symbol AND fundamentals.year = annual_returns.year
ORDER BY price_to_earnings_ratio ASC NULLS LAST; 



-- liquid asset == cash in hand that can use  /liabilites. (Versuing as a ratio.)
-- The more cash, liquid asset we have the better vs. liabilites, which are loans. 
-- Hence we want a higher ratio
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.cash_and_cash_equivalents,
		fundamentals.total_liabilities,
		fundamentals.cash_and_cash_equivalents::FLOAT 
			/ fundamentals.total_liabilities::FLOAT AS liquid_cash_vs_liabilities
FROM annual_returns
INNER JOIN fundamentals 
	ON fundamentals.symbol = annual_returns.symbol AND fundamentals.year = annual_returns.year
ORDER BY liquid_cash_vs_liabilities DESC NULLS LAST; 

-- The next goal is to store all of these in temory tables, and then join them all. Maybe just do what i originally said I would. That way we can see how things are going!



--Note this table is comprehensive of the 6 above. I created this to show everything all at once and then compare those values. 
WITH temp AS (
	SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.total_assets-fundamentals.total_liabilities AS net_worth,
		fundamentals.net_income AS current_net_income,
		LAG(fundamentals.net_income) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_net_income,
		fundamentals.total_revenue AS current_total_revenue,
		LAG(fundamentals.total_revenue) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_total_revenue,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_earnings_per_share,
		fundamentals.cash_and_cash_equivalents,
		fundamentals.total_liabilities,
		fundamentals.cash_and_cash_equivalents::FLOAT 
			/ fundamentals.total_liabilities::FLOAT AS liquid_cash_vs_liabilities
	FROM fundamentals
)
SELECT 
	annual_returns.*, 
	temp.net_worth,
	(( temp.current_net_income - temp.previous_net_income ) 
		/ temp.previous_net_income::FLOAT ) 
		* 100 AS net_income_growth,
	(( temp.current_total_revenue - temp.previous_total_revenue ) 
	/ temp.previous_total_revenue::FLOAT ) 
	* 100 AS total_revenue_growth,
	(( temp.current_earnings_per_share - temp.previous_earnings_per_share ) 
		/ temp.previous_earnings_per_share::FLOAT ) 
		* 100 AS earnings_per_share_growth,
	annual_returns.close / temp.current_earnings_per_share AS price_to_earnings_ratio,
	temp.liquid_cash_vs_liabilities,
	securities.*
FROM temp
INNER JOIN annual_returns ON annual_returns.symbol = temp.symbol AND annual_returns.year = temp.year
INNER JOIN securities ON temp.symbol = securities.symbol
ORDER BY annual_returns.annual_return DESC NULLS LAST; 







-- Answer to Number 2.
	-- Remember, first take high net_income, then take eps that is higher than income 
WITH temp AS (
	SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.net_income AS current_net_income,
		LAG(fundamentals.net_income) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_net_income,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_earnings_per_share
	FROM fundamentals
)
SELECT 
	temp.symbol,
	temp.year,
	(( temp.current_net_income - temp.previous_net_income ) 
		/ temp.previous_net_income::FLOAT ) 
		* 100 AS net_income_growth,
	(( temp.current_earnings_per_share - temp.previous_earnings_per_share ) 
		/ temp.previous_earnings_per_share::FLOAT ) 
		* 100 AS earnings_per_share_growth
FROM temp
WHERE temp.year = 2016
ORDER BY net_income_growth DESC NULLS LAST
LIMIT 30; 



WITH temp AS (
	SELECT 
		--note, adding fundamentals id as it is easier to select these into a new table for question 3
		fundamentals.id,
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.net_income AS current_net_income,
		LAG(fundamentals.net_income) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_net_income,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_earnings_per_share
	FROM fundamentals
)
SELECT 
	temp.id,
	temp.symbol,
	temp.year,
	(( temp.current_net_income - temp.previous_net_income ) 
		/ temp.previous_net_income::FLOAT ) 
		* 100 AS net_income_growth,
	(( temp.current_earnings_per_share - temp.previous_earnings_per_share ) 
		/ temp.previous_earnings_per_share::FLOAT ) 
		* 100 AS earnings_per_share_growth,
	securities.*
FROM temp
INNER JOIN securities ON temp.symbol = securities.symbol
WHERE temp.year = 2016
ORDER BY net_income_growth DESC NULLS LAST
LIMIT 30; 


-- The 10 companies for which I want to invest in are, 
	--id: 1489 (IT), 779 (Health), 631 (Industrials), 1493 (Consumer Staples), 1409 (CD), 
	-- 467(CD), 695(CS), 403(Industrials), 1042(Health), 31(IT)

/*
 I chose these specific comapnies because they all live in 5 different sectors (2 per each sector). 
 I chose both a high net_income_growth and eps_growth, where eps is greater/close to the net_income_growth. 
 Diversification in sector will allow me to see if my methodology of selecting high nig and epsg, where epsg is greater/close to than nig.
 */


WITH temp AS (
	SELECT 
		--note, adding fundamentals id as it is easier to select these into a new table for question 3
		fundamentals.id,
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.net_income AS current_net_income,
		LAG(fundamentals.net_income) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_net_income,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		LAG(fundamentals.earnings_per_share) OVER (
			PARTITION BY symbol
			ORDER BY year
			) AS previous_earnings_per_share
	FROM fundamentals
)
SELECT 
	temp.id,
	temp.symbol,
	temp.year,
	(( temp.current_net_income - temp.previous_net_income ) 
		/ temp.previous_net_income::FLOAT ) 
		* 100 AS net_income_growth,
	(( temp.current_earnings_per_share - temp.previous_earnings_per_share ) 
		/ temp.previous_earnings_per_share::FLOAT ) 
		* 100 AS earnings_per_share_growth,
	securities.*
FROM temp
INNER JOIN securities ON temp.symbol = securities.symbol
WHERE id = 1489 
	OR id = 779 
	OR id = 631 
	OR id = 1493 
	OR id = 1409 
	OR id = 467 
	OR id = 695 
	OR id = 403 
	OR id = 1042 
	OR id = 31
ORDER BY net_income_growth DESC NULLS LAST;



-- Gets all of the information for the symbols I've chosen. 
WITH temp AS (
	SELECT 
		prices.*, 
		EXTRACT(year FROM date) AS year,
		ROW_NUMBER() OVER (
			PARTITION BY symbol, EXTRACT(year FROM date)
			ORDER BY DATE DESC
		) AS row_number
	FROM prices
	WHERE (symbol = 'SYMC'
	OR symbol = 'HOLX'
	OR symbol = 'FDX'
	OR symbol = 'CTAS'
	OR symbol = 'MCK'
	OR symbol = 'GIS'
	OR symbol = 'SYY'
	OR symbol = 'SIG'
	OR symbol = 'ADI'
	OR symbol = 'DIS') AND EXTRACT(year FROM date) = 2016. 
)
SELECT 
	temp.*
-- INTO annual_returns
FROM temp
WHERE row_number = 1; 

/*
Closing prices of: 
ADI:  89.03 12/29/2017
CTAS: 155.83 12/29/2017
DIS: 107.51
FDX: 249.54
GIS: 59.29
HOLX: 42.75
MCK: 155.95
SIG: 56.55
SYMC: 28.06
SYY: 60.73

*/






-- For hw 6, never tested. 
/*

CREATE VIEW bujar_sefa_investments AS 
WITH temp AS (
	SELECT 
		prices.*, 
		EXTRACT(year FROM date) AS year,
		ROW_NUMBER() OVER (
			PARTITION BY symbol, EXTRACT(year FROM date)
			ORDER BY DATE DESC
		) AS row_number
	FROM prices
	WHERE (symbol = 'SYMC'
	OR symbol = 'HOLX'
	OR symbol = 'FDX'
	OR symbol = 'CTAS'
	OR symbol = 'MCK'
	OR symbol = 'GIS'
	OR symbol = 'SYY'
	OR symbol = 'SIG'
	OR symbol = 'ADI'
	OR symbol = 'DIS') AND EXTRACT(year FROM date) >= 2016
	-- Note may not need date but just filtering some data
)
SELECT 
	temp.*,
	securities.company,
	securities.sector,
	securities.sub_industry,
	securities.initial_trade_date,
	fundamentals.year_ending,
	fundamentals.cash_and_cash_equivalents, 
	fundamentals.earnings_before_interest_and_taxes,
	fundamentals.gross_margin,
	fundamentals.net_income,
	fundamentals.total_assets,
	fundamentals.total_liabilities,
	fundamentals.total_revenue,
	fundamentals.year,
	fundamentals.earnings_per_share,
	fundamentals.shares_outstanding
FROM temp
LEFT JOIN fundamentals ON temp.symbol = fundamentals.symbol AND temp.year = fundamentals.year
LEFT JOIN securities ON temp.symbol = securities.symbol
ORDER BY temp.date DESC; 

*/