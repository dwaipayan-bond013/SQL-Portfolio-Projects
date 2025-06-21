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

![](RestaurantWisemonthlyGrowth.PNG)

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

 Formula: `8% of Order Value + Tip`.

![](RiderMonthlyearnings.PNG)

```sql
SELECT r.Rider_ID, Name, MONTH(Order_Date) AS month, SUM((Total_Amount * 0.08) + Tip) AS Earnings 
FROM Riders r 
LEFT JOIN Deliveries d ON r.Rider_ID = d.Rider_ID 
LEFT JOIN Orders o ON d.Order_ID = o.Order_ID 
GROUP BY r.Rider_ID, Name, MONTH(Order_Date) 
ORDER BY r.Rider_ID, Name, MONTH(Order_Date);
```

✅ Action Plan: Rider Monthly Earnings

- Use earnings data to design tiered bonuses or incentives (e.g., “Top 10% earners get a $20 bonus”)
- Ensure competitive earnings across months to prevent attrition. Recognize and reward long-term high performers with loyalty bonuses.
- Helps HR/Finance departments track income distribution.

### 14. ⭐ Rider Rating Simulation
- Based on delivery duration:
  - `<30min`: 5⭐, `30–40`: 4⭐, `41-50`: 3⭐, `51-60`: 2⭐, `>60`: 1⭐, etc.

![](RiderRatingAnalysis.PNG)

``` sql
WITH ratings AS (
  SELECT r.Rider_ID, Name,
         CASE 
           WHEN ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME))) < 30 THEN '5 star'
           WHEN ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME))) BETWEEN 30 AND 40 THEN '4 star'
           WHEN ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME))) BETWEEN 41 AND 50 THEN '3 star'
           WHEN ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME))) BETWEEN 51 AND 60 THEN '2 star'
           ELSE '1 star' 
         END AS Rating 
  FROM Riders r 
  LEFT JOIN Deliveries d ON r.Rider_ID = d.Rider_ID 
  LEFT JOIN Orders o ON d.Order_ID = o.Order_ID 
  WHERE Status = 'Delivered'
)
SELECT Rider_ID, Name, Rating, COUNT(Rating) AS count 
FROM ratings 
GROUP BY Rider_ID, Name, Rating 
ORDER BY Rider_ID, Name;
```

✅ Action Plan: Rider Ratings Analysis
- Offer performance bonuses or incentives for riders consistently rated ⭐⭐⭐⭐ and above
- Identify riders frequently rated below 3 stars and provide targeted feedback and soft-skills training (punctuality, communication, handling orders, etc.)
- Introduce a public-facing badge (e.g., “Top Rated Rider 🚴‍♂️”) visible to customers during live tracking
 

### 15. 🗓️ Restaurant Busiest Day

![](BusiestDayPerRestaurant.PNG)

```sql
WITH order_frequency AS (
  SELECT Name, Location, DATENAME(dw, Order_Date) AS Dayname, COUNT(DISTINCT Order_ID) AS total_orders,
         DENSE_RANK() OVER(PARTITION BY Name, Location ORDER BY COUNT(DISTINCT Order_ID) DESC) AS rank 
  FROM Restaurants r 
  JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
  GROUP BY Name, Location, DATENAME(dw, Order_Date)
)
SELECT Name, Location, total_orders,Dayname 
FROM order_frequency 
WHERE rank = 1;
```

✅ Action Plan: Using Busiest Day Data per Restaurant

- Assign more delivery partners to restaurants on their busiest days by using historical peak-day trends to pre-position riders near high-demand zones
- Run day-specific promotions (e.g., “Wednesday Feast Offers”) for each restaurant to boost already strong performance
- If peak days result in operational strain, throttle new orders temporarily or implement surge pricing during peak hours to manage demand

### 16. 💰 Customer Lifetime Value

![](LifetimeValue.PNG)

```sql
SELECT Name, SUM(Total_Amount) AS total_revenue 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name 
ORDER BY total_revenue DESC;
```

📌 Strategic Actions to Take:

- Identify top spenders and offer them exclusive benefits (e.g., premium support, early access to deals)
- Use CLV to segment users (e.g., high CLV = target with luxury food, low CLV = promote budget-friendly deals)
- Provide AI-driven suggestions based on high CLV users’ past purchases (e.g., cuisine preferences, restaurants, price range)
- If a high CLV customer becomes inactive, trigger win-back campaigns (discount codes, re-engagement offers)

### 17. 📅 Sales Trends Over Months

![](MonthlyTrendofSales.PNG)

```sql
SELECT DATENAME(month, Order_Date) AS month, SUM(Total_Amount) AS total_sale,
  LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date)) AS prev_month_sale,
  (SUM(Total_Amount) - LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date))) * 100.0 / 
   LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date)) AS percent_change
FROM Orders 
GROUP BY DATENAME(month, Order_Date), MONTH(Order_Date);
```

📌 Strategic Actions to Take:

- Identify High-Performing months and boost campaigns during those months in the following year to maximize sales
- Investigate reasons behind MoM drops (e.g., service issues, holidays, market competition)
- Run targeted retention offers or restaurant audits for underperforming months
- Allocate ad budgets based on seasonal sales trends (e.g., more spend in months with proven growth)
- Use growth percentage data to set data-driven targets for internal teams and restaurant partners.

### 18. 🏎️ Fastest vs. Slowest Riders

Based on avg. delivery time

![](EfficientandNonEfficientdriver.PNG)

```sql
WITH rider_efficiency AS (
  SELECT 
    Name,
    AVG(ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME)))) AS avg_delivery_time,
    DENSE_RANK() OVER (ORDER BY AVG(ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME))))) AS rnk
  FROM Riders r
  LEFT JOIN Deliveries d ON r.Rider_ID = d.Rider_ID
  GROUP BY Name
),
rank_bounds AS (
  SELECT 
    MIN(rnk) AS min_rank,
    MAX(rnk) AS max_rank
  FROM rider_efficiency
)
SELECT
  MIN(CASE WHEN re.rnk = rb.min_rank THEN re.Name END) AS Fastest_Rider,
  MIN(CASE WHEN re.rnk = rb.max_rank THEN re.Name END) AS Slowest_Rider
FROM rider_efficiency re
CROSS JOIN rank_bounds rb;
```

### 19. 🌦️ Seasonal Item Popularity

Mapped dish orders across Spring, Summer, Rainy, Winter

![](Seasonwiseorderitempopularity.PNG)

```sql
WITH seasons AS (
  SELECT MONTH(Order_Date) AS month, Order_ID, Items,
         CASE 
           WHEN MONTH(Order_Date) BETWEEN 2 AND 3 THEN 'Spring'
           WHEN MONTH(Order_Date) BETWEEN 4 AND 6 THEN 'Summer'
           WHEN MONTH(Order_Date) BETWEEN 7 AND 9 THEN 'Rainy'
           ELSE 'Winter' 
         END AS seasons 
  FROM Orders
)
SELECT Items, seasons, COUNT(DISTINCT Order_ID) AS count 
FROM seasons 
GROUP BY Items, seasons 
ORDER BY Items, count DESC;
```

📌 Strategic Actions to Take:

- Highlight top seasonal items in the app UI during their peak months and promote season-exclusive dishes that align with customer preferences
- Run seasonal discounts and combo offers on high-demand items
- Push notifications and emails can advertise top items each season
- Recommend popular seasonal items in the “Suggested for You” or “Trending Now” sections
- Allow users to filter by “Winter Favorites”, “Rainy Specials”, etc., improving their browsing and purchase experience
- Use seasonal trends to develop or test new dishes aligned with popular tastes in that time frame
- Leverage seasonal data in sync with regional festivals or events for better cultural targeting and engagement

### 20. 📈 Restaurant Growth Ratio (MoM)

![](Monthwiserestaurantgrowthratio.PNG)

```sql
SELECT Name, Location, MONTH(Order_Date) AS month,
       COUNT(DISTINCT Order_ID) * 1.0 / 
       LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name, Location ORDER BY MONTH(Order_Date)) AS growth_ratio 
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
GROUP BY Name, Location, MONTH(Order_Date);
```

📌 Strategic Actions to Take:

- Identify restaurants consistently showing positive growth and consider featuring them on the home page or in top recommendations.
- Optimize Promotions by allocating marketing budget based on growth trends—boost ads for fast-growing restaurants and consider retention strategies for declining ones
-  Can use this data to predict Zomato's platform-wide growth and estimate revenue contribution from various restaurant tiers.
- Integrate MoM growth into the internal restaurant ranking algorithm to surface more dynamic and active restaurants to users.
- Tracked order count growth ratio using `LAG()`.

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


