DROP TABLE IF EXISTS securities;
DROP TABLE IF EXISTS fundamentals;
DROP TABLE IF EXISTS prices;

SET client_encoding = 'LATIN1';

CREATE TABLE securities(
	symbol varchar(5),
	company text NOT NULL,
	sector text NOT NULL,
	sub_industry text NOT NULL,
	initial_trade_date text
);


CREATE TABLE fundamentals(
	id SERIAL PRIMARY KEY,
	symbol varchar(5), --REFERENCES securities(symbol),
	year_ending DATE NOT NULL,
	cash_and_cash_equivalents BIGINT NOT NULL,
	earnings_before_interest_and_taxes BIGINT NOT NULL,
	gross_margin integer NOT NULL,
	net_income BIGINT NOT NULL, 
	total_assets BIGINT NOT NULL,
	total_liabilities BIGINT NOT NULL,
	total_revenue BIGINT NOT NULL,
	year integer NOT NULL,
	earnings_per_share float,
	shares_outstanding float
);

CREATE TABLE prices(
	date DATE NOT NULL,
	symbol varchar(5), --references securities(symbol),
	open float NOT NULL,
	close float NOT NULL,
	low float NOT NULL,
	high float NOT NULL,
	volume float NOT NULL
);

\COPY securities FROM './securities.csv' WITH (FORMAT csv);
\COPY fundamentals FROM './fundamentals.csv' WITH (FORMAT csv);
\COPY prices FROM './prices.csv' WITH (FORMAT csv);