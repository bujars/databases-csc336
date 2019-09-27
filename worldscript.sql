\pset footer off
\echo '\n\n'



-- Show columns available for each table, and what kind of data is in them:
\echo 'city:'
SELECT * FROM city LIMIT 2;

\echo 'country:'
SELECT * FROM country LIMIT 2;

\echo 'countrylanguage:'
SELECT * FROM countrylanguage LIMIT 2;




-- Warm-ups:
\echo 'Top 10 countries by GNP.'

SELECT name, region, gnp 
    FROM country
    ORDER BY gnp DESC
    LIMIT 10
    ;



\echo 'Top 10 countries by GNP per capita. (watch for division by zero !!).'

SELECT name, region, gnp, gnp / population AS gnp_per_capita 
    FROM country
    WHERE gnp <> 0
    ORDER BY gnp_per_capita DESC
    LIMIT 10
    ;



\echo 'Top 10 most densely populated countries.'

SELECT name, surfacearea, population, population / surfacearea AS density
    FROM country
    WHERE gnp <> 0
    ORDER BY density DESC
    LIMIT 10
    ;



\echo 'Bottom 10 most densely populated countries.'

SELECT name, surfacearea, population, population / surfacearea as densitY
    FROM country
    WHERE gnp <> 0
    ORDER BY density ASC
    LIMIT 10
    ;



\echo 'Different forms of government'.

SELECT DISTINCT governmentform 
    FROM country
    ;



\echo 'Most common forms of government.'
-- can be done with or without DISTINCT due to GROUP BY

SELECT governmentform, COUNT(*) AS num
    FROM country 
    GROUP BY governmentform
    ORDER BY num DESC
    ;



\echo 'Life expectancy.'    

SELECT name, lifeexpectancy 
    FROM country 
    WHERE lifeexpectancy IS NOT NULL
    ORDER BY lifeexpectancy DESC 
    LIMIT 10
    ;


-- Getting more serious - JOINS

\echo 'Top 10 countries by population, and the official language spoken there?'
SELECT a.name, a.population, b.language
    FROM country a
        INNER JOIN countrylanguage b
            ON a.code = b.countrycode
    WHERE b.isofficial='t'  -- also:  TRUE
    ORDER BY a.population DESC
    LIMIT 10
    ;

SELECT a.name, a.population
    FROM country a
    ORDER BY a.population DESC
    LIMIT 10
    ;



\echo 'What are the top 10 most populated cities?'
\echo 'We want a list of them, along with their country and the continent they are on.'

SELECT a.name, a.population, b.name, b.continent
    FROM city a
        INNER JOIN country b
            ON a.countrycode = b.code
    ORDER BY a.population DESC
    LIMIT 10
    ; 


\echo 'Official language of each of these cities?'

select a.name, a.population, b.name, b.continent, c.language
    FROM city a
        INNER JOIN country b
            ON a.countrycode = b.code
        INNER JOIN countrylanguage c
            ON b.code = c.countrycode
    WHERE c.isofficial='t'
    ORDER BY a.population DESC
    LIMIT 10
    ;




\echo 'Which of the above cities (top 10 by population) are capitals of their country?'

SELECT a.name AS city_name, b.name AS country_name
    FROM city a
        INNER JOIN country b
            ON a.id = b.capital
    WHERE a.name IN 
        (SELECT name 
            FROM city
            ORDER BY population DESC 
            LIMIT 10
        )
    ;



        \echo 'OR: (alt method) NOTE: Must have same number of columns to use INTERSECT.'

        (SELECT a.name AS city_name, b.name AS country_name
            FROM city a
                INNER JOIN country b
                    ON a.id = b.capital
            )

        INTERSECT

        (SELECT a.name, b.name
            FROM city a
                INNER JOIN country b
                    ON a.countrycode = b.code
            ORDER BY a.population DESC LIMIT 10
        ) 
        ;



        \echo 'OR: (alt method) Common Table Expression (CTE).'

        WITH top_10_by_pop AS 
            (
                SELECT name
                    FROM city 
                    ORDER BY population DESC LIMIT 10
             ) 

        SELECT a.name AS city_name, b.name AS country_name
            FROM city a
                INNER JOIN country b
                    ON a.id = b.capital
                INNER JOIN top_10_by_pop c
                    ON a.name = c.name
            ;



        \echo ' NOTE:  This one is NOT correct:  Top 10 most populated capitals,'
        \echo '        NOT Capitals in top 10 most populated cities.'
        \echo '        (compare population numbers for top-10 cities to these).'

            SELECT a.name AS city_name, b.name AS country_name, a.population as city_pop
                FROM city a
                    INNER JOIN country b
                        ON a.id = b.capital
                ORDER BY city_pop DESC LIMIT 10
                ;


\echo 'For the above question, what percent of the country lives in the capital city?'

SELECT  a.name, b.name, a.population AS city_population, b.population AS country_population,
        ((a.population::FLOAT) / (b.population::FLOAT))*100 AS percent
        -- (CAST(a.population AS FLOAT) / CAST(b.population AS FLOAT))*100 AS percent
    FROM city a
        INNER JOIN country b
            ON a.id = b.capital
    WHERE a.name IN 
        (SELECT name 
            FROM city 
            ORDER BY population DESC 
            LIMIT 10
        ) 
    ORDER BY percent DESC
    ;

\echo '\n'
