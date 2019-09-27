SELECT
	SUM(survived) / 
		COUNT(*) * 100 AS prct_survived1
FROM passengers; 

SELECT
	SUM(survived) / 
		CAST(COUNT(*) AS FLOAT) * 100 AS prct_survived2
FROM passengers; 

SELECT
	SUM(CASE WHEN survived=1 THEN 1.0 ELSE 0.0 END) / 
		COUNT(*) * 100 AS prct_survived3
FROM passengers; 

SELECT
	SUM(CASE WHEN survived=1 THEN 1.0 ELSE 0.0 END) / 
		CAST(COUNT(*) AS FLOAT) * 100 AS prct_survived4
FROM passengers; 

SELECT
	CAST(SUM(survived) AS FLOAT) / 
		CAST(COUNT(*) AS FLOAT) * 100 AS prct_survived5
FROM passengers; 


---------------------------------------------------------


SELECT
	CAST(SUM(survived) AS FLOAT) / 
		CAST(COUNT(*) AS FLOAT) * 100 AS prct_fem_survived1
FROM passengers
WHERE sex='female'; 


SELECT
	SUM(CASE WHEN survived=1 THEN 1.0 ELSE 0.0 END) / 
		CAST(COUNT(*) AS FLOAT) * 100 AS prct_fem_survived2
FROM passengers
WHERE sex='female'; 

SELECT SUM(CASE WHEN survived=1 AND sex='female' THEN 1.0 ELSE 0.0 END) /
	SUM(CASE WHEN sex='female' THEN 1.0 ELSE 0.0 END) * 100 AS prct_fem_survived3
FROM passengers;


SELECT SUM(CASE WHEN survived=1 AND sex='female' THEN 1.0 ELSE 0.0 END) /
	COUNT(CASE WHEN sex='female' THEN 1.0 ELSE NULL END) * 100 AS prct_fem_survived4
FROM passengers;


---------------------------------------------------------


SELECT
	COUNT(*) AS tot_1st_class
FROM passengers
WHERE class='1st'; 

SELECT
	COUNT(*) AS tot_2nd_class
FROM passengers
WHERE class='2nd'; 

SELECT
	COUNT(*) AS tot_3rd_class
FROM passengers
WHERE class='3rd'; 

SELECT
	COUNT(*) AS tot_unknown_class
FROM passengers
WHERE class IS NULL;



SELECT
	SUM(CASE WHEN class='1st' THEN 1 ELSE 0 END) AS tot_1st_class,
	SUM(CASE WHEN class='2nd' THEN 1 ELSE 0 END) AS tot_2nd_class,
	SUM(CASE WHEN class='3rd' THEN 1 ELSE 0 END) AS tot_3rd_class,
	SUM(CASE WHEN class IS NULL THEN 1 ELSE 0 END) AS tot_unknown_class
FROM passengers; 




SELECT
	COUNT(CASE WHEN class='1st' THEN 1 ELSE NULL END) AS tot_1st_class,
	COUNT(CASE WHEN class='2nd' THEN 1 ELSE NULL END) AS tot_2nd_class,
	COUNT(CASE WHEN class='3rd' THEN 1 ELSE NULL END) AS tot_3rd_class,
	COUNT(CASE WHEN class IS NULL THEN 1 ELSE NULL END) AS tot_unknown_class
FROM passengers;


SELECT class, COUNT(*)
FROM passengers
GROUP BY class
ORDER BY class; 



---------------------------------------------------------


SELECT 
	COUNT(*)
FROM passengers
WHERE class='1st' OR class='2nd';

SELECT 
	COUNT(CASE WHEN  class='1st' OR class='2nd' THEN 1 ELSE NULL END)
FROM passengers;


SELECT 
	COUNT(*)
FROM passengers
WHERE class IN ('1st','2nd');



---------------------------------------------------------



SELECT 
	class, 
	CAST(SUM(survived) AS FLOAT)/CAST(COUNT(*) AS FLOAT) *100 AS percent_survived
FROM passengers
GROUP BY class;



SELECT 
	CAST(SUM(CASE WHEN survived=1 AND class='1st' THEN 1.0 ELSE 0.0 END) AS FLOAT)/
		CAST(SUM(CASE WHEN class='1st' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 as prct_1st_survived,
	CAST(SUM(CASE WHEN survived=1 AND class='2nd' THEN 1.0 ELSE 0.0 END) AS FLOAT)/
		CAST(SUM(CASE WHEN class='2nd' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 as prct_2nd_survived,
	CAST(SUM(CASE WHEN survived=1 AND class='3rd' THEN 1.0 ELSE 0.0 END) AS FLOAT)/
		CAST(SUM(CASE WHEN class='3rd' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 as prct_3rd_survived,
	CAST(SUM(CASE WHEN survived=1 AND class IS NULL THEN 1.0 ELSE 0.0 END) AS FLOAT)/
		CAST(SUM(CASE WHEN class IS NULL THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 as prct_unknown_survived
FROM passengers;