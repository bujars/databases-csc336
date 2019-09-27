/* We want to spend some advertising money - where should we spend it?
            I.e., What is the best referral source of our buyers? */


/* Want the best referral, so on buyers table look at referral. 
 * We want to group by referrals, and we want to count each one 
 * --> The max of that is the best or the first row. LIMIT 1  */
/* NOTE ADDED INNER JOIN transactions ON buyers.cust_id = transactions.cust_id 
 * because we care about referrer where something was bought. */

/* -- Complete List (If needed)
\echo 'Best Referrals:'

SELECT 
	buyers.cust_id, referrer, count(referrer) 
FROM 
	buyers
INNER JOIN transactions ON buyers.cust_id = transactions.cust_id
GROUP BY 
	referrer, buyers.cust_id
ORDER BY
	count(distinct referrer) DESC; 
*/

\echo 'Best Referral:'
SELECT 
	referrer, count(referrer) 
FROM 
	buyers
INNER JOIN transactions ON buyers.cust_id = transactions.cust_id
GROUP BY 
	referrer
ORDER BY 
	count(referrer) DESC 
LIMIT 1; 



/*Which of our customers has not bought a boat yet?*/
/* Get all of the buyers information and link it to transactions. 
We do a left join because wants all buyer info (regardless of purchase). 
Then we join on the cust_id (the primary/foreign key) 
Then we want the cust_id in transactons to be NULL because if it exists, 
it means they made a purchase. */
\echo 'No purchase:'

SELECT 
	buyers.*
FROM 
	buyers
LEFT JOIN 
	transactions ON buyers.cust_id = transactions.cust_id
WHERE 
	transactions.cust_id IS NULL; 

/*Which boats do we have in inventory - i.e., have not sold?*/

/* We need to join transactions on boats. And we need to link the product id, 
ie  primary with foreign. 
Then we want to do a Left Join on boats (we care about that information.
And we don't want ones that sold, so where prod_id in transactions is null, 
meaning that give us only the columns which arent inner.)*/


\echo 'Boats in inventory:'
SELECT 
	boats.*
FROM 
	boats
LEFT JOIN 
	transactions ON boats.prod_id = transactions.prod_id
WHERE
	transactions.prod_id IS NULL; 

/* What boat did Alan Weston buy?*/
/* This requires a 3 way join --> 
 * Buyer to transaction and with that transaction 
 * link the product info or the boat
 * And filter by Alan Weston */

\echo 'Alan Weston Boat:'
SELECT 
	brand, category, fname, lname
FROM 
	buyers
INNER JOIN 
	transactions ON transactions.cust_id = buyers.cust_id
INNER JOIN 
	boats ON transactions.prod_id = boats.prod_id
WHERE buyers.lname = 'Weston' AND buyers.fname = 'Alan';


/* Who are our VIP customers?*/
/* First determine all the buyers ids (cust_id) that have multiple transactions.
 * So first we group all the customers, then we pick all the ones whos count/number 
 * of entites is > 1 
 * (HAVING CLAUSE = filter by aggregate function) */
\echo 'VIPS:'
SELECT 
	buyers.*
FROM 
	buyers
WHERE 
	cust_id IN (SELECT
					 cust_id 
				FROM 
					transactions 
				GROUP BY 
					cust_id 
				HAVING COUNT(cust_id) > 1); 



/*Another 'cleaner' way is first getting all the customers and their count of transaction -CTE*/
/*
\echo 'VIPs V2:'
WITH VIP_custs AS 
(SELECT 
	cust_id, COUNT(cust_id) 
FROM 
	transactions 
GROUP BY 
	cust_id 
HAVING 
count(cust_id) > 1 )
SELECT buyers.* 
FROM buyers
INNER JOIN VIP_custs ON buyers.cust_id = VIP_custs.cust_id;
*/
