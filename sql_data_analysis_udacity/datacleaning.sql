/* LEFT & RIGHT

1. In the accounts table, there is a column holding the website for each company. The last three digits specify what 
type of web address they are using. A list of extensions (and pricing) is provided here(opens in a new tab). 
Pull these extensions and provide how many of each website type exist in the accounts table.*/

SELECT RIGHT(website,3) AS domain
FROM accounts

/*2. There is much debate about how much the name (or even the first letter of a company name)(opens in a new tab) 
matters. Use the accounts table to pull the first letter of each company name to see the distribution of company 
ames that begin with each letter (or number).*/

SELECT RIGHT(website,3) AS domain, COUNT(*)
FROM accounts
GROUP BY domain
ORDER BY COUNT(*) DESC

/*3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a
 number and a second group of those company names that start with a letter. What proportion of company names start 
 with a letter?*/

 SELECT SUM(num) numbs, SUM(letter) letters /*counts how many company names start with letters or number*/
 FROM  (
    SELECT name, /*needs comma!!*/
    CASE
        WHEN LEFT(UPPER(name),1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 1 
        ELSE 0 /*if it starts with number the column num will have a 1*/
        END AS num, /*needs comma!!*/
    CASE
        WHEN LEFT(UPPER(name),1) IN ('0','1','2','3','4','5','6','7','8','9') THEN 0 
        ELSE 1
        END AS letter
    FROM accounts
 ) t1

 /*4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start 
 with anything else?*/

SELECT SUM(vowel) AS perc_vowel, SUM(non_vowel) AS perc_nonvowel
 FROM  (
    SELECT name, /*needs comma!!*/
    CASE
        WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 1 
        ELSE 0 /*if it starts with number the column num will have a 1*/
        END AS vowel, /*needs comma!!*/
    CASE
        WHEN LEFT(UPPER(name),1) IN ('A','E','I','O','U') THEN 0 
        ELSE 1
        END AS non_vowel
    FROM accounts
 ) t1

/* POSITION 

1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.*/

SELECT 
    LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name, 
    RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
    name,
FROM accounts;

/* 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first 
and last name columns. */

SELECT 
    LEFT(name, STRPOS(name, ' ') - 1) AS first_name, 
    RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) AS last_name
FROM sales_reps;

/* CONCAT 

1. Each company in the accounts table wants to create an email address for each primary_poc. 
The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.*/

SELECT CONCAT(LOWER(first_name),'.',LOWER(last_name),'@',name,'.com') AS email
FROM (
    SELECT 
        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name, 
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
        name
    FROM accounts
) t1

/* 2. You may have noticed that in the previous solution some of the company names include spaces, which 
will certainly not work in an email address. See if you can create an email address that will work by 
removing all of the spaces in the account name, but otherwise your solution should be just as in question 1.*/

SELECT CONCAT(LOWER(first_name),'.',LOWER(last_name),'@',REPLACE(LOWER(name), ' ',''),'.com') AS email
FROM (
    SELECT 
        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name, 
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
        name
    FROM accounts
) t1

/* 3. We would also like to create an initial password, which they will change after their first log in. 
The first password will be the first letter of the primary_poc's first name (lowercase), then the last 
letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter 
of their last name (lowercase), the number of letters in their first name, the number of letters in their 
last name, and then the name of the company they are working with, all capitalized with no spaces. */ 

SELECT 
    CONCAT(
        LEFT(LOWER(first_name),1),
        RIGHT(LOWER(first_name), 1),
        LEFT(LOWER(last_name),1),
        RIGHT(LOWER(last_name), 1),
        LENGTH(first_name),
        LENGTH(last_name),
        REPLACE(UPPER(name),' ','')
    ) AS password
FROM (
    SELECT 
        LEFT(primary_poc, STRPOS(primary_poc, ' ') - 1) AS first_name, 
        RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
        name
    FROM accounts
) t1

/*OR* (esta opção junta todas)*/

WITH t1 AS (
    SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
    FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', name, '.com'), LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '')
FROM t1;

/* CAST Quizz 

1. Check dataset*/

SELECT *
FROM sf_crime_data
LIMIT 10

/* 2. Get date into the right format */

SELECT *,
    ((SUBSTR(date,7,4)||'-'||SUBSTR(date, 1,2))||'-'||SUBSTR(date, 4,2))::date AS formatted_date
FROM sf_crime_data
LIMIT 10

/* COALESCE Quizz

1. Table to work with*/

SELECT *
FROM accounts a
LEFT JOIN orders o /*LEFT JOIN: returns all the records from the left table (accounts) and the matching records from the right table (orders)*/
ON a.id = o.account_id
WHERE o.total IS NULL; 

/*2. Fill the accounts.id column with the account.id*/

SELECT COALESCE(o.id,a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o 
ON a.id = o.account_id
WHERE o.total IS NULL

/* 3. Fill the orders.account_id witht the account.id*/

SELECT COALESCE(o.id,a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id,a.id) filled_accountid
FROM accounts a
LEFT JOIN orders o 
ON a.id = o.account_id
WHERE o.total IS NULL

/* Fill qtys with 0*/

SELECT COALESCE(o.id,a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id,a.id) filled_accountid,
    o.occurred_at, COALESCE(standard_qty,0) AS std_qty_filled, COALESCE(gloss_qty,0) gl_qty_filled, COALESCE(poster_qty,0) pt_qty_filled, 
    COALESCE(total,0) AS total_filled, COALESCE(standard_amt_usd,0) AS std_usd_filled, COALESCE(gloss_amt_usd,0) AS gl_usd_filled, 
    COALESCE(poster_amt_usd,0) AS pt_usd_filled, COALESCE(total_amt_usd,0) AS total_usd_filled
FROM accounts a
LEFT JOIN orders o 
ON a.id = o.account_id
WHERE o.total IS NULL

/* Run 1. with the where removed and count the nb of ids*/

SELECT COUNT(a.id) as count_id
FROM accounts a
LEFT JOIN orders o 
ON a.id = o.account_id 

SELECT COALESCE(o.id,a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id,a.id) filled_accountid,
    o.occurred_at, COALESCE(standard_qty,0) AS std_qty_filled, COALESCE(gloss_qty,0) gl_qty_filled, COALESCE(poster_qty,0) pt_qty_filled, 
    COALESCE(total,0) AS total_filled, COALESCE(standard_amt_usd,0) AS std_usd_filled, COALESCE(gloss_amt_usd,0) AS gl_usd_filled, 
    COALESCE(poster_amt_usd,0) AS pt_usd_filled, COALESCE(total_amt_usd,0) AS total_usd_filled
FROM accounts a
LEFT JOIN orders o 
ON a.id = o.account_id