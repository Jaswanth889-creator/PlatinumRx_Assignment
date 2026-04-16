1. Revenue by sales channel

SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

2. Top 10 customers

SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

3. Monthly revenue, expense, profit

WITH revenue AS (
    SELECT DATE_FORMAT(datetime, '%Y-%m') AS month,
           SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY month
),
expense AS (
    SELECT DATE_FORMAT(datetime, '%Y-%m') AS month,
           SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY month
)
SELECT r.month,
       r.revenue,
       e.expense,
       (r.revenue - e.expense) AS profit,
       CASE 
           WHEN (r.revenue - e.expense) > 0 THEN 'Profitable'
           ELSE 'Not Profitable'
       END AS status
FROM revenue r
LEFT JOIN expense e ON r.month = e.month;

4. Most profitable clinic per city

WITH profit_calc AS (
    SELECT c.city, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime) = 9 AND YEAR(cs.datetime)=2021
    GROUP BY c.city, cs.cid
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM profit_calc
) t
WHERE rnk = 1;

5. Second least profitable clinic per state

WITH profit_calc AS (
    SELECT c.state, cs.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinic_sales cs
    JOIN clinics c ON cs.cid = c.cid
    LEFT JOIN expenses e ON cs.cid = e.cid
        AND MONTH(cs.datetime) = MONTH(e.datetime)
    WHERE MONTH(cs.datetime)=9 AND YEAR(cs.datetime)=2021
    GROUP BY c.state, cs.cid
)
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM profit_calc
) t
WHERE rnk = 2;