/* FULL OUTER JOIN

1. Say you're an analyst at Parch & Posey and you want to see:

each account who has a sales rep and each sales rep that has an 
account (all of the columns in these returned rows will be full)
but also each account that does not have a sales rep and each sales 
rep that does not have an account (some of the columns in these 
returned rows will be empty) */

SELECT accounts.*, sales_reps.*
FROM accounts
FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL /* to check if there are unmatched lines*/

/* INEQUALITY JOINS 

In the following SQL Explorer, write a query that left joins the accounts table and
the sales_reps tables on each sale rep's ID number and joins it using the < comparison
 operator on accounts.primary_poc and sales_reps.name, like so:

accounts.primary_poc < sales_reps.name

The query results should be a table with three columns: the account name (e.g. Johnson Controls),
the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name 
(e.g. Samuel Racine). Then answer the subsequent multiple choice question*/

SELECT accounts.name account_name, accounts.primary_poc, sales_reps.name sales_rep_name
FROM accounts 
LEFT JOIN sales_reps 
ON accounts.sales_rep_id = sales_reps.id
AND accounts.primary_poc < sales_reps.name /* the prinary_poc full name comes before alphabetcally*/

/* SELF JOINS

Modify the query from the previous video, which is pre-populated in the SQL Explorer below, 
to perform the same interval analysis except for the web_events table. Also:

- change the interval to 1 day to find those web events that occurred after, but not more than 
1 day after, another web event

- add a column for the channel variable in both instances of the table in your query

SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at */

SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at

/* UNION 

Write a query that uses UNION ALL on two instances (and selecting all columns) 
of the accounts table. Then inspect the results and answer the subsequent quiz. */

SELECT *
FROM accounts

UNION ALL

SELECT *
FROM accounts

/* Add a WHERE clause to each of the tables that you unioned in the query above, 
filtering the first table where name equals Walmart and filtering the second table 
where name equals Disney. Inspect the results then answer the subsequent quiz. */

SELECT *
FROM accounts
WHERE name='Walmart'

UNION ALL

SELECT *
FROM accounts
WHERE name='Disney'

/* Perform the union in your first query (under the Appending Data via UNION header) 
in a common table expression and name it double_accounts. Then do a COUNT the number 
of times a name appears in the double_accounts table. If you do this correctly, your 
query results should have a count of 2 for each name. */

WITH double_accounts AS (
  SELECT *
  FROM accounts

  UNION ALL

  SELECT *
  FROM accounts
)

SELECT name, COUNT(*)
FROM double_accounts
GROUP BY 1
ORDER BY 2 DESC