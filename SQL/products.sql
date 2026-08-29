-- Top 10 products by revenue
SELECT product_name, total_revenue_usd, total_orders
FROM product_summary
ORDER BY total_revenue_usd DESC
LIMIT 10;
 
-- Finding: the top 10 products are dominated by consumer electronics/gadgets
-- -- all Electronics category, clustered tightly in both revenue
-- (~$100K-$124K) and order count (~409-466).
 

-- Products with the highest return rate (problem products)
SELECT product_name, category, return_rate, total_orders, avg_rating
FROM product_summary
ORDER BY return_rate DESC
LIMIT 10;
 
-- Finding: highest-return products are spread across low-order-count
-- categories (Travel & Luggage, Pet Supplies, Office Supplies) -- mostly
-- under 100 orders, unlike the high-revenue electronics list. Return rates
-- (13-17%) are notably higher than the overall order return rate (~8%), so
-- these are genuine outliers, not just noise from small sample sizes.
-- Ratings are mid-range (3.6-4.2), not bad enough to fully explain the
-- returns -- worth flagging Portable Scale and Pet Shampoo Natural
-- specifically, since they combine a high return rate with a below-average
-- rating (3.82, 3.60), suggesting a real product-quality issue

 
-- Goal: total revenue and average rating by category
-- (aggregate product_summary by category)

SELECT
    category,
    SUM(total_revenue_usd) AS total_revenue,
    SUM(total_orders) AS total_orders,
    ROUND(AVG(return_rate), 1) AS avg_return_rate
FROM product_summary
GROUP BY category;
 
-- Finding: Electronics dominates category revenue ($1.08M, more than double
-- #2), consistent with the product-level finding -- but its return rate
-- (8.5%) is right at the dataset average, so the revenue lead isn't coming
-- at a return-rate cost. Clothing & Apparel ($424K) and Home & Kitchen
-- ($413K) are a clear second tier; Clothing actually has the lowest return
-- rate overall (7.7%) -- a strong, low-friction performer despite high
-- volume (3,748 orders). On the flip side, Travel & Luggage has the highest
-- return rate (10.0%) paired with relatively low revenue ($84K) -- this
-- matches the earlier product-level outliers (Money Belt, Portable Scale)
-- and suggests a category-wide quality/fit issue. Pet Supplies shows the same
-- pattern (low revenue, 9.9% returns) 

 
-- Goal: high rating but low sales -- promising but under-the-radar products
SELECT
    product_name,
    SUM(total_revenue_usd) AS revenue,
    avg_rating,
    SUM(total_orders) AS orders
FROM product_summary
WHERE avg_rating >= 4
GROUP BY product_name, avg_rating
ORDER BY orders ASC;
 

 
