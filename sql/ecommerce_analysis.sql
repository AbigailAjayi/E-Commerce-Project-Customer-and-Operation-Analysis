-- ============================================================================
-- E-Commerce Customer and Operations Analysis
-- ============================================================================

USE e_commerce_db;

-- ----------------------------------------------------------------------------
-- 1. Data Quality Checks
-- ----------------------------------------------------------------------------

-- Check for duplicate product IDs
SELECT
    product_id,
    COUNT(*) AS record_count
FROM ecommerce_data
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Flag invalid or out-of-range values
SELECT *
FROM ecommerce_data
WHERE price <= 0
   OR stock_level < 0
   OR customer_age < 18
   OR customer_age > 100
   OR return_rate < 0
   OR return_rate > 100;

-- ----------------------------------------------------------------------------
-- 2. Exploratory & Analytical Views
-- ----------------------------------------------------------------------------

-- Product count by category
SELECT
    category,
    COUNT(*) AS product_count
FROM ecommerce_data
GROUP BY category
ORDER BY product_count DESC;

-- Comprehensive category performance summary
CREATE OR REPLACE VIEW v_category_performance AS
SELECT
    category,
    COUNT(product_id) AS product_count,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(AVG(discount), 2) AS average_discount,
    ROUND(AVG(popularity_index), 2) AS average_popularity,
    SUM(stock_level) AS total_stock_units,
    ROUND(AVG(stock_level), 2) AS average_stock,
    ROUND(AVG(return_rate), 2) AS average_return_rate
FROM ecommerce_data
GROUP BY category;

-- Shipping method cost and return rate performance
CREATE OR REPLACE VIEW v_shipping_performance AS
SELECT
    shipping_method,
    COUNT(*) AS product_count,
    ROUND(AVG(shipping_cost), 2) AS average_shipping_cost,
    ROUND(AVG(return_rate), 2) AS average_return_rate
FROM ecommerce_data
GROUP BY shipping_method;

-- Inventory stockout risk classification
CREATE OR REPLACE VIEW v_inventory_risk AS
SELECT
    product_id,
    product_name,
    category,
    stock_level,
    popularity_index,
    CASE
        WHEN stock_level <= 10 AND popularity_index >= 75 THEN 'High Risk'
        WHEN stock_level <= 10 THEN 'Low Risk'
        ELSE 'Normal Stock'
    END AS inventory_status
FROM ecommerce_data;