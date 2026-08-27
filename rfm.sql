-- Recency: days since each customer's most recent order
-- (reference date 2026-03-30 = max order_date in the dataset)

SELECT customer_id, '2026-03-30' - max(order_date) recency
from orders
group by customer_id
order by recency desc


-- Frequency: number of orders per customer

select customer_id, count(*) frequency
from orders
group by customer_id
order by frequency desc


-- Monetary: total spend per customer

select customer_id, sum(total_amount_usd) monetary
from orders
group by customer_id
order by monetary desc


/*
Segment logic:
 
Segment           | Logic
------------------|---------------------------------------------------------
Champions         | High R, high F, high M
Loyal Customers   | High F (frequent purchases), medium-high R
Big Spenders      | High M but low F (infrequent, but high order value)
New Customers     | High R (recently joined) but low F and M
At Risk           | Low R (hasn't ordered in a long time) but F/M used to be high
Lost              | R, F, and M all low
Others            | Everything else not covered above
*/


-- =========================================================
-- RFM Segmented View
-- Recency reference date: 2026-03-30 (max order_date in dataset)
-- =========================================================
 
CREATE VIEW rfm_segmented AS
WITH recency AS (
    SELECT customer_id, DATE '2026-03-30' - MAX(order_date) AS recency
    FROM orders
    GROUP BY customer_id
),
frequency AS (
    SELECT customer_id, COUNT(order_id) AS frequency
    FROM orders
    GROUP BY customer_id
),
monetary AS (
    SELECT customer_id, SUM(total_amount_usd) AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm AS (
    SELECT 
        r.customer_id,
        r.recency,
        f.frequency,
        m.monetary
    FROM recency r
    JOIN frequency f ON r.customer_id = f.customer_id
    JOIN monetary m ON r.customer_id = m.customer_id
),
rfm_scored AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY recency DESC)  AS r_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary ASC)  AS m_score
    FROM rfm
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    CASE
        WHEN r_score >= 3 AND f_score >= 3 AND m_score >= 3 THEN 'Champions'
        WHEN f_score >= 3 AND r_score >= 2 THEN 'Loyal Customers'
        WHEN m_score >= 3 AND f_score <= 2 THEN 'Big Spenders'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 3) THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Others'
    END AS segment
FROM rfm_scored;


-- Are "Lost" and "At Risk" customers actually churning?

select segment, c.churned, count(*) from rfm_segmented r
join customers c 
ON c.customer_id = r.customer_id
where r.segment = 'Lost' OR r.segment = 'At Risk'
group by churned, segment


-- Finding: 48 of 428 At Risk customers churned (48 / (380 + 48) = 11.2%);
-- 209 of 2,129 Lost customers churned (209 / (1,920 + 209) = 9.8%).
-- Interesting result -- contrary to expectations, the churn rates are quite
-- close to each other, and the "Lost" segment even has a slightly LOWER
-- churn rate than "At Risk".


-- Same comparison, shown as a percentage within each segment

SELECT r.segment, c.churned, COUNT(*) AS musteri_sayisi,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY r.segment), 1) AS segment_ici_yuzde
FROM rfm_segmented r
JOIN customers c ON c.customer_id = r.customer_id
GROUP BY r.segment, c.churned
ORDER BY r.segment, c.churned;

/*
Finding: RFM segmentation correctly separates customer behavior (spend,
frequency, recency), but it does not show a strong correlation with the
dataset's churned label -- suggesting the churn flag may have been assigned
on a different basis. Because of this, campaign targeting should be built
around the RFM segments themselves (especially At Risk and Lost) rather
than the churned flag, which is the more reliable signal here.
*/


-- Which category do Champions gravitate toward, and is it different from
-- what At Risk customers prefer -- for personalizing campaign content by
-- category.

select r.segment, c.preferred_category, count(*)
from customers c
join rfm_segmented r on r.customer_id = c.customer_id
group by r.segment, c.preferred_category
order by segment, count desc


-- Which channel do Champions mostly come from -- informs the decision on
-- which channel deserves more budget.

select c.acquisition_channel, count(*)
from customers c
join rfm_segmented r on r.customer_id = c.customer_id
where r.segment = 'Champions'
group by c.acquisition_channel
order by count desc


-- Do higher-spending segments return more often -- relevant to profit margin.

select r.segment, o.returned, count(*)
from orders o
join rfm_segmented r on r.customer_id = o.customer_id
group by r.segment, o.returned
order by count desc

--- Finding: Big Spenders have the highest return rate (makes sense, since
-- they buy more/pricier items, which raises return likelihood), but the
-- gap isn't large enough to change campaign strategy on its own.


