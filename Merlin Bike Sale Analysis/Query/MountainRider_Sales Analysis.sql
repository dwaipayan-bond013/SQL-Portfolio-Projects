use [Adventure Works]
select * from customers
select * from products
select * from sales;

-- Calculate the range of data
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order,
DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS range_date
FROM sales;

-- Total Sales
SELECT FORMAT(SUM(sales_amount), 'N0') AS total_sales FROM sales;

-- Total Items Sold
SELECT FORMAT(SUM(quantity), 'N0') AS total_product_sold FROM sales;

-- Average Selling Price
ALTER TABLE sales ALTER COLUMN price FLOAT;
SELECT ROUND(AVG(price), 2) AS avg_selling_price FROM sales;


-- Total Orders
SELECT COUNT(DISTINCT order_number) AS total_order FROM sales;

-- Total Products
SELECT COUNT(DISTINCT product_name) AS total_products FROM products;

-- Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM customers;

-- Total Customers Who Placed Orders
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM sales;

-- Key metrics summary

SELECT 'Total Sales' AS measure_name, FORMAT(SUM(sales_amount), 'N0') AS value FROM sales
UNION ALL
SELECT 'Total Items Sold', FORMAT(SUM(quantity), 'N0') FROM sales
UNION ALL
SELECT 'Avg Selling Price', FORMAT(ROUND(AVG(price), 2), 'N2') FROM sales
UNION ALL
SELECT 'Total Orders', FORMAT(COUNT(DISTINCT order_number),'N0') FROM sales
UNION ALL
SELECT 'Total Products', FORMAT(COUNT(DISTINCT product_name), 'N0') FROM products
UNION ALL
SELECT 'Total Customers', FORMAT(COUNT(DISTINCT customer_id),'N0') FROM customers
UNION ALL
SELECT 'Customers with Orders', FORMAT(COUNT(DISTINCT customer_key),'N0') FROM sales;


-- Customers by Country
SELECT country, COUNT(customer_key) AS total_customer FROM customers
GROUP BY country ORDER BY total_customer DESC;

-- Customers by Gender
SELECT gender, COUNT(customer_key) AS total_customer FROM customers
GROUP BY gender ORDER BY total_customer DESC;

-- Products by Category
SELECT category, COUNT(product_id) AS total_items FROM products
GROUP BY category ORDER BY total_items DESC;

-- Average Cost by Category
ALTER TABLE products ALTER COLUMN cost FLOAT;
SELECT category, ROUND(AVG(cost),2) AS avg_cost FROM products
GROUP BY category ORDER BY avg_cost DESC;

-- Revenue by Category
SELECT category, FORMAT(SUM(sales_amount),'N0') AS total_revenue FROM products p
LEFT JOIN sales s ON p.product_key = s.product_key
GROUP BY category HAVING SUM(sales_amount) IS NOT NULL
ORDER BY total_revenue DESC;

-- Revenue per Customer
SELECT c.customer_key, CONCAT(first_name, ' ', last_name) AS full_name,
SUM(sales_amount) AS total_revenue FROM customers c
LEFT JOIN sales s ON c.customer_key = s.customer_key
GROUP BY c.customer_key, first_name, last_name
ORDER BY total_revenue DESC;

-- Sold Items Distribution by Country
SELECT c.country, FORMAT(SUM(quantity),'N0') AS total_quantity_sold FROM customers c
LEFT JOIN sales s ON c.customer_key = s.customer_key
GROUP BY c.country ORDER BY total_quantity_sold DESC;

-- Ranking Analysis

-- Top 5 Revenue Products
SELECT TOP 5 p.product_name, FORMAT(SUM(sales_amount),'N0') AS total_revenue FROM products p
LEFT JOIN sales s ON p.product_key = s.product_key
GROUP BY p.product_name ORDER BY total_revenue DESC;

-- Bottom 5 Revenue Products
SELECT TOP 5 p.product_name, SUM(sales_amount) AS total_revenue FROM products p
LEFT JOIN sales s ON p.product_key = s.product_key
GROUP BY p.product_name HAVING SUM(sales_amount) IS NOT NULL
ORDER BY total_revenue;

-- Top 10 Customers by Revenue
WITH t1 AS (
  SELECT c.customer_key, first_name, last_name, SUM(sales_amount) AS total_revenue,
  DENSE_RANK() OVER (ORDER BY SUM(sales_amount) DESC) AS rank
  FROM customers c
  LEFT JOIN sales s ON c.customer_key = s.customer_key
  GROUP BY c.customer_key, first_name, last_name
)
SELECT first_name, last_name, total_revenue FROM t1 WHERE rank <= 10;

-- Bottom 5 Customers by Orders
SELECT TOP 5 c.customer_key, first_name, last_name,
COUNT(DISTINCT order_number) AS total_order FROM customers c
LEFT JOIN sales s ON c.customer_key = s.customer_key
GROUP BY c.customer_key, first_name, last_name
ORDER BY total_order, customer_key;


-- Trend analysis
--Daily Trend of Sales

-- Daily Sales Trend
SELECT order_date, SUM(sales_amount) AS total_sales FROM sales
WHERE order_date IS NOT NULL
GROUP BY order_date ORDER BY order_date;

-- Monthly Sales Trend
SELECT FORMAT(order_date, 'yyyy-MMM') AS order_date,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM sales
WHERE MONTH(order_date) IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');

-- Cumulative Sales
WITH t1 AS (
  SELECT YEAR(order_date) AS year, MONTH(order_date) AS month,
  SUM(sales_amount) AS total_sales FROM sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT *, SUM(total_sales) OVER (PARTITION BY year ORDER BY year, month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM t1;

-- Product Performance and YoY Analysis
WITH t1 AS (
  SELECT YEAR(order_date) AS year, category,p.product_name,
  SUM(sales_amount) AS total_sales FROM products p
  JOIN sales s ON p.product_key = s.product_key
  WHERE YEAR(order_date) IS NOT NULL
  GROUP BY YEAR(order_date), category, p.product_name
)
SELECT *,
AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS avg_diff,
CASE 
  WHEN total_sales > AVG(total_sales) OVER (PARTITION BY product_name) THEN 'Above_Average'
  WHEN total_sales < AVG(total_sales) OVER (PARTITION BY product_name) THEN 'Below_Average'
  ELSE 'Average'
END AS avg_change,
LAG(total_sales, 1) OVER (PARTITION BY product_name ORDER BY product_name) AS prev_year_sales,
total_sales - LAG(total_sales, 1) OVER (PARTITION BY product_name ORDER BY product_name) AS change_wrt_prev_year,
CASE 
  WHEN total_sales > LAG(total_sales, 1) OVER (PARTITION BY product_name ORDER BY product_name) THEN 'Increasing'
  WHEN total_sales < LAG(total_sales, 1) OVER (PARTITION BY product_name ORDER BY product_name) THEN 'Decreasing'
  ELSE 'No Change'
END AS change
FROM t1;

-- Part-to-Whole Sales by Category
WITH t1 AS (
  SELECT COALESCE(category, 'N/A') AS category,
  COALESCE(SUM(sales_amount), 0) AS total_sales FROM products p
  LEFT JOIN sales s ON p.product_key = s.product_key
  GROUP BY p.category
)
SELECT *,
SUM(total_sales) OVER () AS grand_sale,
(total_sales * 100.0) / SUM(total_sales) OVER () AS per_share
FROM t1;

-- Data Segmentation
-- Price Segmentation
WITH product_segments AS (
  SELECT product_key, product_name, cost,
  CASE 
    WHEN cost < 100 THEN 'Below 100'
    WHEN cost BETWEEN 100 AND 500 THEN '100-500'
    WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
    ELSE 'Above 1000'
  END AS cost_range
  FROM products
)
SELECT cost_range, COUNT(DISTINCT product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

-- Customer Segmentation
WITH customer_spending AS (
  SELECT c.customer_key,
  SUM(sales_amount) AS total_spend,
  DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
  FROM customers c
  LEFT JOIN sales s ON c.customer_key = s.customer_key
  GROUP BY c.customer_key
)
SELECT customer_category, COUNT(DISTINCT customer_key) AS total_customer FROM (
  SELECT *,
  CASE 
    WHEN lifespan >= 12 AND total_spend > 5000 THEN 'VIP'
    WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'Regular'
    ELSE 'New'
  END AS customer_category
  FROM customer_spending
) t1
GROUP BY customer_category;

/*
===============================================================================
Customer Analysis Report
===============================================================================
Purpose:
    - This report summarizes key customer metrics and behaviors

Highlights:
    1. Gathering essential fields such as names, ages, and transaction details.
	2. Segmenting customers into categories (VIP, Regular, New) and age groups.
    3. Aggregateing customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculating valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: report_customers
-- =============================================================================

-- =============================================================================
-- Create View: Customer_Report
-- =============================================================================
CREATE VIEW customer_report AS
WITH Root_Query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieving core columns from tables
    ---------------------------------------------------------------------------*/
    SELECT 
        c.customer_key,
        customer_number,
        CONCAT(first_name, ' ', last_name) AS Customer_Name,
        birthdate,
        DATEDIFF(YEAR, birthdate, GETDATE()) AS Age,
        order_number,
        product_key,
        order_date,
        sales_amount,
        quantity
    FROM customers c
    LEFT JOIN sales s ON c.customer_key = s.customer_key
    WHERE order_date IS NOT NULL
),

Customer_Aggregation AS (
    /*---------------------------------------------------------------------------
    2) Customer Aggregations: Summarizing key metrics at the customer level
    ---------------------------------------------------------------------------*/
    SELECT 
        customer_key,
        customer_number,
        Customer_Name,
        Age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity_purchased,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM Root_Query
    GROUP BY customer_key, customer_number, Customer_Name, Age
)

SELECT 
    customer_key,
    customer_number,
    Customer_Name,
    Age,
    total_orders,
    total_sales,
    total_quantity_purchased,
    total_products,
    lifespan,
    CASE 
        WHEN Age < 20 THEN 'Under 20'
        WHEN Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        ELSE 'Greater than 50'
    END AS Age_Group,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_category,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS time_since_last_order,
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders,2)
    END AS avg_order_value,
    CASE 
        WHEN lifespan = 0 THEN 0
        ELSE ROUND(total_sales / lifespan,2)
    END AS avg_monthly_spend
FROM Customer_Aggregation;

-- =============================================================================
-- Create View: Product_Report
-- =============================================================================
CREATE VIEW product_report AS
WITH Product_Base_Query AS (
    /*---------------------------------------------------------------------------
    1) Base Query: Retrieving core columns from fact_sales and dim_products
    ---------------------------------------------------------------------------*/
    SELECT 
        p.product_key,
        product_name,
        category,
        subcategory,
        cost,
        order_number,
        order_date,
        customer_key,
        sales_amount,
        quantity
    FROM products p
    LEFT JOIN sales s ON p.product_key = s.product_key
    WHERE order_date IS NOT NULL
),

Product_Aggregation AS (
    /*---------------------------------------------------------------------------
    2) Product Aggregations: Summarizing key metrics at the product level
    ---------------------------------------------------------------------------*/
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        MAX(order_date) AS last_sale_date,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT customer_key) AS total_customers,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
    FROM Product_Base_Query
    GROUP BY product_key, product_name, category, subcategory, cost
)

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders,2)
    END AS avg_order_revenue,
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan,2)
    END AS avg_monthly_revenue
FROM Product_Aggregation;













 
