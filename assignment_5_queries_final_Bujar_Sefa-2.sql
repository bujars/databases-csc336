-- Question 1. A. Assets-Liabilities = Net Worth
SELECT 
	annual_returns.*,
	fundamentals.total_assets-fundamentals.total_liabilities AS net_worth
FROM 
	annual_returns
INNER JOIN fundamentals
	ON annual_returns.year = fundamentals.year
	AND annual_returns.symbol = fundamentals.symbol
ORDER BY net_worth DESC NULLS LAST;

-- Question 1. B. Net Income growth year over year
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


-- Question 1. C. Revenue Growth year over year
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


-- Question 1. D. Earnings per share year over year
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


-- Question 1. E. Closing price / EPS 
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		annual_returns.close AS stock_price,
		fundamentals.earnings_per_share AS current_earnings_per_share,
		annual_returns.close / fundamentals.earnings_per_share AS price_to_earnings_ratio
FROM annual_returns
INNER JOIN fundamentals 
	ON fundamentals.symbol = annual_returns.symbol 
		AND fundamentals.year = annual_returns.year
ORDER BY price_to_earnings_ratio ASC NULLS LAST; 

-- Question 1. F. liquid assets/liabilities
SELECT 
		fundamentals.symbol,
		fundamentals.year, 
		fundamentals.cash_and_cash_equivalents,
		fundamentals.total_liabilities,
		fundamentals.cash_and_cash_equivalents::FLOAT 
			/ fundamentals.total_liabilities::FLOAT AS liquid_cash_vs_liabilities
FROM annual_returns
INNER JOIN fundamentals 
	ON fundamentals.symbol = annual_returns.symbol 
		AND fundamentals.year = annual_returns.year
ORDER BY liquid_cash_vs_liabilities DESC NULLS LAST; 


-- Combined table of the 6 queries above
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
INNER JOIN annual_returns 
	ON annual_returns.symbol = temp.symbol 
		AND annual_returns.year = temp.year
INNER JOIN securities 
	ON temp.symbol = securities.symbol
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

 -- Answer to Number 2, adding securities information --> to look at sectors for Q3

WITH temp AS (
	SELECT 
		--note, adding fundamentals id. easier to select into a new table for question 3
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



--- Question 3: 
/*
The 10 companies (symbols) for which I want to invest in are, 
SYMC ( id: 1489),  HOLX (id: 779), FDX (id: 631), CTAS (id: 403), 
MCK (id: 1042), GIS (id: 695), SYY (id: 1493), SIG (id: 1409), 
ADI (id: 31) and finally, DIS (id: 467)

I chose these specific companies because they all come from 5 distinct sectors. 
There are two companies per each sector.

The data-driven aspects I used to select my companies are 
1. A top high net_income_growth
2. Earnings_per_share_growth (eps_growth), 
	which is higher than or approximate to the net_income_growth. 

Diversification in the sector allows me to see if my methodology of 
selecting high net_income_growth 
and eps_growth values greater than or close to net_income_growth apply to different areas.
I chose an eps_growth higher than net_income_growth, 
because, in eps_growth, we removed all dividends; 
This allows the net income to be additional cash 
which the company can make for further investments (assuming with a non-business background).



*/

--- Table of 10 symbls I chose from fundamentals

WITH temp AS (
	SELECT 
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






DROP TABLE IF EXISTS bujars_investment;

-- Gets all of the price information for the symbols I've chosen. Need closing price
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
	OR symbol = 'DIS') AND EXTRACT(year FROM date) = 2016
	-- Note may not need date but just filtering some data
)
SELECT 
	temp.*
INTO bujars_investment
FROM temp
WHERE row_number = 1; 


-- To see the prices of the above query for homework 6. 
select * from bujars_investment;


