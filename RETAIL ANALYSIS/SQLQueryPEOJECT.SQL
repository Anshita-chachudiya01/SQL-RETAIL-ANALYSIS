-- RETAIL ANALYSIS SQL PROJECT
use project;
select * from login_logs;
select * from sales_orders;
select * from sales_orders_items;

ALTER TABLE login_logs 
ADD PRIMARY KEY (login_log_id);

ALTER TABLE sales_orders 
ADD PRIMARY KEY (order_id);

ALTER TABLE sales_orders_items 
ADD PRIMARY KEY (order_item_id);

-- 1. Number of logins on a daily basis 
SELECT DATE(login_time) AS login_date,
    COUNT(*) AS total_logins
FROM login_logs
GROUP BY DATE(login_time)
ORDER BY login_date;

-- 2. Daily trend of logins
SELECT DATE(login_time) AS login_date,
    COUNT(*) AS total_logins
FROM login_logs
GROUP BY DATE(login_time)
ORDER BY login_date;

-- KPIs 
-- 1.Daily Active Users (DAU)
SELECT DATE(login_time) AS login_date, COUNT(DISTINCT user_id) AS daily_active_users
FROM login_logs
GROUP BY DATE(login_time);

-- KPI 2: Conversion Rate
SELECT COUNT(DISTINCT L.user_id) AS total_users,
    COUNT(DISTINCT S.order_id) AS total_orders,
    (COUNT(DISTINCT S.order_id) * 100.0 / 
     COUNT(DISTINCT L.user_id)) AS conversion_rate
FROM login_logs L
LEFT JOIN sales_orders S 
    ON L.user_id = S.fk_buyer_id;
    
-- KPI 3: Total Revenue
SELECT SUM(ordered_quantity * rate) AS total_revenue
FROM sales_orders_items;
    
-- KPI 4: Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM sales_orders;

-- KPI 5: Average Order Value (AOV)
SELECT SUM(I.price * I.quantity) / COUNT(DISTINCT S.order_id) AS avg_order_value
FROM sales_orders S
JOIN sales_orders_items I 
    ON S.order_id = I.fk_order_id;



-- KPI 6: Retention Rate
SELECT COUNT(DISTINCT repeat_users.fk_buyer_id) * 100.0 /
    COUNT(DISTINCT all_users.user_id) AS retention_rate
FROM (SELECT fk_buyer_id FROM sales_orders
     GROUP BY fk_buyer_id
     HAVING COUNT(order_id) > 1) repeat_users
JOIN login_logs all_users 
    ON repeat_users.fk_buyer_id = all_users.user_id;

-- KPI 5: Average Order Value (AOV)
SELECT SUM(ordered_quantity * rate)/ COUNT(DISTINCT S.order_id) AS avg_order_value
FROM sales_orders S
JOIN sales_orders_items I 
    ON S.order_id = I.fk_order_id;

-- 4(a). Did our business grow? (Year-wise Orders & Revenue)
SELECT YEAR(S.creation_time) AS year,
    COUNT(DISTINCT S.order_id) AS total_orders,
    SUM(I.ordered_quantity * I.rate) AS total_revenue
FROM sales_orders S
JOIN sales_orders_items I 
    ON S.order_id = I.fk_order_id
GROUP BY YEAR(S.creation_time)
ORDER BY year;

-- 4(b). Does our app perform better now? (Conversion Rate)
SELECT EAR(L.login_time) AS year,
    COUNT(DISTINCT L.user_id) AS total_users,
    COUNT(DISTINCT S.order_id) AS total_orders,
    (COUNT(DISTINCT S.order_id) * 1.0 / 
     COUNT(DISTINCT L.user_id)) AS conversion_rate
FROM login_logs L
LEFT JOIN sales_orders S 
    ON L.user_id = S.fk_buyer_id
GROUP BY YEAR(L.login_time)
ORDER BY year;

-- 4(c). Did our user base grow?
SELECT YEAR(login_time) AS year,
    COUNT(DISTINCT user_id) AS total_users
FROM login_logs
GROUP BY YEAR(login_time)
ORDER BY year;

-- 5. Top-selling products in each year
SELECT YEAR(S.creation_time) AS year,
    I.fk_product_id,
    SUM(I.ordered_quantity) AS total_sold
FROM sales_orders S
JOIN sales_orders_items I 
    ON S.order_id = I.fk_order_id
GROUP BY YEAR(S.creation_time), I.fk_product_id
ORDER BY year, total_sold DESC;

-- 6. July 2021 Analysis

-- (a). Daily logins in July 2021 
SELECT DATE(login_time) AS login_date,
    COUNT(*) AS total_logins
FROM login_logs
WHERE MONTH(login_time) = 7 
  AND YEAR(login_time) = 2021
GROUP BY DATE(login_time)
ORDER BY login_date;

-- (b). Daily orders in July 2021 
SELECT DATE(login_time) AS login_date, COUNT(*) AS total_logins
FROM login_logs
WHERE login_time between '2021-07-01' and '2021-07-31'
group by date(login_time)
order by login_date;
  
/* 6(c). Conversion rate in July 2021 */
SELECT 
    COUNT(DISTINCT L.user_id) AS total_users,
    COUNT(DISTINCT S.order_id) AS total_orders,
    (COUNT(DISTINCT S.order_id) * 100.0 / 
     COUNT(DISTINCT L.user_id)) AS conversion_rate
FROM login_logs L
LEFT JOIN sales_orders S 
    ON L.user_id = S.fk_buyer_id
WHERE MONTH(L.login_time) = 7 
  AND YEAR(L.login_time) = 2021;
