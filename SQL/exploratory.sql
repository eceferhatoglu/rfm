/*
================================================================================
 Customer Acquisition, Churn & Revenue Analysis
================================================================================
 A set of exploratory SQL queries covering:
   - Customer base size vs. active (ordering) customers
   - Acquisition channel breakdown for customers with and without orders
   - Monthly revenue trends
   - Churn rate
   - Return rate and its impact on revenue
   - Geographic and device/payment distribution
================================================================================
*/

-- Total number of customers
-- Result: ~8,000 customers

SELECT 
    COUNT (*)
FROM
    customers


-- Number of unique customers who have placed at least one order
-- Result: 7,663 -> there are potential customers who never ordered. 

SELECT
    COUNT (DISTINCT(customer_id))
FROM 
    orders


-- Customers who never placed an order

SELECT  
    c.customer_id
FROM
    customers c
LEFT JOIN 
    orders o 
ON c.customer_id = o.customer_id
WHERE 
    o.order_id IS NULL


-- Where did these non-ordering customers come from? (acquisition channel breakdown)

SELECT  
    c.acquisition_channel, COUNT(C.acquisition_channel)
FROM
    customers c
LEFT JOIN 
    orders o 
ON c.customer_id = o.customer_id
WHERE 
    o.order_id IS NULL
GROUP BY C.acquisition_channel
ORDER BY count(c.acquisition_channel) DESC


-- Date range covered by orders that were placed

SELECT
    MAX(order_date),
    MIN(order_date)
FROM
    orders


-- Where did customers who DID order come from? (acquisition channel breakdown)
-- Finding: distribution mirrors the non-ordering group, so acquisition channels
-- aren't the problem -> the focus should shift to running campaigns instead.

SELECT COUNT(DISTINCT(o.customer_id)), c.acquisition_channel
FROM 
    customers c 
LEFT JOIN
    orders o
ON o.customer_id = c.customer_id
WHERE 
    o.order_id IS NOT NULL
GROUP BY c.acquisition_channel
ORDER BY count desc


-- When do people shop the most, based on monthly revenue?

SELECT month, AVG(avg_order_value), AVG(revenue_usd) 
FROM monthly_revenue
GROUP BY month

-- Full monthly revenue trend

SELECT year, month, revenue_usd, orders, unique_customers, new_customers
FROM monthly_revenue
ORDER BY year, month;


-- What percentage of total customers has churned?

SELECT 
    churned,
    COUNT(*) AS musteri_sayisi,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS yuzde
FROM customers
GROUP BY churned;


-- What percentage of total orders are returns, and their revenue impact?

SELECT
    returned,
    COUNT(*) AS order_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage,
    SUM(total_amount_usd) AS total_revenue,
    ROUND(AVG(total_amount_usd), 2) AS avg_order_value
FROM orders
GROUP BY returned;
 

-- Distribution by country

SELECT
    country,
    COUNT(*) AS customer_count,
    SUM(total_spend_usd) AS total_spend
FROM customers
GROUP BY country
ORDER BY total_spend DESC;


-- Device / payment method distribution

SELECT preferred_device, COUNT(*) 
FROM customers 
GROUP BY preferred_device;

