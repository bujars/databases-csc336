///Note this is just scrap for assingment 5. Most of these queries are just ideas, not necessarily correct. 



select annual_return_60.*, fundamentals.net_income, fundamentals.net_income / LAG(fundamentals.net_income) OVER (Partition by symbol order by year)::float as net_growth from annual_return_60 inner join fundamentals on a.symbol = f. symbol and a.year = f.year
order by net_growth desc; 


/* note annual returns now has a simplified list of symbol and year,
do this time when we partition, we just care about breaking everything by symbol, as we will only have one symbol per year and essentially we look at it from year 1 to year 2. 

In HW4, our partition by was different where we split everything by symbol then by year because we had basicaly multiple valyes in the same year, here we do not have that. each year has 1 value */





//note compared to the first one, here instead i will save the lag in a column, then perform the computation. 

// the formula = current net - previous net / previous net * 100



select annual_return_60.*, fundamentals.net_income, LAG(fundamentals.net_income) OVER (Partition by symbol order by year) as previous net, ((net_growth - previous net)/(previous net::float)) * 100 from annual_return_60 inner join fundamentals on a.symbol = f. symbol and a.year = f.year
order by net_growth desc; 


//Update, cannot do the above

select annual_return_60.*, fundamentals.net_income, LAG(fundamentals.net_income) OVER (Partition by symbol order by year) as previous net, ((net_growth - LAG(fundamentals.net_income) OVER (Partition by symbol order by year))/(LAG(fundamentals.net_income) OVER (Partition by symbol order by year)::float)) * 100 from annual_return_60 inner join fundamentals on a.symbol = f. symbol and a.year = f.year
order by net_growth desc; 











/// table this right now
you then use this similar query, except this time changing the fields

select annual_return_60.*, fundamentals.net_income, fundamentals.net_income / LAG(fundamentals.net_income) OVER (Partition by symbol order by year)::float as net_growth from annual_return_60 inner join fundamentals on a.symbol = f. symbol and a.year = f.year
order by net_growth desc; 

