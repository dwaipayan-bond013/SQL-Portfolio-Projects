-- Preparing the data

DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    id     INT PRIMARY KEY,
    name   VARCHAR(30),
    email  VARCHAR(50)
);

DROP TABLE IF EXISTS bike;
CREATE TABLE bike (
    id              INT PRIMARY KEY,
    model           VARCHAR(50),
    category        VARCHAR(50),
    price_per_hour  DECIMAL,
    price_per_day   DECIMAL,
    status          VARCHAR(20)
);

DROP TABLE IF EXISTS rental;
CREATE TABLE rental (
    id              INT PRIMARY KEY,
    customer_id     INT REFERENCES customer(id),
    bike_id         INT REFERENCES bike(id),
    start_timestamp DATETIME,
    duration        INT,
    total_paid      DECIMAL
);

DROP TABLE IF EXISTS membership_type;
CREATE TABLE membership_type (
    id          INT PRIMARY KEY,
    name        VARCHAR(50),
    description VARCHAR(500),
    price       DECIMAL
);

DROP TABLE IF EXISTS membership;
CREATE TABLE membership (
    id                 INT PRIMARY KEY,
    membership_type_id INT REFERENCES membership_type(id),
    customer_id        INT REFERENCES customer(id),
    start_date         DATE,
    end_date           DATE,
    total_paid         DECIMAL
);

INSERT INTO customer VALUES
(1, 'John Doe', 'john.doe@example.com'),
(2, 'Alice Smith', 'alice.smith@example.com'),
(3, 'Bob Johnson', 'bob.johnson@example.com'),
(4, 'Eva Brown', 'eva.brown@example.com'),
(5, 'Michael Lee', 'michael.lee@example.com'),
(6, 'Sarah White', 'sarah.white@example.com'),
(7, 'David Wilson', 'david.wilson@example.com'),
(8, 'Emily Davis', 'emily.davis@example.com'),
(9, 'Daniel Miller', 'daniel.miller@example.com'),
(10, 'Olivia Taylor', 'olivia.taylor@example.com');

INSERT INTO bike VALUES
(1, 'Mountain Bike 1',  'mountain bike', 10.00, 50.00, 'available'),
(2, 'Road Bike 1',      'road bike',     12.00, 60.00, 'available'),
(3, 'Hybrid Bike 1',    'hybrid',         8.00, 40.00, 'rented'),
(4, 'Electric Bike 1',  'electric',      15.00, 75.00, 'available'),
(5, 'Mountain Bike 2',  'mountain bike', 10.00, 50.00, 'out of service'),
(6, 'Road Bike 2',      'road bike',     12.00, 60.00, 'available'),
(7, 'Hybrid Bike 2',    'hybrid',         8.00, 40.00, 'out of service'),
(8, 'Electric Bike 2',  'electric',      15.00, 75.00, 'available'),
(9, 'Mountain Bike 3',  'mountain bike', 10.00, 50.00, 'rented'),
(10,'Road Bike 3',      'road bike',     12.00, 60.00, 'available');

INSERT INTO rental VALUES
(1,1,1,'2022-11-01 10:00:00',240,50.00), (2,1,1,'2022-11-02 10:00:00',245,50.00),
(3,1,1,'2022-11-03 10:00:00',250,50.00), (4,1,1,'2022-11-04 10:00:00',235,50.00),
(5,1,1,'2022-12-05 10:00:00',155,50.00), (6,2,2,'2022-12-08 11:00:00',250,60.00),
(7,3,3,'2022-12-13 12:00:00',245,40.00), (8,1,1,'2023-01-05 10:00:00',240,50.00),
(9,2,2,'2023-01-08 11:00:00',235,60.00), (10,3,3,'2023-02-13 12:00:00',245,40.00),
(11,1,1,'2023-03-05 10:00:00',250,50.00), (12,2,2,'2023-03-08 11:00:00',355,60.00),
(13,3,3,'2023-04-13 12:00:00',240,40.00), (14,1,1,'2023-04-01 10:00:00',235,50.00),
(15,1,6,'2023-05-01 10:00:00',245,60.00), (16,1,2,'2023-05-01 10:00:00',250,60.00),
(17,1,3,'2023-06-01 10:00:00',235,40.00), (18,1,4,'2023-06-01 10:00:00',255,75.00),
(19,1,5,'2023-07-01 10:00:00',240,50.00), (20,2,2,'2023-07-02 11:00:00',445,60.00),
(21,3,3,'2023-07-03 12:00:00',250,40.00), (22,4,4,'2023-08-04 13:00:00',235,75.00),
(23,5,5,'2023-08-05 14:00:00',555,50.00), (24,6,6,'2023-09-06 15:00:00',240,60.00),
(25,7,7,'2023-09-07 16:00:00',245,40.00), (26,8,8,'2023-09-08 17:00:00',250,75.00),
(27,9,9,'2023-10-09 18:00:00',335,50.00), (28,10,10,'2023-10-10 19:00:00',255,60.00),
(29,10,1,'2023-10-10 19:00:00',240,50.00), (30,10,2,'2023-10-10 19:00:00',245,60.00),
(31,10,3,'2023-10-10 19:00:00',250,40.00), (32,10,4,'2023-10-10 19:00:00',235,75.00);

INSERT INTO membership_type VALUES
(1, 'Basic Monthly',  'Unlimited rides with non-electric bikes. Renews monthly.',  100.00),
(2, 'Basic Annual',   'Unlimited rides with non-electric bikes. Renews annually.', 500.00),
(3, 'Premium Monthly','Unlimited rides with all bikes. Renews monthly.',           200.00);

INSERT INTO membership VALUES
(1,2,3,'2023-08-01','2023-08-31',500.00), (2,1,2,'2023-08-01','2023-08-31',100.00),
(3,3,4,'2023-08-01','2023-08-31',200.00), (4,1,1,'2023-09-01','2023-09-30',100.00),
(5,2,2,'2023-09-01','2023-09-30',500.00), (6,3,3,'2023-09-01','2023-09-30',200.00),
(7,1,4,'2023-10-01','2023-10-31',100.00), (8,2,5,'2023-10-01','2023-10-31',500.00),
(9,3,3,'2023-10-01','2023-10-31',200.00), (10,3,1,'2023-11-01','2023-11-30',200.00),
(11,2,5,'2023-11-01','2023-11-30',500.00), (12,1,2,'2023-11-01','2023-11-30',100.00);



SELECT * FROM customer;
SELECT * FROM bike;
SELECT * FROM rental;
SELECT * FROM membership_type;
SELECT * FROM membership;

-- Analysis

-- 1) Number of bikes the shop owns by category
SELECT category, COUNT(DISTINCT model) AS number_of_bikes 
FROM bike
GROUP BY category;

-- 2) Number of memberships purchased by each customer
WITH T1 AS (
    SELECT c.id, name, m.customer_id  
    FROM customer c
    LEFT JOIN membership m ON c.id = m.customer_id
)
SELECT name, SUM(CASE WHEN customer_id IS NOT NULL THEN 1 ELSE 0 END) AS total_memberships 
FROM T1
GROUP BY name
ORDER BY total_memberships DESC;

-- 3) Winter Sale discounts
SELECT id, category, price_per_hour,
       CASE 
           WHEN category = 'electric' THEN price_per_hour * 0.90
           WHEN category = 'mountain bike' THEN price_per_hour * 0.80
           ELSE price_per_hour * 0.50 
       END AS discounted_price_per_hour,
       price_per_day,
       CASE 
           WHEN category = 'electric' THEN price_per_day * 0.80
           WHEN category = 'mountain bike' THEN price_per_day * 0.50
           ELSE price_per_day * 0.50 
       END AS discounted_price_per_day
FROM bike;

-- 4) Rented vs Available count
SELECT category,
       SUM(CASE WHEN status = 'available' THEN 1 ELSE 0 END) AS available_bikes_count,
       SUM(CASE WHEN status = 'rented' THEN 1 ELSE 0 END) AS rented_bikes_count,
       SUM(CASE WHEN status = 'out of service' THEN 1 ELSE 0 END) AS out_of_service_bikes_count
FROM bike
GROUP BY category;

-- 5) Revenue based on year, month and membership type
SELECT YEAR(start_date) AS year, MONTH(start_date) AS month, name AS membership_type, SUM(total_paid) AS total_revenue 
FROM membership_type mt
JOIN membership m ON mt.id = m.membership_type_id
GROUP BY YEAR(start_date), MONTH(start_date), name;

-- 6) Revenue by membership type
SELECT name AS membership_type, MONTH(start_date) AS month, SUM(total_paid) AS total_revenue 
FROM membership_type mt
JOIN membership m ON mt.id = m.membership_type_id
WHERE YEAR(start_date) = 2023
GROUP BY MONTH(start_date), name
ORDER BY name;

-- 7) Customer segmentation 
WITH T1 AS (
    SELECT CASE 
               WHEN COUNT(customer_id) > 10 THEN 'more than 10'
               WHEN COUNT(customer_id) BETWEEN 5 AND 10 THEN 'between 5 and 10'
               ELSE 'fewer than 5' 
           END AS category 
    FROM rental
    GROUP BY customer_id
)
SELECT category, COUNT(category) 
FROM T1
GROUP BY category;

-- 8) Total revenue by month and year
SELECT YEAR(start_timestamp) AS year, MONTH(start_timestamp) AS month, SUM(total_paid) AS total_revenue 
FROM rental
GROUP BY YEAR(start_timestamp), MONTH(start_timestamp)


