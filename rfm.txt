Month Name = FORMAT(DATE(2000, monthly_revenue[month], 1), "MMMM")
add column

daha sonra sort column by month table view ayarlarından


-- Top category by revenue
SELECT category, SUM(total_revenue_usd) AS total_revenue
FROM product_summary
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 1;


-- Best seller product
SELECT product_name, total_revenue_usd
FROM product_summary
ORDER BY total_revenue_usd DESC
LIMIT 1;


--mobile percentage
Mobile Percentage =
DIVIDE(
    CALCULATE(COUNTROWS('Table'), 'Table'[device] = "mobile"),
    COUNTROWS('Table'),
    0
)


Repeat Customer % = 
DIVIDE(
    CALCULATE(
        COUNTROWS('public orders'),
        'public orders'[is_repeat_customer] = TRUE()
    ),
    COUNTROWS('public orders'),
    0
)

---return rate by device
Return Rate = 
DIVIDE(
    CALCULATE(COUNTROWS('public orders'), 'public orders'[returned] = TRUE),
    COUNTROWS('public orders'),
    0
)




--
SELECT 
    CASE 
        WHEN delivery_days <= 3 THEN '1-3 days'
        WHEN delivery_days <= 7 THEN '4-7 days'
        ELSE '8+ days'
    END AS delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(100.0 * SUM(CASE WHEN returned THEN 1 ELSE 0 END) / COUNT(*), 1) AS return_rate_pct
FROM orders
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
---,

rfm

İlişkiyi kur
Model view'a geç, customers.customer_id → rfm_segmented.customer_id arasında bir ilişki oluştur (yoksa). Bu, segment bilgisini customers'ın demografik alanlarıyla (ör. membership_tier, churned) kesiştirmeni sağlar.


6 segmente ayrı measure:
Champions Count = CALCULATE(COUNTROWS('public rfm_segmented'), 'public rfm_segmented'[segment]="Champions")
........


Churn Rate = DIVIDE(CALCULATE(COUNTROWS(customers), customers[churned]=TRUE), COUNTROWS(customers)) 



