###1. Last booked room per user

SELECT user_id, room_no
FROM (
    SELECT user_id, room_no,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;


2. Total billing per booking (Nov 2021)

SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bc.bill_date, '%Y-%m') = '2021-11'
GROUP BY bc.booking_id;


3. Bills >1000 (Oct 2021)

SELECT bill_id,
       SUM(item_quantity * item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE DATE_FORMAT(bill_date, '%Y-%m') = '2021-10'
GROUP BY bill_id
HAVING bill_amount > 1000;

4. Most & Least ordered item per month (2021)

WITH item_orders AS (
    SELECT 
        DATE_FORMAT(bill_date, '%Y-%m') AS month,
        item_id,
        SUM(item_quantity) AS total_qty
    FROM booking_commercials
    WHERE YEAR(bill_date) = 2021
    GROUP BY month, item_id
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
    FROM item_orders
) t
WHERE most_rank = 1 OR least_rank = 1;

5. Second highest bill per month

WITH bill_values AS (
    SELECT 
        DATE_FORMAT(bill_date, '%Y-%m') AS month,
        bill_id,
        SUM(item_quantity * item_rate) AS total_bill
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bill_date) = 2021
    GROUP BY month, bill_id
)
SELECT *
FROM (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
    FROM bill_values
) t
WHERE rnk = 2;