# 🚴‍♂️ NextBike Bike Rentals – Database Documentation
<p align="center">
  <img src="NextBike.png" width="500px">
</p>

## 📊 Overview
NextBike Rentals is a modern and customer-centric bike rental platform designed to offer flexible, affordable, and accessible transportation solutions. Whether it's a one-hour ride around the city or a month-long adventure, NextBike enables users to choose from a wide range of bikes and tailored membership plans.
This project aims to design a robust and scalable database system that efficiently handles core business operations such as bike inventory management, customer tracking, rental transactions, and subscription memberships.

---

## 🧱 Database Schema Overview

### 1. 🧍 `Customer`
Stores details of all customers.

| Column        | Data Type | Description             |
|---------------|-----------|-------------------------|
| `customer_id` | INT       | Unique ID (PK)          |
| `name`        | TEXT      | Customer's full name    |
| `email`       | TEXT      | Customer's email        |

🔑 **Primary Key**: `customer_id`

---

### 2. 🚲 `Bike`
Information about all bikes available for rent.

| Column           | Data Type | Description                             |
|------------------|-----------|-----------------------------------------|
| `id`             | INT       | Unique Bike ID (PK)                     |
| `model`          | TEXT      | Bike model name                         |
| `category`       | TEXT      | Type (e.g., mountain, road, hybrid)     |
| `price_per_hour` | DECIMAL   | Rental price per hour                   |
| `price_per_day`  | DECIMAL   | Rental price per day                    |
| `status`         | TEXT      | Current availability (e.g., available, rented, maintenance) |

🔑 **Primary Key**: `id`

---

### 3. 📄 `Rental`
Records each bike rental transaction.

| Column           | Data Type | Description                                   |
|------------------|-----------|-----------------------------------------------|
| `id`             | INT       | Unique Rental ID (PK)                         |
| `customer_id`    | INT       | Linked to `Customer.customer_id` (FK)        |
| `bike_id`        | INT       | Linked to `Bike.id` (FK)                      |
| `start_timestamp`| TIMESTAMP | When the rental started                       |
| `duration`       | INT       | Duration in hours or days (based on pricing) |
| `total_paid`     | DECIMAL   | Total amount paid                             |

🔑 **Primary Key**: `id`  
🔗 **Foreign Keys**:  
- `customer_id → Customer.customer_id`  
- `bike_id → Bike.id`

---

### 4. 🏷️ `Membership_Type`
Defines different subscription plans.

| Column      | Data Type | Description                       |
|-------------|-----------|-----------------------------------|
| `id`        | INT       | Unique Type ID (PK)               |
| `name`      | TEXT      | Plan name (e.g., Monthly, Annual) |
| `description`| TEXT     | Features and benefits             |
| `price`     | DECIMAL   | Subscription cost                 |

🔑 **Primary Key**: `id`

---

### 5. 💳 `Membership`
Links a customer to a specific membership type.

| Column              | Data Type | Description                                |
|---------------------|-----------|--------------------------------------------|
| `id`                | INT       | Unique Membership ID (PK)                  |
| `membership_type_id`| INT       | Linked to `Membership_Type.id` (FK)        |
| `customer_id`       | INT       | Linked to `Customer.customer_id` (FK)      |
| `start_date`        | DATE      | Start date of membership                   |
| `end_date`          | DATE      | Expiry date                                |
| `total_paid`        | DECIMAL   | Total amount paid                          |

🔑 **Primary Key**: `id`  
🔗 **Foreign Keys**:  
- `membership_type_id → Membership_Type.id`  
- `customer_id → Customer.customer_id`

---

## 🔗 Entity Relationships

- A **Customer** can rent multiple bikes (1-to-many).
- A **Bike** can be rented many times (1-to-many).
- A **Customer** can hold one or more **Memberships**.
- Each **Membership** belongs to a **Membership Type**.

---

## 🧠 Key Analysis Areas

- Track active and historical rentals
- Calculate revenue by customer or time frame
- Identify most/least rented bikes
- Analyze membership profitability and retention
- Determine availability and optimize bike utilization
---

## 📈 Insights and Recommendations

## 🛠️ Next Steps

- Build dashboards for rental trends and membership value
- Create APIs to support mobile booking apps
- Implement loyalty points based on rental frequency

---

> Made with ❤️ by the RideFlex Data Team

