/*  DBase Assn 1:

    Passengers on the Titanic:
        1,503 people died on the Titanic.
        - around 900 were passengers, 
        - the rest were crew members.

    This is a list of what we know about the passengers.
    Some lists show 1,317 passengers, 
        some show 1,313 - so these numbers are not exact, 
        but they will be close enough that we can spot trends and correlations.

    Lets' answer some questions about the passengers' survival data: 
 */

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- DELETE OR COMMENT-OUT the statements in section below after running them ONCE !!
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/*  Create the table and get data into it: */
/*
DROP TABLE IF EXISTS passengers;

CREATE TABLE passengers (
    id INTEGER NOT NULL,
    lname TEXT,
    title TEXT,
    class TEXT, 
    age FLOAT,
    sex TEXT,
    survived INTEGER,
    code INTEGER
);

-- Now get the data into the database:
\COPY passengers FROM './titanic.csv' WITH (FORMAT csv);

*/

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- DELETE OR COMMENT-OUT the statements in the above section after running them ONCE !!
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


/* Some queries to get you started:  */


-- How many total passengers?:
SELECT COUNT(*) AS total_passengers FROM passengers;


-- How many survived?
SELECT COUNT(*) AS survived FROM passengers WHERE survived=1;


-- How many died?
SELECT COUNT(*) AS did_not_survive FROM passengers WHERE survived=0;


-- How many were female? Male?
SELECT COUNT(*) AS total_females FROM passengers WHERE sex='female';
SELECT COUNT(*) AS total_males FROM passengers WHERE sex='male';


-- How many total females died?  Males?
SELECT COUNT(*) AS no_survived_females FROM passengers WHERE sex='female' AND survived=0;
SELECT COUNT(*) AS no_survived_males FROM passengers WHERE sex='male' AND survived=0;


-- Percentage of females of the total?
SELECT 
    SUM(CASE WHEN sex='female' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_female 
FROM passengers;


-- Percentage of males of the total?
SELECT 
    SUM(CASE WHEN sex='male' THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) AS FLOAT)*100 
            AS tot_pct_male 
FROM passengers;



-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%% Write queries that will answer the following questions:  %%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


-- 1.  What percent of passengers survived? (total)
SELECT 
    SUM(CASE WHEN survived=1 THEN 1.0 ELSE 0.0 END) / 
        CAST (COUNT(*) AS FLOAT)*100
        AS tot_pct_survived
FROM passengers;


-- 2.  What percentage of females survived?     (female_survivors / tot_females)
SELECT 
    SUM(CASE WHEN survived=1 and sex='female' THEN 1.0 ELSE 0.0 END) / 
        CAST (SUM(CASE WHEN sex='female' THEN 1.0 ELSE 0.0 END) AS FLOAT)*100
        AS tot_pct_female_survived
FROM passengers;


-- 3.  What percentage of males that survived?      (male_survivors / tot_males)
SELECT 
    SUM(CASE WHEN survived=1 and sex='male' THEN 1.0 ELSE 0.0 END) / 
        CAST (SUM(CASE WHEN sex='male' THEN 1.0 ELSE 0.0 END) AS FLOAT)*100
        AS tot_pct_male_survived
    FROM passengers;

-- 4.  How many people total were in First class, Second class, Third class, or of class unknown ?
SELECT 
    SUM(CASE WHEN class = '1st' THEN 1.0 ELSE 0.0 END) 
        AS tot_first_class,
    SUM(CASE WHEN class = '2nd' THEN 1.0 ELSE 0.0 END)
        AS tot_second_class,
    SUM(CASE WHEN class = '3rd' THEN 1.0 ELSE 0.0 END)
        AS tot_third_class,
    SUM(CASE WHEN class IS NULL THEN 1.0 ELSE 0.0 END)
        AS tot_unknown_class
    FROM passengers; 

-- 5.  What is the total number of people in First and Second class ?
SELECT COUNT(*) AS tot_first_second_class
FROM passengers 
WHERE class='1st' OR class = '2nd';

-- 6.  What are the survival percentages of the different classes? (3).

/*Need to get back to this but (tot class + survived) / (tot class)*/

/*
SELECT 
    SUM(CASE WHEN class = '1st' AND survived=1 THEN 1.0 ELSE 0.0 END) /
        CAST(COUNT(*) AS FLOAT) * 100 
        AS percent_first_class_survived,
    SUM(CASE WHEN class = '2nd' AND survived=1 THEN 1.0 ELSE 0.0 END)/
        CAST(COUNT(*) AS FLOAT) * 100 
        AS tpercent_second_class_survived,
    SUM(CASE WHEN class = '3rd' AND survived=1 THEN 1.0 ELSE 0.0 END)/
        CAST(COUNT(*) AS FLOAT) * 100 
        AS percent_third_class_survived,
    SUM(CASE WHEN class IS NULL AND survived=1 THEN 1.0 ELSE 0.0 END)/
        CAST(COUNT(*) AS FLOAT) * 100 
        AS percent_unknown_class_survived
    FROM passengers; 
*/
SELECT 
    SUM(CASE WHEN class = '1st' AND survived=1 THEN 1.0 ELSE 0.0 END) /
        CAST(SUM(CASE WHEN class = '1st' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 
        AS percent_first_class_survived,
    SUM(CASE WHEN class = '2nd' AND survived=1 THEN 1.0 ELSE 0.0 END) /
        CAST(SUM(CASE WHEN class = '2nd' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 
        AS percent_second_class_survived,
    SUM(CASE WHEN class = '3rd' AND survived=1 THEN 1.0 ELSE 0.0 END) /
        CAST(SUM(CASE WHEN class = '3rd' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 
        AS percent_third_class_survived,
    SUM(CASE WHEN class IS NULL AND survived=1 THEN 1.0 ELSE 0.0 END) /
        CAST(SUM(CASE WHEN class IS NULL THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100 
        AS percent_unknown_class_survived
FROM passengers; 

-- 7.  Can you think of other interesting questions about this dataset?
--      I.e., is there anything interesting we can learn from it?  
--      Try to come up with at least two new questions we could ask.

-- Question 7 Part A: What are the odds of someone who is under the age of 30 
-- and survived compared to someone over the age of 25 
-- (as the life expectancy was about 50)?


-- Question 7 Part B: What is the percentage of females that are under the age of 25 
-- and that survived? (25 assuming are more able to live and female's 
-- had priorities of getting onto the boats)

-- Question 3: What is the percentage of males that are under 
-- the age of 25 and that survived? (25 assuming are more able to live )

--      Example:
--      Can we calcualte the odds of survival if you are a female in Second Class?
        /** sum female/surve/second class / NOT  female/surve/second */

--      Could we compare this to the odds of survival if you are a female in First Class?
--      If we can answer this question, is it meaningful?  Or just a coincidence ... ?


-- 8.  Can you answer the questions you thought of above?
--      Are you able to write the query to find the answer now?  
--      If so, try to answer the question you proposed.
--      If you aren't able to answer it, try to answer the following:



-- Answer to Question 7 Part A: 

-- I am a bit unsure to the type of answer but will explain in the validation section (Question 9)
-- Option 1: 
SELECT 
    -- SUM(CASE WHEN age<=25 AND survived=1 THEN 1.0 ELSE 0.0 END)  / 
    CAST(COUNT(*) - 
            SUM(CASE WHEN age<=25 AND survived=1 
                THEN 1.0 ELSE 0.0 END)
        AS FLOAT) 
    AS odds_under_and_25_survived_1
FROM passengers; 

-- Option 2: 
SELECT 
    -- SUM(CASE WHEN survived = 1 AND age <= 25 THEN 1.0 ELSE 0.0 END) / 
        CAST(SUM(CASE WHEN (survived = 1 AND age <=25)
                THEN 1.0 ELSE 0.0 END) 
        AS FLOAT) 
    AS odds_under_and_25_survived_2
FROM passengers; 

-- Option 1: 
SELECT 
    SUM(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) 
            - SUM(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE 0.0 END) 
        AS FLOAT)
    AS odds_over_25_survived_1
FROM passengers; 

-- Option 2
SELECT 
    SUM(CASE WHEN survived = 1 AND age >25 THEN 1.0 ELSE 0.0 END) / 
        CAST(SUM(CASE WHEN NOT (survived = 1 AND  age > 25)
                THEN 1.0 ELSE 0.0 END) 
        AS FLOAT) 
    AS odds_over_25_survived_2
FROM passengers; 



-- Answer to Question 7 Part B:
SELECT
    SUM(CASE WHEN survived=1 AND age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(SUM(CASE WHEN age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100
    AS prct_female_under_26_survived
FROM passengers;


-- Answer to Question 7 Part C:
SELECT
    SUM(CASE WHEN survived=1 AND age <=25  AND sex='male' THEN 1.0 ELSE 0.0 END) /  
    CAST(SUM(CASE WHEN age <= 25  AND sex='male' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100
    AS prct_male_under_26_survived
FROM passengers;



-- Answer to Example Problem:
SELECT 
    SUM(CASE WHEN sex='female' AND class='2nd' AND survived=1 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(
        SUM(CASE WHEN NOT (sex='female' AND class='2nd' AND survived=1)
            THEN 1.0 ELSE 0.0 END) 
        AS FLOAT) 
    AS odds_second_fem_surive1
FROM passengers; 

SELECT 
    SUM(CASE WHEN sex='female' AND class='2nd' AND survived=1 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(COUNT(*) - 
            SUM(CASE WHEN sex='female' AND class='2nd' AND survived=1 
                THEN 1.0 ELSE 0.0 END)
        AS FLOAT) 
    AS odds_second_fem_surive2
FROM passengers; 

-- Answer to Example Problem part 2:
SELECT 
    SUM(CASE WHEN sex='female' AND class='1st' AND survived=1 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(SUM(CASE WHEN NOT (sex='female' AND class='1st' AND survived=1)
            THEN 1.0 ELSE 0.0 END) 
    AS FLOAT) 
    AS odds_first_fem_surive 
FROM passengers; 


SELECT 
    SUM(CASE WHEN sex='female' AND class='1st' AND survived=1 
        THEN 1.0 ELSE 0.0 END) / 
    CAST(COUNT(*) - 
        SUM(CASE WHEN sex='female' AND class='1st' AND survived=1 
            THEN 1.0 ELSE 0.0 END)
        AS FLOAT) 
    AS odds_first_fem_surive2
FROM passengers; 


-- 9.  If someone asserted that your results for Question #8 were incorrect,
--     how could you defend your results, and verify that they are indeed correct?


-- Question 7 Part A Verification --: 

-- Verifying my first question:
-- Option 1
SELECT 
    SUM(CASE WHEN age<=25 AND survived=1 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(COUNT(*) - 
            SUM(CASE WHEN age<=25 AND survived=1 
                THEN 1.0 ELSE 0.0 END)
        AS FLOAT) 
    AS odds_under_and_25_survived1
FROM passengers; 

-- A) Get the count of survived and age <= 25
SELECT 
    COUNT(*) as survived_and_25Less
FROM passengers 
WHERE age <=25 AND survived = 1; 

-- Get the total count
SELECT COUNT(*) FROM passengers; 


-- Final: 
/* 
    This solution is correct if we take into consideration all entries, essentially what count does.

    Manually: total passengers is 1313 and number surived and <=25 is 137.
    THus 1313 - 137 = 1176
    137/1176 gives us the answer of 0.116496 which confirms the original query for option 1.
*/ 

-- Option 2: 
SELECT 
    SUM(CASE WHEN survived = 1 AND age <= 25 THEN 1.0 ELSE 0.0 END) / 
        CAST(SUM(CASE WHEN NOT (survived = 1 AND age <=25)
                THEN 1.0 ELSE 0.0 END) 
        AS FLOAT) 
    AS odds_under_and_25_survived_2
FROM passengers; 

SELECT 
    SUM(CASE WHEN survived = 1 AND age <= 25 THEN 1.0 ELSE 0.0 END) as survived_and_25Less
FROM passengers; 

SELECT SUM(CASE WHEN NOT (survived = 1 AND age <=25)
                THEN 1.0 ELSE 0.0 END)  as not_survived_and_25Less
FROM passengers; 

-- Also The below statement confirms the above result Because the count statement takes values in as NULL 
-- (which is why this value is greater than option 1). 
SELECT 
    COUNT(CASE WHEN survived = 1 AND age <= 25 THEN 1.0 ELSE NULL END) / 
        CAST(COUNT(CASE WHEN NOT (survived = 1 AND age <=25)
                THEN 1.0 ELSE NULL END) 
        AS FLOAT) 
    AS odds_under_and_25_survived_2
FROM passengers; 

-- Final: 
/* 
    This solution is correct if we do not count the options of null, essentially 
    we are skipping over certian values.

    Manually: the total passengers not surviving or under the age of 25, 
    excluding nulls is 1039 and number surived and <=25 is 137.
    137/1039 gives us the answer of 0.1318 which confirms the original query for option 2.
*/ 


-- Verifying the second part: ---
-- Original Option 1:
SELECT 
    SUM(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE 0.0 END) / 
        CAST(COUNT(*) 
            - SUM(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE 0.0 END) 
        AS FLOAT)
    AS odds_over_25_survived_1
FROM passengers; 

-- A) Get the count of survived and age > 25
SELECT 
    COUNT(*) as survived_and_more25
FROM passengers 
WHERE age > 25 AND survived = 1; 

-- Get the total count

SELECT COUNT(*) FROM passengers; 

-- Final: 
/* Manually: total passengers is 1313 and number surived and > 25 is 176.
    THus 1313 - 176 = 1137
    176/1137 gives us the answer of 0.15479 which confirms the original query.
*/ 



-- Option 2: 
SELECT 
    SUM(CASE WHEN survived = 1 AND age >25 THEN 1.0 ELSE 0.0 END) / 
        CAST(SUM(CASE WHEN NOT (survived = 1 AND  age > 25)
                THEN 1.0 ELSE 0.0 END) 
        AS FLOAT) 
    AS odds_over_25_survived_2
FROM passengers; 


SELECT 
    SUM(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE 0.0 END) as survived_and_25more
FROM passengers; 

SELECT SUM(CASE WHEN NOT (survived = 1 AND age > 25)
                THEN 1.0 ELSE 0.0 END)  as not_survived_and_25more
FROM passengers; 

-- Also The below statement confirms the above result Because the count statement takes values in as NULL 
-- (which is why this value is greater than option 1). 
SELECT 
    COUNT(CASE WHEN survived = 1 AND age > 25 THEN 1.0 ELSE NULL END) / 
        CAST(COUNT(CASE WHEN NOT (survived = 1 AND age >25)
                THEN 1.0 ELSE NULL END) 
        AS FLOAT) 
    AS odds_over_25_survived
FROM passengers; 

-- Final: 
/* 
    This solution is correct if we do not count the options of null, essentially 
    we are skipping over certian values.

    Manually: the total passengers not surviving or over the age of 25, 
    excluding nulls is 1000 and number surived and > 25 is 176.
    176/1000 gives us the answer of 0.176 which confirms the original query for option 2.
*/ 



-- Question 7 Part B Verifcation:

-- Original
SELECT
    SUM(CASE WHEN survived=1 AND age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END) 
    / 
    CAST(SUM(CASE WHEN age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100
    AS prct_female_under_26_survived
FROM passengers;


-- First compute the number of people <=25 and that are females: 
SELECT SUM(CASE WHEN age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END)  as fem_under_26
FROM passengers; 

-- Next, compute the number of people <=25 and that are females, and that survived:
SELECT SUM(CASE WHEN survived=1 AND age <=25  AND sex='female' 
        THEN 1.0 ELSE 0.0 END) as survived_fem_26
FROM passengers; 

-- Final: 
/* Manually: total females under 26 is 133 and 
    number of females under 26 that surived is 92.
    92/133 is 0.691729 which as a percent is 69.17 which confirms the original query 
    * Note I am taking for granted the cast and * 100 to work...
*/ 

--  Question 7 Part C Verification:

-- Original
SELECT
    SUM(CASE WHEN survived=1 AND age <=25  AND sex='male' THEN 1.0 ELSE 0.0 END) /  
    CAST(SUM(CASE WHEN age <= 25  AND sex='male' THEN 1.0 ELSE 0.0 END) AS FLOAT) * 100
    AS prct_male_under_26_survived
FROM passengers;


-- First compute the number of people <=25 and that are males: 
SELECT SUM(CASE WHEN age <=25  AND sex='male' 
        THEN 1.0 ELSE 0.0 END)  as male_under_26
FROM passengers; 

-- Next, compute the number of people <=25 and that are males, and that survived:
SELECT SUM(CASE WHEN survived=1 AND age <=25  AND sex='male' 
        THEN 1.0 ELSE 0.0 END) as survived_male_26
FROM passengers; 

-- Final: 
/* Manually: total male under 26 is 178 and 
    number of males under 26 that surived is 45.
    45/178 is 0.2528 which as a percent is 25.28 which confirms the original query 
    * Note I am taking for granted the cast and * 100 to work...
*/ 


/* NOTE the example problems can be verified in a similar manner to 
    Question 7 Part A verification. Instead of checking for survived and age, 
    we would check for class, sex, and survived.
    
 */



/*
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Email me ONLY this document - as an attachment.  You may just fill in your answers above.

    Do NOT send any other format except for one single .sql file.

    ZIP folders, word documents, and any other format (other than .sql) will receive zero credit.

    Do NOT copy and paste your queries into the body of the email.

    Your sql should run without errors - please test it beforehand.

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/
