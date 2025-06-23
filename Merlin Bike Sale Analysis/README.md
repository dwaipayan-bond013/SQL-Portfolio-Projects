# 🚴‍♂️ Merlin Bike Sales Analysis
<p align="center">
  <img src="135185_.jpg" width="1000px">
</p>

## 📊 Overview
This project involves an in-depth analysis of Merlin's bike sales data over a span of 4 years. The goal is to uncover actionable insights around product performance, customer segmentation, regional trends, and revenue distribution to help drive better decision-making across marketing, sales, and inventory.

## 🧱 Database Schema
Tables and Columns Used:

- Customers 💲: 
`customer_key`, `customer_id`, `customer_number`, `first_name`, `last_name`, `country`, `marital_status`, `gender`, `birthdate`, `create_date`
- Products 🚴‍♂️:
`product_key`, `product_id`, `product_number`, `product_name`, `category_id`, `category`, `subcategory`, `maintenance`, `cost`, `product_line`, `start_date`
- Sales 📈:
`order_number`, `product_key`, `customer_key`, `order_date`, `shipping_date`, `due_date`, `sales_amount`, `quantity`, `price`

## Entity Relationship Diagram (ERD)
![](ERD.PNG)

🔑 Primary Keys
- Customers
   - `customer_key`: Serves as the primary key. It uniquely identifies each customer
- Products
   - `product_key`: Serves as the primary key. It uniquely identifies each product
- Sales
   - `order_number`: Serves as the primary key. It uniquely identifies each sales transaction

🔗 Foreign Keys
- Sales
   - `customer_key`: Foreign key referencing customer_key in the Customers table. This links each sale to a specific customer
   - `product_key`: Foreign key referencing product_key in the Products table. This links each sale to a specific product

## 📊 Key Analysis Areas
- Customer Lifetime Value (CLTV): Identify customers who contribute the most to revenue
- Product Profitability: Compare product costs vs. sales to identify high-margin items
- Sales Trends: Analyze sales by date, product, region, and category
- Customer Segmentation: Group customers by demographics and purchasing behavior
- Order Fulfillment: Track shipping and due dates for delay analysis
- Market Expansion Opportunities: Discover underperforming countries or categories

## 📈 Insights and Recommendations

1. KPI Reporting
   
    ![](KPI.PNG)

   ```sql
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
   ```

  - 📊 Business Insights from KPIs
    
    - 💰 Total Sales: $29,356,250
      - This indicates strong revenue performance, reflecting the effectiveness of the sales team and marketing strategies.
      - It provides a solid financial base for reinvestment in operations, marketing, or customer retention programs.

    - 📦 Total Items Sold: 60,423
      - A high number of units sold suggests good product-market fit and customer demand.
      - Inventory and supply chain teams should ensure stock levels are sufficient to meet continued demand.

    - 💲 Average Selling Price: $486.04
      - The average price point is relatively premium, hinting at a value-driven or high-quality brand positioning.
      - Bundling, upselling, or loyalty discounts could be explored without harming profitability too much.

    - 🧾 Total Orders: 27,659
      - A healthy number of transactions, indicating consistent customer engagement.
      - Analyzing order frequency per customer can identify potential for subscription models or repeat purchase incentives.

    - 🛒 Total Products: 295
      - A fairly broad product catalog provides opportunities for cross-selling and bundling strategies.
      - Consider reviewing low-selling items for removal or optimization.

    - 👥 Total Customers: 18,484
      - A large customer base offers strong potential for segmentation, targeting, and personalized marketing.
      - Focus on improving customer lifetime value and churn reduction.

    - 📈 Customers with Orders: 18,484
      - This matches the total customers, meaning every customer has made at least one purchase — a 100% conversion rate
      - This is an exceptional indicator of marketing and product effectiveness; however, further analysis should check for repeat purchases and retention

2. Country wise customer distribution

   ![](Countrywisecustomer.PNG)

   ```sql
   SELECT country, COUNT(customer_key) AS total_customer FROM customers
   GROUP BY country ORDER BY total_customer DESC;
   ```

   💡 Insights:
   - The United States has the largest customer base (7,482 customers), accounting for ~40% of total customers
   - Australia and the United Kingdom follow with 3,591 and 1,913 customers respectively
   - Countries like France, Germany, and Canada have roughly similar customer numbers, all around 1,500–1,800
   - There are 337 customers with unclassified or missing country data (n/a), which may need data cleaning

   📌 Business Strategy:
   - Focus marketing and logistics optimization primarily in the US, as it holds the majority share
   - Consider expanding customer engagement efforts in Australia and the UK—high potential for revenue growth
   - Clean and validate customer data to minimize n/a entries for better geographic segmentation

3. Revenue by product category

   ![](Revenuepercategory.PNG)

   ```sql
   SELECT category, FORMAT(SUM(sales_amount),'N0') AS total_revenue FROM products p
   LEFT JOIN sales s ON p.product_key = s.product_key
   GROUP BY category HAVING SUM(sales_amount) IS NOT NULL
   ORDER BY total_revenue DESC;
   ```

   💡 Insights:
   - Bikes dominate the revenue stream with $28.3M, making up ~96% of total revenue.
   - Accessories generate $700K, and Clothing brings in $340K, which are marginal compared to Bikes.

   📌 Business Strategy:
   - Bikes are the main revenue geneartors —continue investing in their marketing, innovation, and upselling
   - Accessories and Clothing are underperforming. Either reposition these items as essential add-ons for bikes or consider bundling them for cross-sell opportunities
   - Reevaluate pricing, visibility, or product relevance in Accessories and Clothing categories

4. Revenue per customer

   ![](Customerwiserevenue.PNG)

   ```sql
   SELECT c.customer_key, CONCAT(first_name, ' ', last_name) AS full_name,
   SUM(sales_amount) AS total_revenue FROM customers c
   LEFT JOIN sales s ON c.customer_key = s.customer_key
   GROUP BY c.customer_key, first_name, last_name
   ORDER BY total_revenue DESC;
   ```

  💡 Insights:
   - The top 17 customers each contributed over $10K in revenue
   - Kaitlyn Henderson, Nichole Nara, and Margaret He are the top 3 high-value customers with revenue around $13.2K+
   - There’s a tight cluster in the $12K–$13.2K range, indicating consistent purchase patterns among the top-tier customers

  📌 Business Strategy:
   - Group customers into Gold, Silver and Bronze category based on revenue and offer facilities like early acceess, discounts, gifts etc to prevent customer churn
   - Consider personalized engagement strategies (email campaigns, early access) to increase customer lifetime value
     
5. Distribution of items sold by country

   ![](Countrywisequantitysold.PNG)

   ```sql
   SELECT c.country, FORMAT(SUM(quantity),'N0') AS total_quantity_sold FROM customers c
   LEFT JOIN sales s ON c.customer_key = s.customer_key
   GROUP BY c.country ORDER BY total_quantity_sold DESC;
   ```

   💡 Insights:
   - United States (20,481 units) and Australia (13,346 units) lead in terms of quantity sold, indicating high market penetration
   - Countries like Germany (5,626) and France (5,559) have similar performance, presenting potential for regional marketing expansion
   - The ‘n/a’ country (871 units) points to possible data quality issues—data cleansing is needed for more accurate geographical insights

   📌 Business Strategy:
   - With over 20K+ units sold, the U.S. is the strongest market. Increase in inventory allocation, ad spend, and local partnerships in the U.S. will maintain dominance
   - Strong sales in Australia (13K+) indicate growth potential. Launching regional promotions or seasonal discounts might convert Australia into a high-revenue market like the U.S
   - Countries like Germany, France, and the UK show moderate sales. Using targeted marketing campaigns (localized ads, shipping discounts) might drive sales up by 10–15%

6. Top 5 revenue products

   ![](Top5revenueproducts.PNG)

  ```sql
  SELECT TOP 5 p.product_name, FORMAT(SUM(sales_amount),'N0') AS total_revenue FROM products p
  LEFT JOIN sales s ON p.product_key = s.product_key
  GROUP BY p.product_name ORDER BY total_revenue DESC;
  ```

 🔎 Insights:
  - High-end mountain and touring bikes dominate the revenue chart 
  - Bike accessories (like helmets and tires) also appear, suggesting cross-selling opportunities with premium bike sales

 📌 Business Strategy:
  - Top revenue comes from Mountain-400-W and Touring bikes. Prioritize these products in marketing, ensure high inventory, and consider new variants based on customer feedback
  - Cross-sell accessories: Helmets and tire tubes appear among high earner. Use bundling strategies (e.g., "Buy a bike, get 20% off a helmet") to boost AOV (average order value)

7. Bottom 5 revenue products

   ![](Bottom5revenueproducts.PNG)

   ```sql
   SELECT TOP 5 p.product_name, SUM(sales_amount) AS total_revenue FROM products p
   LEFT JOIN sales s ON p.product_key = s.product_key
   GROUP BY p.product_name HAVING SUM(sales_amount) IS NOT NULL
   ORDER BY total_revenue;
   ```

   🔎 Insights:
   - Low-cost accessory products naturally generate less revenue
   - These items could be used for bundling, promotions, or loyalty programs to drive customer retention and increase cart value
   - Consider inventory optimization to reduce overstocking of such low-performing SKUs

   📌 Business Strategy:
   - Items like Racing Socks and Patch Kits bring low revenue. Bundling them with premium products will lead to more sale
   - Run clearance sales.
   - Offer as freebies in loyalty programs or minimum cart values
     
8. 📊 Monthly Sales Trend

   ![](MonthlySalescustomersquantity.PNG)

  ```sql
  SELECT FORMAT(order_date, 'yyyy-MMM') AS order_date,
  SUM(sales_amount) AS total_sales,
  COUNT(DISTINCT customer_key) AS total_customers,
  SUM(quantity) AS total_quantity
  FROM sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY FORMAT(order_date, 'yyyy-MMM')
  ORDER BY FORMAT(order_date, 'yyyy-MMM');
 ```

  🔎 Insights: 
  - Steady Growth: From Dec 2010 ($43K) to Dec 2012 ($24K), sales have grown over 13x—showing a solid upward trend in business performance.
  - Customer Base Expansion: Customer count increased from just 14 in Dec 2010 to 354 by Dec 2012, indicating strong market acquisition.
  - Healthy Conversion: The total quantity ordered seems to scale linearly with customer count, suggesting that new customers are actively purchasing.
  - Key Spikes: Major jumps were seen in:
       - Aug 2011 ($614K): Likely a seasonal or promotional period
       - Dec 2011 ($669K): Year-end sales boost
       - Dec 2012 ($624K): Another strong December, signaling a recurring pattern in high year-end sales

  📌 Business Strategy:
 - Launch major seasonal campaigns or limited-time offers during the peak months.Introducing exclusive product launches in these peak months
 - April 2012 (₹400K) and March 2012 (₹374K) showed noticeable dips. Use of targeted discounts, email nudges, or flash sales in low-performing months can improve the situation
 - Implement referral programs to accelerate word-of-mouth and promote retargeting ads during high-traffic months to increase conversion

9. 📈 Cummulative Sales Trend

    ![](Cummulativesales.PNG)

 ```sql
 WITH t1 AS (
 SELECT YEAR(order_date) AS year, MONTH(order_date) AS month,
 SUM(sales_amount) AS total_sales FROM sales
 WHERE MONTH(order_date) IS NOT NULL
 GROUP BY YEAR(order_date), MONTH(order_date)
 )
 SELECT *, SUM(total_sales) OVER (PARTITION BY year ORDER BY year, month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
 FROM t1;
```

🔎 Insights: 
- Consistent Uptrend: From $43K in Dec 2010 to over $1.77M by Apr 2012, cumulative sales show a clear upward growth, suggesting strong product-market fit
- Acceleration Mid-2011: Sales began compounding significantly from Apr–Jul 2011, indicating possible successful marketing efforts or product upgrades
- Sustained Momentum in 2012: Despite a dip in March 2012, Apr 2012 sales rebounded—showing resilience in customer demand
- Cumulative sales rose from ₹43K in Dec 2010 to ₹1.77M in Apr 2012, reflecting a strong growth trajectory
- The pace of cumulative sales growth slightly flattens in early 2012

📌 Business Strategy: 
- Scale winning strategies (ads, products, offers) that fueled the growth between 2010-12 by implementing automated marketing pipelines to support sustained demand generation
- Introducing  new product lines or categories to re-spark growth early 2012 may improve the sale
- Test new customer acquisition channels (influencer marketing, partnerships)

10. 🧩 Product performance and YoY analysis

    ![](ProductperformanceYoYanalysis.PNG)

```sql
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
```

🔎 Insights: 
- Bikes: Show both high-volume and high-variance sales
   - Mountain-100 and Mountain-200 variants consistently deliver large sales
   - Strong positive YoY growth in key models like Mountain-200 Black, 42 (+₹602K)
- Accessories: Mixed performance
   - All-Purpose Bike Stand and Fender Set – Mountain show strong upward trends
   - Mountain Tire Tube and Bike Wash – Dissolver show YoY decline in later years
- Clothing: Struggles persist
   - Most clothing items (e.g., Classic Vest-L, S, M) are marked “Below_Average” with negative YoY change

📈 Product-Level Performance
- Top Performers:
  - Mountain-200 Black, 42: $945,540 in sales (+$602,619 YoY) → best overall performer
  - Mountain-100 Black, 42: $202,500 — steady high performer
  - Fender Set – Mountain: grew from 110 to 44,484 — excellent YoY surge
- Underperformers:
  - Classic Vest-L, M, S: Showing multi-year decline and “Below_Average” performance
  - Bike Wash – Dissolver and Mountain Tire Tube showed negative YoY growth
  - Mountain-100 Silver, 38–44: No change or decline — stagnant products

📌 Business Strategy: 
- Increase production and regional availability of models like Mountain-200 Black, 42 and Mountain-100 Black, 42 show excellent traction
  - Consider launching new variants or premium versions of these bikes
- Most clothing SKUs are underperforming (declining YoY, marked as “Below_Average”)
- Conduct customer surveys to identify why clothing isn't converting (fit, style, pricing?)
  - Bundle underperforming clothing with top accessories or bikes to move stock
  - Consider seasonal or limited collections to reignite interest
- Strong performers: Fender Set – Mountain, All-Purpose Bike Stand
- Weak performers: Mountain Tire Tube (decline in 2014), Bike Wash – Dissolver
  - Prioritize marketing and bundling high-performing accessories
  - Evaluate utility and quality of low-performers; consider discontinuation or redesign
    


