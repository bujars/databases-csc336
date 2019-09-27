-- Part 1 Question 2:
/* 2. This database is in second normal form. 
 * To be in 2NF, you must be in 1NF and have no partial dependencies. 
 * The database is in 1NF because if we look at the schema, 
 * we notice that we have homogenous data types and atomic data. 
 * Partial dependencies are considered if we have composite primary keys, 
 * which is only present in the countrylanguage table. 
 * If we look at the columns in countrylanguage, 
 * we can see that in order for a language to be official in a country, 
 * it depends on both columns in the primary key, 
 * the same logic is applied for percentage. 
 * Table Country does not allow this database to be in third normal form 
 * because of the transitive dependency between code -> name -> continent -> region.  
 * This database can be normalized by turning table country into third normal form 
 * by creating a new table which contains columns continent 
 * and region from the country table, 
 * and connect to the country table, with now a 'continet_ID' foreign key column 
 * to reference the new table.
 */



-- Part 2

-- Answer to Question 1: 

SELECT name 
FROM country 
ORDER BY gnp DESC 
LIMIT 10; 

-- Answer to Question 2 
-- (Just make sure the population is not 0, incase the data is messed up):


SELECT name, (gnp/CAST( (country.population) AS FLOAT )) AS gnp_per_capita
FROM country 
WHERE country.population <> 0 AND country.population IS NOT NULL
ORDER BY gnp_per_capita DESC 
LIMIT 10;



-- Answer to Question 3:

-- 10 most densely populated countries
SELECT name, (CAST( (country.population) AS FLOAT )/ CAST( (country.surfacearea) AS FLOAT )) as pop_density
FROM country 
ORDER BY pop_density DESC 
LIMIT 10;


/*######Dense = by area*/
/*
-- 10 least densely populated countries
SELECT name, population 
FROM country 
WHERE population IS NOT NULL 
ORDER BY population 
LIMIT 10; 
*/
-- Answer to Question 4: 

-- Part A. 
SELECT DISTINCT governmentform FROM country;

-- Part B.
-- You can say that group by gets them in alphabetical order?...
SELECT DISTINCT governmentform, COUNT(governmentform) AS AMOUNT 
FROM country 
GROUP BY governmentform 
ORDER BY COUNT(governmentform) DESC;

-- Answer to Question 5: 
SELECT name, lifeexpectancy 
FROM country 
WHERE lifeexpectancy IS NOT NULL 
ORDER BY lifeexpectancy DESC; 


-- Answer to Question 6:
SELECT country.name, country.population, countrylanguage.language 
FROM country
INNER JOIN countrylanguage ON country.code=countrylanguage.countrycode
WHERE countrylanguage.isofficial 
ORDER BY country.population DESC
LIMIT 10; 


-- Answer to Question 7:

SELECT country.name as country, country.continent, city.name as city, city.population
FROM country
INNER JOIN city ON country.code = city.countrycode 
ORDER BY city.population DESC
LIMIT 10; 

/*** This doesn't get the right answer because the top populaton isnt exactly a capital, 
which is what's going on here. In good design, we would connect the tables via foreign key, 
but by looking at the raw data, we can see that country codes align with what is in the table. 
And thus we can use this choice. 
(In the case that this isn't acceptable, 
the commented out solution give us what we need via foreign keys)

SELECT country.name as country, country.continent, city.population, city.name as city
FROM country
INNER JOIN city ON country.capital = city.id 
ORDER BY city.population DESC
LIMIT 10; 
*/
-- Answer to Question 8: 
SELECT country.name as country, country.continent, 
        city.name as city, city.population, countrylanguage.language
FROM country
INNER JOIN countrylanguage ON countrylanguage.countrycode = country.code
INNER JOIN city ON country.code = city.countrycode 
WHERE countrylanguage.isofficial 
ORDER BY city.population DESC
LIMIT 10; 

/*** After reviewing 7, this also needs to be changed. 
Although the foriegn key is the capital, that only gives information based on capital.
 So connect by country code. 
SELECT country.name as country, country.continent, 
        city.name as city, city.population, countrylanguage.language
FROM country
INNER JOIN countrylanguage ON countrylanguage.countrycode = country.code
INNER JOIN city ON country.capital = city.id 
WHERE countrylanguage.isofficial 
ORDER BY city.population DESC
LIMIT 10; 
*/

/* SCRAP
SELECT country.name as country, country.continent, city.population, city.name as city
FROM country
INNER JOIN city ON country.code = city.countrycode 
ORDER BY city.population DESC
LIMIT 10; */

-- Answer to Question 9: 

SELECT country.name AS country,  city.name AS city
FROM city 
INNER JOIN country ON country.capital = city.id 
WHERE country.capital in 
    (SELECT city.id
        FROM country
        INNER JOIN city ON country.code = city.countrycode 
        ORDER BY city.population DESC
        LIMIT 10
    );

/* Again updating because #7 changed
SELECT country.name, city.name
FROM city 
INNER JOIN country ON country.capital = city.id 
WHERE country.capital in 
    (SELECT city.id from city 
        INNER JOIN country ON country.capital = city.id 
        ORDER BY city.population DESC
        LIMIT 10
    );
*/
-- Answer to Question 10: 

With temp_table as 
    (SELECT country.code, country.name AS country, 
        city.name AS city, 
        city.population AS city_population, 
        city.id AS city_id,
        country.continent
    FROM city 
    INNER JOIN country ON country.capital = city.id 
    WHERE country.capital in 
        (SELECT city.id
            FROM country
            INNER JOIN city ON country.code = city.countrycode 
            ORDER BY city.population DESC
            LIMIT 10
        )
) SELECT country.name AS country, 
    (CAST(temp_table.city_population AS FLOAT)/CAST(country.population AS FLOAT))
    AS prct_pop 
    FROM temp_table INNER JOIN country on country.code = temp_table.code;

/*SCRAP
select country.name, CAST ((
    SELECT city.population
    FROM city 
    INNER JOIN country ON country.capital = city.id 
    WHERE country.capital in 
        (SELECT city.id
            FROM country
            INNER JOIN city ON country.code = city.countrycode 
            ORDER BY city.population DESC
            LIMIT 10
        )
    )
    AS FLOAT)/country.population FROM country;
    */



/* Old answer incomplete because changed 9. 
WITH temp_table AS (
    SELECT country.name AS country, city.name AS city
    FROM city 
    INNER JOIN country ON country.capital = city.id 
        WHERE country.capital IN 
            (SELECT city.id FROM city 
            INNER JOIN country ON country.capital = city.id 
            ORDER BY city.population DESC
            LIMIT 10
    )
)
SELECT country.name, city.name FROM city
INNER JOIN country ON country.capital=city.capital
*/