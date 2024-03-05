/*Subqueries*/

/* video examples*/

SELECT channel, AVG(nb_events)
FROM (
    SELECT DATE_TRUNC('day', occurred_at) AS day, channel, COUNT(channel) nb_events
    FROM web_events
    GROUP BY day, channel
    ORDER BY 1, 2) sub
GROUP BY 1
ORDER BY 1  /*(since we broke by day in the first query, the average is a daily average)*/

SELECT AVG(gloss_qty) gloss_avg, AVG(poster_qty) poster_avg, AVG(standard_qty) standard_avg, SUM(total_amt_usd) total
FROM orders
WHERE DATE_TRUNC('month', (occurred_at)) =(~
    SELECT DATE_TRUNC('month',MIN(occurred_at)) 
    FROM orders) /*we are selecting only the orders that occurred in the month where the first order was placed*/

/* 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

First, I wanted to find the total_amt_usd totals associated with each sales rep, and I also wanted the region 
in which they were located. The query below provided this information.*/

SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

/* Next, I pulled the max for each region, and then we can use this to pull those rows in our final result.*/

SELECT region_name, MAX(total_amt) total_amt
FROM (
    SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1, 2) t1
GROUP BY 1;

/* Then, to get the sales_rep names we need to join this table with the first one (ver video para mais detalhes no porque de ter de ser assim)*/

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM (
    SELECT region_name, MAX(total_amt) total_amt
    FROM (
        SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1, 2) t1
    GROUP BY 1) t2
JOIN ( 
    SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1,2
    ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

/* 2. For the region with the largest sales total_amt_usd, how many total orders were placed? */

/* First, find the total sales for each reagion*/

SELECT r.name region, SUM(o.total_amt_usd) total_sales
FROM region r
JOIN sales_reps s
ON s.region_id = r.id 
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1

/*Find the region with the most sales*/

 SELECT MAX(total_sales) /*(hide the region name here because we'll be using this in having)*/   
 FROM (
    SELECT r.name region, SUM(o.total_amt_usd) total_sales
    FROM region r
    JOIN sales_reps s
    ON s.region_id = r.id 
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1) t1
GROUP BY 1

/*Then, in a table that joins the region name to the orders, find how many orders were placed in the region whose total equals the max*/

SELECT r.name, COUNT(o.total) nb_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total_amt_usd) = (
    SELECT MAX(total_sales)   
    FROM (
        SELECT r.name region, SUM(o.total_amt_usd) total_sales
        FROM region r
        JOIN sales_reps s
        ON s.region_id = r.id 
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1) t1)

/*3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?*/

/*First, we want to find the account that had the most standard_qty paper. The query here pulls that account, as well as the total amount:*/

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1; /*chose only the account with the most std qty*/

/*Now, I want to use this to pull all the accounts with more total sales:*/

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total /*MORE SALES THAN THE TOTAL SALES OF THE ACCOUNT WITH MORE STD QTY*/
                      FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                            FROM accounts a
                            JOIN orders o
                            ON o.account_id = a.id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) sub);

/*This is now a list of all the accounts with more total orders. We can get the count with just another simple subquery.*/

SELECT COUNT(*)
FROM (SELECT a.name
          FROM orders o
          JOIN accounts a
          ON a.id = o.account_id
          GROUP BY 1
          HAVING SUM(o.total) > (SELECT total 
                      FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                            FROM accounts a
                            JOIN orders o
                            ON o.account_id = a.id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) inner_tab)
                ) counter_tab;

/*4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
how many web_events did they have for each channel? 

First find the costumer who has spent more*/

SELECT a.name account, a.id, SUM(total_amt_usd) usd_spent
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1

/* join prev table on web events to check channel activity. */

SELECT t1.account, w.channel, COUNT(w.channel) nb_channel
FROM web_events w
JOIN (
    SELECT a.name account, a.id acc_id, SUM(total_amt_usd) usd_spent
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY 1,2
    ORDER BY 3 DESC
    LIMIT 1
) t1
ON w.account_id = t1.acc_id
GROUP BY t1.account, channel
ORDER BY nb_channel DESC

/*5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?*/

/* Find the top ten spending accounts */

SELECT a.id acc_id, a.name account_name, SUM(total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY acc_id, account_name
ORDER BY total_spent DESC
LIMIT 10

/* average total */

SELECT AVG(total_spent) avg_spent_top10
FROM (
    SELECT a.id acc_id, a.name account_name, SUM(total_amt_usd) total_spent
    FROM accounts a
    JOIN orders o
    ON o.account_id = a.id
    GROUP BY acc_id, account_name
    ORDER BY total_spent DESC
    LIMIT 10
)

/* 6. What is the lifetime average amount spent in terms of **total_amt_usd**, 
including only the companies that spent more per order, on average, than the average of all orders. */

/* First, get the average spent per order*/

SELECT AVG(total_amt_usd)
FROM orders o

/* get the accounts that on average spent more than this number */

SELECT o.account_id acc_id, AVG(o.total_amt_usd) total_spent
FROM orders o 
GROUP BY 1
HAVING AVG(o.total_amt_usd) > (
    SELECT AVG(total_amt_usd)
    FROM orders o
)

/* average only from these accounts */

SELECT AVG(total_spent)
FROM (
    SELECT o.account_id acc_id, AVG(o.total_amt_usd) total_spent
    FROM orders o 
    GROUP BY 1
    HAVING AVG(o.total_amt_usd) > (
        SELECT AVG(total_amt_usd)
        FROM orders o
) 
) sub

/*------------------------------------*/

/*SAME QUESTIONS BUT USING WITH*/

WITH total_for_sales_rep AS (
    SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
    FROM sales_reps s
    JOIN accounts a
    ON a.sales_rep_id = s.id
    JOIN orders o
    ON o.account_id = a.id
    JOIN region r
    ON r.id = s.region_id
    GROUP BY 1,2
    ORDER BY 3 DESC),

max_region AS (
    SELECT region_name, MAX(total_amt) total_amt
    FROM total_for_sales_rep
    GROUP BY 1)


SELECT total_for_sales_rep.rep_name, total_for_sales_rep.region_name, total_for_sales_rep.total_amt
FROM max_region
JOIN total_for_sales_rep
ON max_region.region_name = total_for_sales_rep.region_name AND max_region.total_amt = total_for_sales_rep.total_amt;