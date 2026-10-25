-- Check table structure 
PRAGMA table_info(orders)

--Preview first 5 rows
SELECT * FROM orders LIMIT 5

--Show Selected columns only
SELECT OrderID, Date, Product, Quantity, TotalPrice FROM orders LIMIT 10

--Distict Values
SELECT DISTINCT Product FROM orders ORDER BY Product

--Aggeragations (count, sum, avg, min, max)
SELECT COUNT(*)               AS total_orders,
    ROUND(SUM(TotalPrice),2)  AS total_revenue,
    ROUND(AVG(TotalPrice), 2) AS avg_order_value,
    MIN(TotalPrice)           AS min_order,
    MAX(TotalPrice)           AS max_order,
    MIN(Date)                 AS first_date,
    MAX(Date)                 AS last_date
FROM orders


--Unique customers vs total orders (check repeating customers)
SELECT COUNT(DISTINCT CustomerID) AS unique_customers, 
       COUNT(*)                   AS total_orders 
FROM orders


--Where (filtering) + Order by (sorting)
SELECT OrderID , Product, Quantity, UnitPrice, TotalPrice
FROM orders 
WHERE TotalPrice > 3000
ORDER BY TotalPrice DESC
LIMIT 10    


--AND 
SELECT COUNT(*) AS delivered_laptops
FROM orders
WHERE OrderStatus="Delivered"
AND Product = "Laptop"


--IN + BETWEEN + GROUP BY
SELECT Product, COUNT(*) AS orders
FROM orders
WHERE PaymentMethod IN ("Credit Card", "Debit Card")
        AND Date BETWEEN "2024-01-01" AND "2024-12-31"
GROUP BY Product
ORDER BY orders DESC


--LIKE 
SELECT COUNT(*) AS save_coupon_orders
FROM orders
WHERE CouponCode LIKE "SAVE%"


--GROUP BY (Business Analysis)
--product performance
product_df =
SELECT  Product,
            COUNT(*)                    AS orders,
            ROUND(SUM(TotalPrice), 2)   AS revenue,
            ROUND(AVG(TotalPrice), 2)    AS avg_order
FROM orders
GROUP BY Product
ORDER BY revenue DESC


--order status breakdown with percentage
SELECT  OrderStatus,
            COUNT(*)                    AS orders,
            ROUND(SUM(TotalPrice), 2)   AS revenue,
            ROUND(COUNT(*)*100.0 /(SELECT COUNT(*) FROM orders), 1)    AS pct_of_orders
FROM orders
GROUP BY OrderStatus
ORDER BY orders DESC


--Revenue by year
SELECT strftime ('%Y', Date)    AS year,
        COUNT(*)                    AS orders,
        ROUND(SUM(TotalPrice), 2)   AS revenue
FROM orders
GROUP BY year
ORDER BY year

--comparison: only Jan-Jun of each year (2025 has only six months)
SELECT strftime('%Y', Date) AS year,
ROUND(SUM(TotalPrice), 2)  AS h1_revenue
FROM orders
WHERE CAST(strftime('%m', Date) AS INTEGER) <=6
GROUP BY year
ORDER BY year 


--Top 3 months by total revenue
SELECT strftime('%m' , Date)   AS month,
        ROUND(SUM(TotalPrice), 2)  AS revenue
FROM orders
GROUP BY month
ORDER BY revenue DESC
LIMIT 3


--Marketing: referral source
SELECT ReferralSource, COUNT(*) AS orders,
    ROUND(AVG(TotalPrice), 2)   AS avg_orders
FROM orders
GROUP BY ReferralSource 
ORDER BY  avg_orders DESC


SELECT couponCode, 
       COUNT(*)                  AS orders,
       ROUND(AVG(TotalPrice), 2) AS avg_order
FROM orders 
GROUP BY CouponCode
ORDER BY avg_order DESC 


SELECT  PaymentMethod,
        COUNT(*)                    AS orders ,
        ROUND(SUM(TotalPrice), 2)   AS revenue
FROM orders 
GROUP BY PaymentMethod
ORDER BY revenue DESC


--HAVING  (filter AFTER grouping)
--Products with revenue above 180,000
SELECT  Product,
        ROUND(SUM(TotalPrice), 2) AS revenue
FROM orders
GROUP BY Product
HAVING SUM(TotalPrice) > 180000
ORDER BY revenue DESC


--customers who ordered more than once
SELECT CustomerID,
        COUNT(*)                    AS orders,
        ROUND(SUM(TotalPrice), 2)   AS total_spent
FROM orders
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY total_spent DESC
LIMIT 5


--Advanced Insights (Percentage contribution)
--Percentage contribution of each prodcut to total revenue
SELECT  Product,
        ROUND(SUM(TotalPrice)* 100.0 / (SELECT SUM(TotalPrice) FROM orders), 1) AS pct_of_revenue
FROM orders
GROUP BY Product
ORDER BY pct_of_revenue DESC    


--Canecllation + Return rate per product 
SELECT  Product,
        ROUND(100.0 * SUM(CASE WHEN OrderStatus 
                IN ('Canecelled', 'Returned') THEN 1 ELSE 0 END) / COUNT(*), 1) AS fail_rate_pct
FROM orders
GROUP BY Product
ORDER BY fail_rate_pct DESC


--Revenue lost to cancelled + returned orders
SELECT  ROUND(SUM(TotalPrice), 2) AS failed_order_value,
            ROUND(SUM(TotalPrice) * 100.0 / (SELECT SUM(TotalPrice) FROM orders), 1) AS pct_of_total
FROM orders
WHERE OrderStatus IN ('Cancelled' , 'Returned')


--Close connection
con.close()