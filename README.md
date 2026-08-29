# Customer Analytics: RFM Segmentation & Retention SQL & Power BI Project
 
## Introduction
 
This project uses SQL to explore a customer/orders dataset from an e-commerce business, combining RFM (Recency, Frequency, Monetary) segmentation with churn, acquisition, revenue, and product-level analysis.
 
The analysis builds a chain of targeted questions to challenge initial assumptions: Does RFM segmentation actually predict churn? Is acquisition channel the reason some customers never order? Does browsing behavior, device, or delivery speed meaningfully change how customers spend or return products?
 
📁 - Source Dataset: [Kaggle - E-Commerce Customer Behavior and Sales (2020–2026)](https://www.kaggle.com/datasets/meruvakodandasuraj/e-commerce-customer-behavior-and-sales-20202026)
## Background
 
The analysis works through a chain of questions, each one built to test or challenge the previous finding:
 
1. Does RFM segmentation (recency, frequency, monetary value) meaningfully separate customers, and does it align with the dataset's own churn label?
2. Do different segments prefer different product categories or come from different acquisition channels — information that could inform campaign targeting?
3. Of the total customer base, how many have never placed an order, and is acquisition channel the reason?
4. Are churn and return behavior driven by anything structural (device, delivery speed, browsing session length), or are they mostly noise?
5. At the product and category level, where is revenue concentrated, and where are the hidden problem areas (high returns, under-the-radar high performers)?
## Tools
 
- **SQL**: Core language for querying, aggregation, window functions (`NTILE`, `PARTITION BY`), CTEs, `CASE WHEN` segmentation logic, and join-based comparisons.
- **PostgreSQL**: Database used to host and query the dataset.
- **VS Code**: Primary code editor used for writing and managing local SQL queries.
- **GitHub**: Version control platform used to host the repository.
- **Claude**: AI collaborator utilized to assist with query debugging and structuring the analysis.
## Analysis & Key Findings
 
### 1. RFM Segmentation
 
Customers are scored on Recency, Frequency, and Monetary value (each split into quartiles via `NTILE(4)`), then classified into segments (Champions, Loyal Customers, Big Spenders, New Customers, At Risk, Lost, Others) based on combined R/F/M score thresholds.
 
### 2. Does RFM Segment Predict the Dataset's Churn Label?
 
Checking churn rate within the "At Risk" and "Lost" segments:
 
- 48 of 428 At Risk customers churned (**11.2%**).
- 209 of 2,129 Lost customers churned (**9.8%**).
- Contrary to expectations, the two rates are close — and Lost customers even churn at a *slightly lower* rate than At Risk customers.
- **Finding:** RFM segmentation correctly separates customers by behavior (spend, frequency, recency), but it does not correlate strongly with the dataset's `churned` label — suggesting the churn flag was likely assigned on a different basis. Campaign targeting should be built around the RFM segments themselves (especially At Risk and Lost), rather than relying on the churned flag.
### 3. Segment Behavior: Category Preference, Acquisition Channel, and Returns
 
- Preferred product category was compared between Champions and At Risk customers, to inform category-personalized campaign content.
- Acquisition channel was checked specifically for Champions, to inform which channel deserves more marketing budget.
- Return rate by segment: **Big Spenders have the highest return rate** — consistent with buying more/pricier items, which raises return likelihood — but the gap isn't large enough on its own to change campaign strategy.
### 4. Customer Base vs. Active Customers
 
- Total customers: **~8,000**.
- Customers who placed at least one order: **7,663** — meaning a meaningful portion of the customer base never converts to a first order.
- Acquisition channel breakdown of non-ordering customers closely mirrors the breakdown of ordering customers.
- **Finding:** acquisition channel isn't the problem behind non-converting customers — the focus should shift toward running conversion-oriented campaigns rather than changing acquisition strategy.
### 5. Behavioral Signals: Session, Device, and Delivery
 
- **Repeat vs. first-time customers:** average session duration (~16.7–16.9 min) and pages viewed before purchase (~6.5) are nearly identical between the two groups. Browsing behavior isn't a meaningful signal for distinguishing customer types in this dataset.
- **Device used:** average order value is nearly flat across Desktop ($126.86), Tablet ($126.29), and Mobile ($124.47) — within 2% of each other. Return rates also cluster tightly (~7.4–8.2%). Mobile dominates order volume (13,989 orders, ~58% of total), but doesn't behave differently once it's shopping.
- **Delivery speed:** bucketing delivery into 1–3, 4–7, and 8+ days shows no meaningful difference in return rate (7.9–8.2%) or average customer rating (4.00–4.01). The expected "longer delivery = lower satisfaction" relationship isn't present in this dataset.
### 6. Product & Category Performance
 
- **Top 10 products by revenue** are dominated by Electronics, clustered tightly in both revenue (~$100K–$124K) and order count (~409–466).
- **Highest-return products** are spread across low-order-count categories (Travel & Luggage, Pet Supplies, Office Supplies), mostly under 100 orders each, with return rates of 13–17% — well above the overall ~8% average. Ratings are mid-range (3.6–4.2), not low enough to fully explain the returns on their own. Two products stand out as likely genuine quality issues: Portable Scale (3.82 rating) and Pet Shampoo Natural (3.60 rating), both combining high returns with below-average ratings.
- **Category-level revenue:** Electronics leads by a wide margin ($1.08M, more than double the next category), with a return rate (8.5%) right at the dataset average — its revenue lead isn't coming at a return-rate cost. Clothing & Apparel ($424K) and Home & Kitchen ($413K) form a clear second tier; Clothing has the lowest return rate overall (7.7%) despite high volume (3,748 orders) — a strong, low-friction performer. Travel & Luggage and Pet Supplies both show the opposite pattern: relatively low revenue paired with the highest return rates (10.0% and 9.9% respectively), pointing to a category-wide quality or fit issue rather than isolated product problems.
## Limitations
 
- The dataset's `churned` flag does not align well with RFM-based segments, and its underlying definition/methodology isn't documented — conclusions about churn should lean on RFM segment behavior (recency, frequency, monetary decline) rather than the flag itself.
- Several behavioral splits (device, delivery speed, session duration) showed no meaningful differences — while informative, these are negative findings and don't rule out other unmeasured factors (e.g., marketing message, price sensitivity) driving customer behavior.
- Return-rate outliers at the product level (e.g., Portable Scale, Pet Shampoo Natural) are based on relatively low order counts (under 100), so while the return rates are well above average, the absolute sample sizes are still fairly small.
## Recommendations

Translating the segment and campaign findings above into concrete next steps:

**By segment:**

| Segment | Recommended Action |
|---|---|
| Champions | Early access & VIP previews, not discounts. Invite into a referral program. |
| Loyal Customers | Bundle offers and cross-sell to lift order value, not frequency. |
| Big Spenders | Subscription or reorder reminders to increase visit frequency. |
| New Customers | Second-purchase discount within the first 30 days, plus an onboarding email series. |
| At Risk | "We miss you" win-back email with a strong incentive — highest priority, given this segment's elevated churn rate. |
| Lost | Low-cost automated win-back (lower priority than At Risk, given the larger volume and lower expected return). |

**By campaign opportunity:**

- **February revenue dip, every year.** Monthly revenue consistently drops in February. A Valentine's Day campaign (Feb 14) focused on Jewelry & Accessories and Beauty & Personal Care could offset the post-holiday slowdown.
- **Travel & Luggage and Pet Supplies** combine low revenue with the highest category-level return rates (~10%) — a product-fit issue worth resolving before running acquisition campaigns for these categories.
- **337 registered customers have never ordered**, and they're spread evenly across acquisition channels — confirming this is an onboarding gap, not a channel problem. Worth a dedicated first-purchase campaign.

## Conclusions

- **RFM segments are a better targeting signal than the churn flag.** The dataset's churn label doesn't meaningfully separate from RFM-based Lost/At Risk segments, so campaign targeting should be built on RFM behavior directly.
- **Acquisition isn't the conversion bottleneck.** Non-ordering customers come from the same channel mix as ordering customers, so the drop-off happens after acquisition — campaigns, not channel strategy, are the lever to pull.
- **Most operational factors (device, delivery speed, browsing session) don't move the needle.** Order value, return rate, and satisfaction stay flat across these dimensions — the meaningful differences in this dataset show up at the segment and category level, not the operational level.
- **Return-rate problems are concentrated, not uniform.** A handful of low-volume categories (Travel & Luggage, Pet Supplies) and specific products consistently show elevated return rates alongside below-average ratings — these are the most actionable quality-control targets, rather than treating returns as a uniform cost across the catalog.
