-- Goal: compare average session_duration_minutes and pages_viewed_before_purchase
-- by is_repeat_customer (true/false) -- do repeat customers decide faster, or
-- browse longer before buying?
SELECT
    is_repeat_customer,
    ROUND(AVG(session_duration_minutes), 2) AS avg_session_duration,
    ROUND(AVG(pages_viewed_before_purchase), 2) AS avg_pages_viewed
FROM orders
GROUP BY is_repeat_customer;
 
-- Finding: session behavior is nearly identical between repeat and first-time
-- customers -- average session duration (~16.7-16.9 min) and pages viewed
-- (~6.5) barely differ. Browsing behavior isn't a meaningful signal for
-- distinguishing customer types in this dataset

 
-- Goal: compare order count, average order value, and return rate by
-- device_used -- which device's shoppers spend more / return more?
SELECT
    device_used,
    ROUND(AVG(total_amount_usd), 2) AS avg_order_value,
    SUM(CASE WHEN returned THEN 1 ELSE 0 END) AS return_count,
    COUNT(*) AS total_orders
FROM orders
GROUP BY device_used
ORDER BY avg_order_value DESC;
 
-- Finding: device usage shows no meaningful behavioral difference -- average
-- order value is nearly flat across Desktop ($126.86), Tablet ($126.29), and
-- Mobile ($124.47), within 2% of each other. Return rates follow the same
-- pattern (~7.4-8.2%), close to the overall dataset average. Mobile has by
-- far the highest order volume (13,989 orders, ~58% of total).

 
-- Goal: bucket delivery_days into ranges (1-3, 4-7, 8+ days) and compare
-- return rate and average customer_rating across those ranges -- does
-- satisfaction/return behavior change as delivery takes longer?

SELECT
    CASE
        WHEN delivery_days <= 3 THEN '1-3 days'
        WHEN delivery_days <= 7 THEN '4-7 days'
        ELSE '8+ days'
    END AS delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(100.0 * SUM(CASE WHEN returned THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct,
    ROUND(AVG(customer_rating), 2) AS avg_rating
FROM orders
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
 
-- Finding: delivery time affects neither the return rate (7.9-8.2%,
-- practically no difference) nor the average rating (4.00-4.01, nearly
-- identical). The expected "longer delivery = lower satisfaction / higher
-- returns" relationship simply isn't present in this dataset.
 