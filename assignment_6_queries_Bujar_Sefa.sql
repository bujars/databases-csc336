DROP VIEW IF EXISTS bujar_sefa_investments;

-- Question 1: 
--pg_dump -U BujarSefa -d assignment4 > backup_Bujar_Sefa.sql


-- Question: 2 
/*
-- Because the prices table always updated, 
-- we want all of the values from the year we started investing
-- And to keep on going (Hence year > 2016). 
-- We sort backwards by date because we want to see current going down. 
*/ 

CREATE VIEW bujar_sefa_investments AS 
SELECT 
	prices.*,
	EXTRACT(year FROM prices.date) AS year, 
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
	fundamentals.earnings_per_share,
	fundamentals.shares_outstanding
FROM prices
LEFT JOIN fundamentals 
	ON prices.symbol = fundamentals.symbol 
		AND EXTRACT(year FROM prices.date) = fundamentals.year
LEFT JOIN 
	securities ON prices.symbol = securities.symbol
WHERE (prices.symbol = 'SYMC'
	OR prices.symbol = 'HOLX'
	OR prices.symbol = 'FDX'
	OR prices.symbol = 'CTAS'
	OR prices.symbol = 'MCK'
	OR prices.symbol = 'GIS'
	OR prices.symbol = 'SYY'
	OR prices.symbol = 'SIG'
	OR prices.symbol = 'ADI'
	OR prices.symbol = 'DIS') AND prices.date >= '2016-12-01'
ORDER BY prices.date DESC, prices.symbol; 

select * from bujar_sefa_investments;


-- Question 3: 
--psql -U BujarSefa -d assignment4 -tAF, -f assignment_6_queries_Bujar_Sefa.sql > output_file_Bujar_Sefa.csv

-- ********[NOTE in Quesition 2, I can change the where clause to 
-- where EXTRACT(year FROM prices.date) >= 2016 for start of year.
-- However, I made the decision to simplify showings in Queston 3]
-- **** Also note! My database name is assignment4. NOT postgres. 




-- Answer to Question 4: 
/*
-- Get the price of 2016 for the companies I chose
-- in the table I created in Question 3 of HW5.   
select * from bujars_investment; */

/**
  * Closing prices of my companies in 2017: 
  * ADI:  89.03 | 12/29/2017
  * CTAS: 155.83 | 12/29/2017
  * DIS: 107.51 | 12/29/2017
  * FDX: 249.54 | 12/29/2017
  * GIS: 59.29 | 12/29/2017
  * HOLX: 42.75 | 12/29/2017
  * MCK: 155.95 | 12/29/2017
  * SIG: 56.55 | 12/29/2017
  * SYMC: 28.06 | 12/29/2017
  * SYY: 60.73 | 12/29/2017


* [Numbers received from Yahoo.]
*/

/** Calculating Annual Return
  * Formula (closing price current year / closing price previous year) -1 
  * ADI: (89.03/72.620003) = 1.2259707563 - 1 = 0.2259707563 ~= 22.60%
  * CTAS: (155.83/115.559998) = 1.348477005 - 1 = 0.348477005 ~= 34.85%
  * DIS: (107.51 / 104.220001) = 1.0315678274 - 1 = 0.0315678274 ~= 3.16%
  * FDX: (249.54/186.199997) = 1.3401718798 - 1 = 0.3401718798 ~= 34.02%
  * GIS: (59.29/61.77) = 0.9598510604 - 1 = -0.04014893961 ~= -4.01%
  * HOLX: (42.75/40.119999) = 1.0655533665 - 1 = 0.0655533665 ~= 6.56%
  * MCK: (155.95/140.449997) = 1.1103595823 - 1 = 0.1103595823 ~= 11.04%
  * SIG: (56.55/94.260002) = 0.5999363335 - 1 = -0.4000636665 ~= -40.01%
  * SYMC: (28.06/23.889999) = 1.1745500701 - 1 = 0.1745500701 ~= 17.46%
  * SYY: (60.73/55.369999) = 1.0968033429 - 1 = 0.0968033429 ~= 9.68%
 */

 /** Total Annual Return = 
   * Sum of individual annual returns:
   * 22.60% + 34.85% + 3.16% + 34.02% + -4.01% + 6.56% + 11.04% + -40.01% + 17.46% + 9.68% 
   *  ====> 95.35%
 */