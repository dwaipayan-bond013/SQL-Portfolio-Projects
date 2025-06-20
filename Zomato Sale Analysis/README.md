# 🍽️ Zomato Sales Analysis SQL Project

![alt text](zomato-sc-1.jpg)

## 📌 Overview
This SQL project explores the sales, delivery, and customer behavior data of  Zomato. It includes 20 advanced SQL queries to uncover performance drivers, customer segmentation, item trends, and operational insights.

---

## 🧩 Database Schema

- **Customer**: `CustomerID`, `Name`,`Email`,`Address`, `Age`, `Gender`  
- **Orders**: `OrderID`, `CustomerID`, `Restaurant_ID`, `Order_Date`, `Order_Time`, `Items`, `Total_Amount`, `Status`  
- **Deliveries**: `DeliveryID`, `OrderID`, `RiderID`, `Pickup_Time`, `Delivery_Time`, `Distance_covered`, `Tip`  
- **Restaurants**: `Restaurant_ID`, `DishName`, `Cuisine`, `Location`, `Rating`,`Contact`  
- **Riders**: `RiderID`, `Name`, `Vehicle`, `Rating`,`Phone`

---

## Entity Relationship Diagram (ERD)
The ERD for the analysis is present as follows

![alt text](ERD.PNG)

🔑 Primary Keys
- Customers: CustomerID

- Orders: `OrderID`

- Restaurants: `Restaurant_ID`

- Deliveries: `DeliveryID`

- Riders: `RiderID`

🔗 Foreign Keys

- Orders.`CustomerID` → Customers.`CustomerID`

- Orders.`Restaurant_ID` → Restaurants.`Restaurant_ID`

- Deliveries.`OrderID` → Orders.`OrderID`

- Deliveries.`RiderID`→ Riders.`RiderID`

## 📊 Analytical Insights & Recommendations

### 1. 🔝 Top 5 Dishes Ordered by a specific customer(eg. David Smith)

![Top 5 Dish](Top5Dish.PNG)

```sql
WITH top_5_food AS (
  SELECT o.Items, COUNT(o.Items) AS Number_of_orders,
         DENSE_RANK() OVER (ORDER BY COUNT(o.Items) DESC) AS rank
  FROM Customer c
  JOIN Orders o ON c.Customer_ID = o.Customer_ID
  WHERE c.Name = 'David Smith' AND o.Order_Date BETWEEN '2023-06-01' AND '2023-12-31'
  GROUP BY o.Items
)
SELECT Items, Number_of_orders FROM top_5_food WHERE rank <= 5;
```

👉 Based on customer segmentation and this result personalised recommendations can be generated along with other offers to increase CLV. For example here SInce Salad is the lowest order item, it can be recommended along with noodles targeting a healthy package of meal.

### 2. ⏰ Peak Order Timing
- Most orders placed between **10AM - 12PM**.

![alt text](MostPopularTimeSlot.PNG)

```sql
WITH popular_timeslot AS (
  SELECT Order_ID, Order_Time,
         CASE 
           WHEN DATEPART(hour, Order_Time) BETWEEN 0 AND 1 THEN '12AM - 2AM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 2 AND 3 THEN '2AM - 4AM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 4 AND 5 THEN '4AM - 6AM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 6 AND 7 THEN '6AM - 8AM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 8 AND 9 THEN '8AM - 10AM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 10 AND 11 THEN '10AM - 12PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 12 AND 13 THEN '12PM - 2PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 14 AND 15 THEN '2PM - 4PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 16 AND 17 THEN '4PM - 6PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 18 AND 19 THEN '6PM - 8PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 20 AND 21 THEN '8PM - 10PM'
           WHEN DATEPART(hour, Order_Time) BETWEEN 22 AND 23 THEN '10PM - 12AM'
         END AS Time_Interval
  FROM Orders
)
SELECT TOP 1 Time_Interval, COUNT(Order_ID) AS number_of_orders 
FROM popular_timeslot 
GROUP BY Time_Interval 
ORDER BY number_of_orders DESC;
```

📌 To increase the number of orders it is the ideal time to allocate more delivery staff and run promotions during this slot.

### 3. 💸 Average Order Value of Power Users (i.e. users who have ordered more than 400 times)

![](AvgOrderValuepercustomer.PNG)

```sql
SELECT Name, SUM(Total_Amount) / COUNT(Order_ID) AS avg_order_value 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name 
HAVING COUNT(Order_ID) > 400 
ORDER BY COUNT(Order_ID) DESC;
```

- High-frequency users (>400 orders) spend $50–$55 per order
- 🎯 Reward loyalty via exclusive discounts or early access to resaturants can be provide to encourage regualr orders.

### 4. 🎖️ High-Value Customers

![](HighvalueCustomers.PNG)

```sql
SELECT c.Customer_ID, Name, SUM(Total_Amount) AS Total_Amount 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY c.Customer_ID, Name 
HAVING SUM(Total_Amount) > 22000 
ORDER BY COUNT(Order_ID) DESC;
```
- Users with lifetime spend > $22,000 are considered as a high value customer
- 📦 Eligible for VIP tiers and cashback campaigns when launched

### 5. ⚠️ Undelivered Orders by Restaurant

![](Restaurentswithfailedorders.PNG)

```sql
SELECT Name, Location, COUNT(DISTINCT Order_ID) AS total_failed_orders 
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
WHERE Status = 'Not delivered' 
GROUP BY Name, Location 
ORDER BY total_failed_orders DESC;
```
🔧 Since the number of failed order is significantly more following steps can be taken to improve the process
- Need process audit or customer service intervention
- Proactively issue vouchers or refunds to affected customers
- If a restaurant fails repeatedly, delist it temporarily or permanently
- Incentivize Reliable Restaurants like “98% delivery success”

### 6. 🏆 Top 10 Revenue Restaurants

![](Top10revenuegeneratingrestaurants.PNG)

```sql
WITH top_restaurants AS (
  SELECT Name, Location, SUM(Total_Amount) AS total_revenue, 
         DENSE_RANK() OVER (ORDER BY SUM(Total_Amount) DESC) AS rank 
  FROM Restaurants r 
  LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
  GROUP BY Name, Location
)
SELECT Name, Location, total_revenue FROM top_restaurants WHERE rank <= 10;
```

💼 Business Insight: Strategy for Top 10 High-Revenue Restaurants
-  Feature these partners more prominently in app feeds
-  Highlight them in social media campaigns or city-based food trend articles
-  Launch co-branded campaigns, discount weeks, or food festivals

### 7. 🍟 Most Popular Items per Restaurant

Single most ordered dish per restaurant.
  
![](Resatuarantswiththeirpopularitems.PNG)

```sql
WITH most_popular_items AS (
  SELECT Name, Location, Items, COUNT(Items) AS number_of_orders,
         DENSE_RANK() OVER (PARTITION BY Name, Location ORDER BY COUNT(Items) DESC) AS rank
  FROM Restaurants r 
  LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
  GROUP BY Name, Location, Items
)
SELECT Name, Location, Items,number_of_orders FROM most_popular_items WHERE rank = 1;;
```

📌 Strategic Uses of Most Popular Items Per Restaurant Data:

- Highlight these items on Zomato's app and website with badges like "Most Popular" and run targeted promotions or discounts on these items to increase conversion
- Offer incentives for consistently popular dishes with good delivery ratings
- Understand dish popularity by area—tailor Zomato campaigns based on food preferences in each city or neighborhood
- Run localized ads featuring these popular dishes to increase order frequency from those restaurants

### 8. 📈 Customer Order Trend (Monthly)

- Monthly activity tracking.
  
![](CustomerMonthlyorderanalysis.PNG)

```sql
SELECT Name, MONTH(Order_Date) AS month, COUNT(DATEPART(month, Order_Date)) AS number_of_order 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name, MONTH(Order_Date) 
ORDER BY Name, month;
```

✅ Action Plan: Customers Order Analysis Per Month

- Spot trends in monthly order volumes per customer and boost sales during low-order months using personalized discounts or cashback for inactive users
- Detect customers with declining monthly activity and re-engage them through loyalty programs or reminders
- Identify customers who suddenly stop ordering in a given month and initiate retention campaigns or surveys
- Allocate marketing budget and timing based on user activity trends — more during high-engagement months, creative campaigns in low ones
  
### 9. 🔁 MoM Cancellation Trend

 Trend showing increase/decrease in non-delivered orders

 ![](MoMCancellationTrend.PNG)

 ```sql
SELECT Name, Location, MONTH(Order_Date) AS month, COUNT(DISTINCT Order_ID) AS total_failed_orders,
       LAG(COUNT(DISTINCT Order_ID), 1) OVER (PARTITION BY Name ORDER BY MONTH(Order_Date)) AS prev_month_order,
       CASE 
         WHEN COUNT(DISTINCT Order_ID) > LAG(COUNT(DISTINCT Order_ID), 1) OVER (PARTITION BY Name ORDER BY MONTH(Order_Date)) THEN 'Increase'
         WHEN COUNT(DISTINCT Order_ID) < LAG(COUNT(DISTINCT Order_ID), 1) OVER (PARTITION BY Name ORDER BY MONTH(Order_Date)) THEN 'Decrease'
         ELSE 'No Change' 
       END AS cancellation
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
WHERE Status = 'Not Delivered' 
GROUP BY Name, Location, MONTH(Order_Date) 
ORDER BY Name, month;
```

✅ Action Plan: MoM Cancellation Analysis of Restaurants

- Detect restaurants with consistently increasing cancellation trends by setting thresholds (e.g., 10% MoM increase) to trigger intervention
- Determine reasons for order cancellations: delivery delays, out-of-stock items, quality issues, etc
- For repeat offenders, introduce soft penalties like reduced visibility in search results or customer filters


### 10. 🚴‍♂️ Average Rider Delivery Time

![](AvgDeliveryTime.PNG)

 Riders' average time ranged from **~29–123 mins**.

```sql
SELECT r.Rider_ID, Name, AVG(ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME)))) AS avg_delivery_time 
FROM Riders r 
JOIN Deliveries d ON r.Rider_ID = d.Rider_ID 
GROUP BY r.Rider_ID, Name 
ORDER BY avg_delivery_time;
```

### 11. 📉 MoM Order Growth (Restaurant-Level)

![](Monthwiserestaurantgrowthratio.PNG)

```sql

SELECT Name, Location, MONTH(Order_Date) AS month, COUNT(DISTINCT Order_ID) AS total_delivered_orders,
       LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name ORDER BY MONTH(Order_Date)) AS prev_month_order,
       CASE 
         WHEN COUNT(DISTINCT Order_ID) > LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name ORDER BY MONTH(Order_Date)) THEN 'Increase'
         WHEN COUNT(DISTINCT Order_ID) < LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name ORDER BY MONTH(Order_Date)) THEN 'Decrease'
         ELSE 'No change' 
       END AS Succesful_Delivery,
(COUNT(DISTINCT Order_ID) - LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name,Location ORDER BY MONTH(Order_Date)))*1.0/LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name,Location ORDER BY MONTH(Order_Date)) Rate
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
WHERE Status = 'Delivered' 
GROUP BY Name, Location, MONTH(Order_Date) 
ORDER BY Name, month;
```

✅ Action Plan: Month-over-Month Order Growth Analysis

- Spot restaurants with consistent MoM growth 📈 in delivered orders and feature them in “Top Trending” or “Most Reliable” sections of the app
- Flag restaurants with decreasing order growth and  help them optimize menus, pricing, and packaging
- Correlate growth trends with customer retention and repeat ordering metrics and suggest loyalty programs for restaurants with stable growth

### 12. 🧱 Customer Segmentation: Gold vs. Silver

![](CustomerSegmentation.PNG)

```sql
WITH customer_details AS (
  SELECT c.Customer_ID, Name, AVG(Total_Amount) AS avg_customer_spend, avg_revenue 
  FROM Customer c 
  LEFT JOIN (
    SELECT *, AVG(Total_Amount) OVER(ORDER BY (SELECT NULL)) AS avg_revenue FROM Orders
  ) o ON c.Customer_ID = o.Customer_ID 
  GROUP BY c.Customer_ID, Name, avg_revenue
),
customer_segments AS (
  SELECT Customer_ID, Name,
         CASE WHEN avg_customer_spend > avg_revenue THEN 'Gold' ELSE 'Silver' END AS customer_category 
  FROM customer_details
)
SELECT customer_category, COUNT(DISTINCT Order_ID) AS total_orders, SUM(Total_Amount) AS total_revenue 
FROM customer_segments cs 
JOIN Orders o ON cs.Customer_ID = o.Customer_ID 
GROUP BY customer_category;
```

✅ Action Plan: Customer Segmentation – Gold vs Silver

- For **GOLD** customers we can provide exclusive deals, loyalty bonuses, or early access to new features or restaurants and offer priority customer support or VIP delivery service
- Launch a Gold Membership Program for recurring benefits (free delivery, discounts) which personalizes offers based on their favorite cuisine or restaurants if the number of customers having gold membership decreases
- Target Silver customers withIncentives for increased spending (e.g., spend $50 more to get Gold)
- Invest more in retaining Gold customers and use cost-effective campaigns for Silver users until they move up tiers


### 13. 💵 Rider Earnings
- Formula: `8% of Order Value + Tip`.
- 🧮 Helps HR/Finance departments track income distribution.

### 14. ⭐ Rider Rating Simulation
- Based on delivery duration:
  - `<30min`: 5⭐, `30–40`: 4⭐, `>60`: 1⭐, etc.
- 🧭 Performance benchmark metric.

### 15. 🗓️ Restaurant Busiest Day
- Found most popular day of the week per restaurant.
- 👷 Helps schedule staffing accordingly.

### 16. 💰 Customer Lifetime Value
- Aggregated total revenue per customer.
- 🎯 Ideal for CLV-based marketing targeting.

### 17. 📅 Sales Trends Over Months
- Month-over-month revenue trend and percentage change.
- 📊 Use for financial forecasting and budget allocation.

### 18. 🏎️ Fastest vs. Slowest Riders
- Based on avg. delivery time.
- 📌 Can be tied to incentives or mentorship.

### 19. 🌦️ Seasonal Item Popularity
- Mapped dish orders across Spring, Summer, Rainy, Winter.
- 🌸 Helps in launching seasonal combos.

### 20. 📈 Restaurant Growth Ratio (MoM)
- Tracked order count growth ratio using `LAG()`.
- 🧩 Used to detect momentum and trigger intervention.

---

## 🛠️ SQL Techniques Used

- **Window Functions**: `LAG()`, `DENSE_RANK()`, `AVG()`, etc.
- **Joins**: `INNER`, `LEFT JOIN` across 5+ tables
- **Aggregates**: `SUM()`, `COUNT()`, `DATEDIFF()`
- **Case Logic**: `CASE WHEN` used for dynamic labels and segmentation
- **Time Functions**: `DATEPART`, `DATENAME`, `MONTH()`, `CAST()`

---

## 🧪 Sample Use Cases

- Build customer loyalty engine based on lifetime value and segmentation.
- Create operational dashboard for rider performance and restaurant delivery failures.
- Recommend promotions by season, time slot, or trending dishes.
- Highlight high-performing restaurants and customers for sales/marketing.

---

## 📁 Folder Structure


