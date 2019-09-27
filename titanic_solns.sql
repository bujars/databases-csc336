\pset footer off
\echo

/*
-- How many total:
SELECT COUNT(*) AS total_passengers FROM passengers;

-- How many survived?
SELECT COUNT(*) AS survived FROM passengers WHERE survived=1;

-- How many died?
SELECT COUNT(*) AS did_not_survive FROM passengers WHERE survived=0;

-- How many were female? Male?
-- Percentage of males of the total?
SELECT COUNT(*) AS total_females FROM passengers WHERE sex='female';
SELECT COUNT(*) AS total_males FROM passengers WHERE sex='male';

-- How many total females died?  Males?
-- Percentage of males of the total?
SELECT COUNT(*) AS no_survived_females
FROM passengers 
WHERE sex='female' 
        AND survived=0;

SELECT COUNT(*) AS no_survived_males 
FROM passengers 
WHERE sex='male' 
        AND survived=0;

-- Percentage of females of the total?
-- Percentage of males of the total?
SELECT 
    SUM(CASE WHEN sex='female' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 AS tot_pct_female 
FROM passengers;

-- Percentage of males of the total?
SELECT 
    SUM(CASE WHEN sex='male' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 AS tot_pct_male 
FROM passengers;

*/

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- What percent survived? (both male AND female)
SELECT 
    SUM(CASE WHEN survived=1.0 THEN 1 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 AS tot_pct_survived 
FROM passengers;

    -- OR:  (because 'survived' is numeric data IN this CASE:)

    SELECT (
            CAST(SUM(survived) AS FLOAT) / 
            CAST(COUNT(*) AS FLOAT))*100 AS tot_pct_survived
    FROM passengers;


-- Percentage of females that survived?
SELECT 
    SUM(survived) / CAST(COUNT(*) AS FLOAT)*100 AS female_survival_pct
FROM passengers
WHERE sex='female';


-- Percentage of males that survived?
SELECT 
    SUM(survived) / CAST(COUNT(*) AS FLOAT)*100 AS male_survival_pct
FROM passengers
WHERE sex='male';


-- How many people total were in First class, Second class, Third, or unknown ?
SELECT class, COUNT(*)
FROM passengers
GROUP BY class
ORDER BY class;

    -- OR:

    SELECT COUNT(*) AS num_in_unk_class
    FROM passengers
    WHERE class IS NULL;
    -- WHERE class='1st';


-- What is the total number of people IN First AND Second class ?
SELECT COUNT(*) AS tot_1st_and_2nd_class 
FROM passengers 
WHERE class IN ('1st', '2nd');

    -- OR:

    SELECT COUNT(*) AS tot_1st_and_2nd_class 
    FROM passengers 
    WHERE class='1st' OR class='2nd';


-- Survival percentages of different classes:
SELECT
    class,
    SUM(CASE WHEN survived=1 THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 AS first_class_pct_survived 
FROM passengers
GROUP BY class
ORDER BY class;






