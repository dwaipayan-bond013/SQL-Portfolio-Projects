use Zomato_Sale_Analysis;

select * from Customer
select * from Deliveries
select * from Orders
select * from Restaurants
select * from Riders;

-- Creating Index to speed up the process of joins and grouping
CREATE INDEX idx_orders_customer_id ON Orders(Customer_ID);
CREATE INDEX idx_customer_id_name ON Customer(Customer_ID, Name);
CREATE INDEX idx_orders_order_id ON Orders(Order_ID);


--1) What are teh top 5 dishes for customer David Smith'
WITH top_5_food AS (
  SELECT o.Items, COUNT(o.Items) AS Number_of_orders,
         DENSE_RANK() OVER (ORDER BY COUNT(o.Items) DESC) AS rank
  FROM Customer c
  JOIN Orders o ON c.Customer_ID = o.Customer_ID
  WHERE c.Name = 'David Smith' AND o.Order_Date BETWEEN '2023-06-01' AND '2023-12-31'
  GROUP BY o.Items
)
SELECT Items, Number_of_orders FROM top_5_food WHERE rank <= 5;


--2) Most popular time slots
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


--3) Average order value per customer who have ordered more than 400 times
SELECT Name, SUM(Total_Amount) / COUNT(Order_ID) AS avg_order_value 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name 
HAVING COUNT(Order_ID) > 400 
ORDER BY COUNT(Order_ID) DESC;


--4) High value Customers
SELECT c.Customer_ID, Name, SUM(Total_Amount) AS Total_Amount 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY c.Customer_ID, Name 
HAVING SUM(Total_Amount) > 22000 
ORDER BY COUNT(Order_ID) DESC;


--5) Restuarents with Orders Placed but not delivered
SELECT Name, Location, COUNT(DISTINCT Order_ID) AS total_failed_orders 
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
WHERE Status = 'Not delivered' 
GROUP BY Name, Location 
ORDER BY total_failed_orders DESC;


--6) Top 10 restaurants based on revenue

WITH top_restaurants AS (
  SELECT Name, Location, SUM(Total_Amount) AS total_revenue, 
         DENSE_RANK() OVER (ORDER BY SUM(Total_Amount) DESC) AS rank 
  FROM Restaurants r 
  LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
  GROUP BY Name, Location
)
SELECT Name, Location,total_revenue FROM top_restaurants WHERE rank <= 10;


--7) Most popular Items in each restaurent
WITH most_popular_items AS (
  SELECT Name, Location, Items, COUNT(Items) AS number_of_orders,
         DENSE_RANK() OVER (PARTITION BY Name, Location ORDER BY COUNT(Items) DESC) AS rank
  FROM Restaurants r 
  LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
  GROUP BY Name, Location, Items
)
SELECT Name, Location, Items,number_of_orders FROM most_popular_items WHERE rank = 1;

-- 8) Customers Order Analysis per month
SELECT Name, MONTH(Order_Date) AS month, COUNT(DATEPART(month, Order_Date)) AS number_of_order 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name, MONTH(Order_Date) 
ORDER BY Name, month;

-- 9) MoM cancellation analysis of restaurant
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


-- 10) Delivery Partners average delivery time
SELECT r.Rider_ID, Name, AVG(ABS(DATEDIFF(MINUTE, CAST(Pickup_time AS TIME), CAST(Delivery_Time AS TIME)))) AS avg_delivery_time 
FROM Riders r 
JOIN Deliveries d ON r.Rider_ID = d.Rider_ID 
GROUP BY r.Rider_ID, Name 
ORDER BY avg_delivery_time;

-- 11) MoM order growth per restaurant per month
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

-- 12) Customer Segmentation
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

-- 13) Riders Monthly earnings
SELECT r.Rider_ID, Name, MONTH(Order_Date) AS month, SUM((Total_Amount * 0.08) + Tip) AS Earnings 
FROM Riders r 
LEFT JOIN Deliveries d ON r.Rider_ID = d.Rider_ID 
LEFT JOIN Orders o ON d.Order_ID = o.Order_ID 
GROUP BY r.Rider_ID, Name, MONTH(Order_Date) 
ORDER BY r.Rider_ID, Name, MONTH(Order_Date);

-- 14) Rider ratings analysis
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

-- 15) Order frequency per day per restaurant
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

-- 16) Customer lifetime value
SELECT Name, SUM(Total_Amount) AS total_revenue 
FROM Customer c 
LEFT JOIN Orders o ON c.Customer_ID = o.Customer_ID 
GROUP BY Name 
ORDER BY total_revenue DESC;

-- 17) Monthly trend of sales

SELECT DATENAME(month,Order_Date) AS month, SUM(Total_Amount) AS total_sale,
  LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date)) AS prev_month_sale,
  (SUM(Total_Amount) - LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date))) * 100.0 / LAG(SUM(Total_Amount), 1) OVER(ORDER BY MONTH(Order_Date)) AS percent_change
  FROM Orders 
GROUP BY DATENAME(month,Order_Date),MONTH(Order_Date)

-- 18) Rider Efficiency
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


-- 19) Order Item Popularity
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

-- 20) Monthly Restaurant Growth rate
SELECT Name, Location, MONTH(Order_Date) AS month,
       COUNT(DISTINCT Order_ID) * 1.0 / LAG(COUNT(DISTINCT Order_ID), 1) OVER(PARTITION BY Name, Location ORDER BY MONTH(Order_Date)) AS growth_ratio 
FROM Restaurants r 
LEFT JOIN Orders o ON r.Restaurant_ID = o.Restaurant_ID 
GROUP BY Name, Location, MONTH(Order_Date);






