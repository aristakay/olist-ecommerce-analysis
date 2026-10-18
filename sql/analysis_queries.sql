-- =========================================================
-- OLIST E-COMMERCE BUSINESS ANALYSIS
-- Phase 2 - SQL Analysis
-- =========================================================

-- Business Question 1:
-- What is the overall order volume?

SELECT
    COUNT(*) AS total_orders
FROM public.olist_orders;

-- Business Question 2:
-- What is the total revenue generated from order items?

SELECT
    ROUND(SUM(price), 2) AS total_revenue
FROM public.olist_order_items;
-- Business Question 3:
-- How much freight value was charged?

SELECT
    ROUND(SUM(freight_value), 2) AS total_freight_value
FROM public.olist_order_items;
-- Business Question 4:
-- How many individual items were sold?

SELECT
    COUNT(*) AS total_items_sold
FROM public.olist_order_items;
-- Business Question 5:
-- What is the average merchandise value per order?

SELECT
    ROUND(
        SUM(oi.price) / COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value
FROM public.olist_order_items oi;
-- Business Question 6:
-- How are orders distributed across statuses?

SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_orders
FROM public.olist_orders
GROUP BY order_status
ORDER BY order_count DESC;
-- Business Question 7:
-- How did order volume change month by month?

SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
    COUNT(*) AS total_orders
FROM public.olist_orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY month;
-- Business Question 8:
-- How did merchandise revenue change month by month?

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM public.olist_orders o
JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY month;
-- Business Question 9:
-- Which product categories generate the most revenue?

SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM public.olist_order_items oi
JOIN public.olist_products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC;
-- Business Question 10:
-- What percentage of total revenue comes from each category?

WITH category_revenue AS (
    SELECT
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        ) AS category,
        SUM(oi.price) AS revenue
    FROM public.olist_order_items oi
    JOIN public.olist_products p
        ON oi.product_id = p.product_id
    LEFT JOIN public.product_category_translation pct
        ON p.product_category_name = pct.product_category_name
    GROUP BY
        COALESCE(
            pct.product_category_name_english,
            p.product_category_name,
            'Unknown'
        )
)

SELECT
    category,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        revenue * 100.0 / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct
FROM category_revenue
ORDER BY revenue DESC;
-- Business Question 11:
-- Which products generate the most revenue?

SELECT
    oi.product_id,
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
FROM public.olist_order_items oi
JOIN public.olist_products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY
    oi.product_id,
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY revenue DESC
LIMIT 20;
-- Business Question 12:
-- Which sellers generate the most revenue?

SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM public.olist_order_items oi
JOIN public.olist_sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY revenue DESC
LIMIT 20;
-- Business Question 13:
-- Which customer states generate the most revenue?

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER (),
        2
    ) AS revenue_share_pct
FROM public.olist_orders o
JOIN public.olist_customers c
    ON o.customer_id = c.customer_id
JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;
-- Business Question 14:
-- How many customers are one-time vs repeat customers?

WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS order_count
    FROM public.olist_orders o
    JOIN public.olist_customers c
        ON o.customer_id = c.customer_id
    GROUP BY customer_unique_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS customer_share_pct
FROM customer_orders
GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time customer'
        ELSE 'Repeat customer'
    END
ORDER BY customers DESC;
-- Business Question 15:
-- Which customers generate the most revenue?

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(*) AS items_purchased,
    ROUND(SUM(oi.price), 2) AS revenue
FROM public.olist_orders o
JOIN public.olist_customers c
    ON o.customer_id = c.customer_id
JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY revenue DESC
LIMIT 20;
-- Business Question 16:
-- Which payment methods are most frequently used?

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM public.olist_order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;
-- Business Question 17:
-- How are credit card installments distributed?

SELECT
    payment_installments,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value
FROM public.olist_order_payments
WHERE payment_type = 'credit_card'
GROUP BY payment_installments
ORDER BY payment_installments;
-- Business Question 18:
-- How long do customers wait for their orders?

SELECT
    COUNT(*) AS delivered_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_delivery_days,

    ROUND(
        MIN(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS min_delivery_days,

    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        )::numeric,
        2
    ) AS max_delivery_days

FROM public.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
  -- Business Question 19:
-- How often are orders delivered later than promised?

SELECT
    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              > order_estimated_delivery_date
    ) AS late_orders,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              <= order_estimated_delivery_date
    ) AS on_time_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE order_delivered_customer_date
                  > order_estimated_delivery_date
        )
        / COUNT(*),
        2
    ) AS late_percentage

FROM public.olist_orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- Business Question 20:
-- Which customer states have the highest late-delivery rates?

SELECT
    c.customer_state AS state,

    COUNT(*) AS delivered_orders,

    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date
              > o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date
                  > o.order_estimated_delivery_date
        )
        / COUNT(*),
        2
    ) AS late_percentage

FROM public.olist_orders o

JOIN public.olist_customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY late_percentage DESC;
-- Business Question 21:
-- How many days late are late deliveries?

SELECT
    COUNT(*) AS late_orders,

    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        )::numeric,
        2
    ) AS avg_days_late,

    ROUND(
        MIN(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        )::numeric,
        2
    ) AS minimum_days_late,

    ROUND(
        MAX(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_estimated_delivery_date
                )
            ) / 86400
        )::numeric,
        2
    ) AS maximum_days_late

FROM public.olist_orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
  AND order_delivered_customer_date > order_estimated_delivery_date;
  -- Business Question 22:
-- Are late deliveries associated with lower customer review scores?

SELECT
    CASE
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,

    COUNT(DISTINCT o.order_id) AS orders,

    COUNT(r.review_id) AS reviews,

    ROUND(
        AVG(r.review_score)::numeric,
        2
    ) AS average_review_score

FROM public.olist_orders o

JOIN public.olist_order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END

ORDER BY average_review_score;
-- Business Question 23:
-- How does the review-score distribution differ between late and on-time deliveries?

SELECT
    CASE
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END AS delivery_status,

    r.review_score,

    COUNT(*) AS review_count,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (
            PARTITION BY
                CASE
                    WHEN o.order_delivered_customer_date
                         > o.order_estimated_delivery_date
                    THEN 'Late'
                    ELSE 'On time'
                END
        ),
        2
    ) AS percentage_of_reviews

FROM public.olist_orders o

JOIN public.olist_order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date
             > o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On time'
    END,
    r.review_score

ORDER BY
    delivery_status,
    r.review_score;
	-- Business Question 24:
-- Which product categories have the lowest customer review scores?

SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT o.order_id) AS orders,

    COUNT(r.review_id) AS reviews,

    ROUND(
        AVG(r.review_score)::numeric,
        2
    ) AS average_review_score

FROM public.olist_orders o

JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id

JOIN public.olist_products p
    ON oi.product_id = p.product_id

LEFT JOIN public.product_category_translation pct
    ON p.product_category_name = pct.product_category_name

JOIN public.olist_order_reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'

GROUP BY
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

HAVING COUNT(r.review_id) >= 100

ORDER BY average_review_score ASC;
-- Business Question 25:
-- Which product categories have the highest late-delivery rates?

SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT o.order_id) AS delivered_orders,

    COUNT(DISTINCT o.order_id) FILTER (
        WHERE o.order_delivered_customer_date
              > o.order_estimated_delivery_date
    ) AS late_orders,

    ROUND(
        100.0 *
        COUNT(DISTINCT o.order_id) FILTER (
            WHERE o.order_delivered_customer_date
                  > o.order_estimated_delivery_date
        )
        / COUNT(DISTINCT o.order_id),
        2
    ) AS late_percentage

FROM public.olist_orders o

JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id

JOIN public.olist_products p
    ON oi.product_id = p.product_id

LEFT JOIN public.product_category_translation pct
    ON p.product_category_name = pct.product_category_name

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_estimated_delivery_date IS NOT NULL

GROUP BY
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY late_percentage DESC;
-- =========================================================
-- POWER BI VIEWS
-- =========================================================

-- 1. Monthly sales performance
CREATE OR REPLACE VIEW public.vw_monthly_sales AS
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM public.olist_orders o
JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1;


-- 2. Order status
CREATE OR REPLACE VIEW public.vw_order_status AS
SELECT
    order_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM public.olist_orders
GROUP BY order_status
ORDER BY orders DESC;


-- 3. Category performance
CREATE OR REPLACE VIEW public.vw_category_performance AS
SELECT
    COALESCE(
        pct.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_price
FROM public.olist_order_items oi
JOIN public.olist_products p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_translation pct
    ON p.product_category_name = pct.product_category_name
GROUP BY 1
ORDER BY revenue DESC;


-- 4. State performance
CREATE OR REPLACE VIEW public.vw_state_performance AS
SELECT
    c.customer_state AS state,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM public.olist_customers c
JOIN public.olist_orders o
    ON c.customer_id = o.customer_id
JOIN public.olist_order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- 5. Delivery performance
CREATE OR REPLACE VIEW public.vw_delivery_performance AS
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'Unknown'
    END AS delivery_status,
    COUNT(*) AS orders,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM
                (
                    o.order_delivered_customer_date
                    - o.order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS average_delivery_days
FROM public.olist_orders o
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY orders DESC;


-- 6. Payment method performance
CREATE OR REPLACE VIEW public.vw_payment_performance AS
SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(payment_value), 2) AS payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment
FROM public.olist_order_payments
GROUP BY payment_type
ORDER BY payment_value DESC;


-- 7. Customer performance
CREATE OR REPLACE VIEW public.vw_customer_performance AS
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customers,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM public.olist_customers c
    JOIN public.olist_orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) x
GROUP BY 1
ORDER BY customers DESC;


-- 8. Review performance by delivery status
CREATE OR REPLACE VIEW public.vw_delivery_reviews AS
SELECT
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 'On Time'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
            THEN 'Late'
        ELSE 'Unknown'
    END AS delivery_status,
    AVG(r.review_score)::numeric(10,2) AS average_review_score,
    COUNT(*) AS reviews
FROM public.olist_orders o
JOIN public.olist_order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- 9. Seller performance
CREATE OR REPLACE VIEW public.vw_seller_performance AS
SELECT
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS orders,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue,
    ROUND(AVG(oi.price), 2) AS average_item_price
FROM public.olist_order_items oi
JOIN public.olist_sellers s
    ON oi.seller_id = s.seller_id
GROUP BY
    oi.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY revenue DESC;
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
ORDER BY table_name;
SELECT 'vw_category_performance' AS view_name, COUNT(*) AS rows
FROM public.vw_category_performance

UNION ALL

SELECT 'vw_customer_performance', COUNT(*)
FROM public.vw_customer_performance

UNION ALL

SELECT 'vw_delivery_performance', COUNT(*)
FROM public.vw_delivery_performance

UNION ALL

SELECT 'vw_delivery_reviews', COUNT(*)
FROM public.vw_delivery_reviews

UNION ALL

SELECT 'vw_monthly_sales', COUNT(*)
FROM public.vw_monthly_sales

UNION ALL

SELECT 'vw_order_status', COUNT(*)
FROM public.vw_order_status

UNION ALL

SELECT 'vw_payment_performance', COUNT(*)
FROM public.vw_payment_performance

UNION ALL

SELECT 'vw_seller_performance', COUNT(*)
FROM public.vw_seller_performance

UNION ALL

SELECT 'vw_state_performance', COUNT(*)
FROM public.vw_state_performance

ORDER BY view_name;
