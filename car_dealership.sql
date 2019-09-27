\pset footer off
\echo '\n'
-- HIDE ROW COUNT AT BOTTOM OF RESULTS - JUST ADDS CLUTTER.
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS vehicles;

CREATE TABLE vehicles(
    vin INTEGER UNIQUE,
    descr TEXT,
    year INTEGER,
    vehic_type TEXT,
    cost INTEGER,
    days_in_inventory INTEGER
);

CREATE TABLE customers(
    cust_id INTEGER UNIQUE,
    lname TEXT,
    fname TEXT,
    city TEXT,
    state TEXT
);

CREATE TABLE transactions(
    trans_id INTEGER,
      -- A FOREIGN KEY:  WHAT DOES THIS DO?  
      -- cust_id INTEGER REFERENCES customers(cust_id),
    cust_id INTEGER,
    time TEXT,  -- WOULE BE OF time TYPE - THIS IS JUST AN EXAMPLE
      -- ANOTHER FOREIGN KEY:  
      -- WHAT IF I CHOOS 123456789 HERE?  IS THAT A VALID vehicle IN OUR TABLE?
      -- vehicle INTEGER REFERENCES vehicles(vin),
    vehicle INTEGER,
    sale_price INTEGER,
    pmt_method TEXT
);


INSERT INTO vehicles VALUES 
(1111, 'mustang', 2018, 'sport', 14000, 32),
(1112, 'f150', 2017, 'truck', 11000, 76),
(1231, 'f150', 2018, 'truck', 10500, 38),
(1313, 'explorer', 2018, 'suv', 16000, 12),
(1314, 'escort', 2018, 'economy', 8000, 19),
(1532, 'fiesta', 2017, 'economy', 6000, 22),
(1617, 'f250', 2016, 'truck', 14000, 346),
(1718, 'f350', 2017, 'truck', 16000, 87);

INSERT INTO customers VALUES 
(321,'doe','james','darien','ct'),
(322,'allen','jim','fort lee','nj'),
(323,'smith','fred','stony brook','ny'),
(324,'jones','joe','boston','ma'),
(325,'johnson','john','hartford','ct'),
(326,'harold','ronald','newark','nj');

INSERT INTO transactions VALUES 
(1121,323,'12:07pm 3/1/17',1112,15000,'cash'),
(1122,325,'12:08pm 3/1/17',1111,18000,'loan'),
(1123,321,'02:00pm 3/3/17',1313,22000,'loan'),
(1124,326,'03:12pm 3/4/17',1718,19000,'cash');


\echo '\n\nvehicles table:\n'
SELECT * FROM vehicles;

\echo '\n\ncustomers table:\n'
SELECT * FROM customers;

\echo '\n\ntransactions table:\n'
SELECT * FROM transactions;


-- GROUP BY
SELECT
    state,
    COUNT(*)
FROM
    customers
GROUP BY 
    state
;


\echo '\n'

SELECT 
    AVG(days_in_inventory)::NUMERIC(10, 2) AS avg_days_in_inventory
FROM
    vehicles
;



\echo '\n'

SELECT 
    vehic_type,
    AVG(days_in_inventory)::NUMERIC(10, 2)  AS avg_days_in_inventory 
FROM
    vehicles
GROUP BY
    vehic_type
;



-- WHERE AVG(days_in_inventory) > 10
-- HAVING AVG(days_in_inventory) > (SELECT AVG(days_in_inventory) FROM vehicles)


\echo '\ncustomers INNER JOIN transactions ON customers.cust_id = transactions.cust_id:\n'
-- JOIN AND SEE HOW IT WORKS (TWO WAYS - WHAT IS THE DIFFERENCE?  (IDENTICAL COLUMN NAMES)):
SELECT * 
FROM customers 
    INNER JOIN transactions 
        ON customers.cust_id = transactions.cust_id;


\echo '\ncustomers INNER JOIN transactions USING(cust_id):\n'
-- \echo '\n\nSIMPLE TWO-WAY JOIN: customers-transactions JOIN.\n'
SELECT *
FROM customers 
    INNER JOIN transactions USING(cust_id);


-- JOIN ALL THE THINGS !!    (THREE-WAY JOIN):
\echo '\nALL INFO ON ALL transactions: CUSTOMER-TRANSACTION-vehicle INNER JOINed.\n'
SELECT *
    FROM transactions 
        INNER JOIN customers
        USING(cust_id)
        INNER JOIN vehicles
        ON vehicles.vin = transactions.vehicle;  -- CANNOT USE "USING()" HERE - NOT SAME NAME.

-- QUESTION:  WHY ISN'T THIS TABLE BIGGER - HOW LONG CAN IT BE?
-- QUESTION:  WHY didn't I use USING() on the second join?



\echo '\ntransactions only with customers who live in ny and nj:\n'
SELECT * 
    FROM transactions A 
        INNER JOIN customers B
        ON A.cust_id = B.cust_id
        WHERE B.state IN ('ny', 'nj');  -- CASE SENSITIVE !!

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-- OTHER TYPES OF JOINS:


-- LEFT JOINs:
\echo '\n\nvehicles LEFT JOIN transactions ON vehicles.vin = transactions.vehicle:\n'
SELECT * 
FROM 
    vehicles 
        LEFT OUTER JOIN transactions 
            ON vehicles.vin = transactions.vehicle
WHERE 
    transactions.trans_id IS NULL
;


-- Vehicles that have not sold:
SELECT 
    -- *
    vehicles.* 
FROM 
    vehicles
    LEFT OUTER JOIN transactions
        ON vehicles.vin = transactions.vehicle 
WHERE 
    transactions.vehicle IS NULL;
-- transactions.trans_id, transactions.cust_id, etc. - any that are null will give same results.



SELECT *
FROM customers 
    LEFT OUTER JOIN transactions 
        ON customers.cust_id = transactions.cust_id;


-- WHICH customers HAVEN'T PURCHASED ANYTHING.
SELECT * 
FROM customers 
    LEFT OUTER JOIN transactions 
        ON customers.cust_id = transactions.cust_id 
WHERE transactions.cust_id IS NULL;


-- WILL THIS WORK?
SELECT * 
FROM transactions 
    LEFT OUTER JOIN customers ON transactions.cust_id = customers.cust_id 
WHERE transactions.cust_id IS NULL;


-- HOW BOUT THIS?
SELECT * 
FROM transactions 
    RIGHT OUTER JOIN customers 
        ON transactions.cust_id = customers.cust_id 
WHERE transactions.cust_id IS NULL;


-- QUESTION:  CAN WE MAKE A QUERY THAT WILL RETURN ALL DATA?
-- YES, CAN JOIN.  WILL IT MEAN ANYTHING?  (REALLY, NO - CAN JOIN ANYTHING TO ANYTHING ELSE INDISCRIMINATELY.
SELECT * 
    FROM customers 
    LEFT OUTER JOIN transactions 
        ON customers.cust_id = transactions.cust_id
--    FULL OUTER JOIN vehicles 
--        ON transactions.vehicle = vehicles.vin;
    ;



-- EVERYTHING !!
SELECT * 
    FROM customers 
    FULL OUTER JOIN transactions 
        ON customers.cust_id = transactions.cust_id
    FULL OUTER JOIN vehicles 
        ON transactions.vehicle = vehicles.vin;

