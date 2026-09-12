
----ECOMMERCE ANALYSIS-----------

--DATABASE SETUP---
CREATE DATABASE EcommerceAnalytics

USE EcommerceAnalytics

---imported the customer table---

select*from Customers

---imported orders table---

SELECT*FROM Orders

---imported order_items----

SELECT*FROM ORDER_ITEMS

----imported products table---

SELECT*FROM PRODUCTS
----------------------------------------------------
USE EcommerceAnalytics;
GO
---ROW COUNTS---
SELECT COUNT(*) AS Customer_Count
FROM Customers;

SELECT COUNT(*) AS Product_Count
FROM Products;

SELECT COUNT(*) AS Order_Count
FROM Orders;

SELECT COUNT(*) AS Order_Item_Count
FROM Order_Items;
-------------------------------------
---CHECK NULL VALUES FOR ALL TABLES--

SELECT * FROM CUSTOMERS
WHERE customer_id IS NULL
OR country IS NULL
OR signup_date IS NULL

SELECT * FROM orders
WHERE order_id IS NULL
OR customer_id IS NULL
OR order_date IS NULL
OR status IS NULL

SELECT * FROM order_items
WHERE order_id IS NULL
OR product_id IS NULL
OR quantity IS NULL


SELECT * FROM products
WHERE product_id IS NULL
OR product_name IS NULL
OR category IS NULL

----CHECK DUPLICATE---


SELECT customer_id,COUNT(*) AS NO_OF_CUST FROM customers
GROUP BY customer_id
HAVING COUNT(*)>1

SELECT order_id,COUNT(*) FROM orders
GROUP BY order_id
HAVING COUNT(*)>1

SELECT product_id,COUNT(*) AS NO_OF_CUST FROM products
GROUP BY product_id
HAVING COUNT(*)>1

----order items table is not primary key as it have duplicate---

SELECT order_id, product_id, COUNT(*) AS cnt
FROM Order_Items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;
---JOINS---
----IT GIVES MATCHES AND INMATCHED ROWS FROM ORDER AND MATCHED FROM CUSTOMER----

SELECT *
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id

--IT RETURNS 0 ROWS THAT MEANS EVERY ORDER HAS CUSTOMERS---

SELECT o.customer_id
FROM Orders o
LEFT JOIN Customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

---CHECKING QUANTITY--IF IT RETURN 0 QUANTITY LOOKS VALID----

SELECT *
FROM Order_Items
WHERE quantity <= 0
----checkin unique values----

SELECT DISTINCT status
FROM Orders;

SELECT DISTINCT category
FROM Products;
---checking invalid/no future order---
SELECT *
FROM Orders
WHERE order_date > GETDATE();

----total customers---
select count(*) total_cust from customers

---count of status---

select*from orders

select status,count(*) count
from orders
group by status
order by count asc
------------------------------------------

---checking unique value for customer_id-----
SELECT DISTINCT customer_Id
FROM orders;

---customer id have duplicate in orders table as one customer have many orders.so only orderid is unique---

SELECT customer_id,COUNT(*) FROM orders
GROUP BY customer_id
HAVING COUNT(*)>1
------------------------------------------------------------
----USING JOINS FOR CUSTOMER AND ORDERS TABLE---
SELECT*FROM customers
SELECT*FROM orders
select * from customers c join orders o
on c.customer_id=o.customer_id
----count of customer by order----------------------------------------------------

select c.customer_id,count(o.order_id) count_orders from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_id
order by count_orders desc

-----analysis-------
--which customer placed most orders-------------------------------------------
select* from customers

select customer_id,count(order_id)count from orders
group by customer_id
order by count desc

select customer_id,count(*) count from orders
group by customer_id
order by count desc

----who are the top customers------------------------------------------
select c.customer_id,count(o.order_id) count_orders from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_id
order by count_orders desc

----how many repeat customers ----------------------------------------
select c.customer_id,count(o.order_id) count_orders from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_id
having count(o.order_id)>1

WITH ABC AS
(select c.customer_id,count(o.order_id) count_orders from customers c join orders o
on c.customer_id=o.customer_id
group by c.customer_id
having count(o.order_id)>1)
SELECT COUNT(*) FROM ABC

--- how many customers are never ordered--------------------------------

------if i use join it gives only matched rows ie,who have customerid and orderid not give null.so use left join----------------
SELECT *
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id

---below code shows leftjoin----
SELECT *
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
---------
SELECT c.customer_id,o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
--it gives total count----
SELECT COUNT(*) AS never_ordered
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-----which product sells the most----
-----which category performs best----
select* from products
select*from order_items

select * from products p join order_items o
on p.product_id=o.product_id

select sum(o.quantity) total_sold,o.product_id,p.category from products p join order_items o
on p.product_id=o.product_id
group by o.product_id,p.category
order by total_sold desc 

----which product generate most revenue-----------

select p.category,o.product_id,sum(o.price) total_price
from products p join order_items o
on p.product_id=o.product_id
group by o.product_id,p.category
order by total_price desc

-----How many completed/cancelled/returned orders are there?-----
select*from orders
 select status,count(status) from orders
 group by status

 -----What is the monthly order trend?----
 select month(order_date) month_only,count(order_id)count from orders
 group by month(order_date)
 order by month_only asc

 select *from order_items
 select*from orders
 -----Which month had the highest orders?----

  select month(order_date) month_only,count(order_id)count from orders
 group by month(order_date)
 order by count desc

 ----which customer spends the most----
 select*from customers
 select*from orders
 select*from products
 select*from order_items

 select c.customer_id,sum(ot.price) total_price from customers c join orders o
 on c.customer_id=o.customer_id
 join order_items ot
 on ot.order_id=o.order_id
 group by c.customer_id
 order by total_price desc

 ----What products are most popular among customers?----
 select *from products
 select*from order_items

 select *from products p join order_items o
 on p.product_id=o.product_id

 select sum(o.quantity)total_sold,p.category,o.product_id from products p
 join order_items o
 on p.product_id=o.product_id
 group by o.product_id,p.category
 order by total_sold Desc

 ------Which category is most popular in each country?----

select top 2 * from  customers
select top 2 *from orders
select top 2* from order_items
select top 2* from products


with ABC AS(
select c.country,p.category,sum(ot.quantity)total, 
dense_rank() over(partition by c.country order by sum(ot.quantity) desc)DR
from customers c join orders o 
on c.customer_id =o.customer_id
join order_items ot
on ot.order_id=o.order_id
join products p
on p.product_id=ot.product_id
group by c.country,p.category
)

select*from ABC
where DR=1

----or----

with ABC as(
select c.country,p.category,sum(ot.quantity)total from customers c join orders o 
on c.customer_id =o.customer_id
join order_items ot
on ot.order_id=o.order_id
join products p
on p.product_id=ot.product_id
group by c.country,p.category
),

ranked as(
select *, dense_rank() over(partition by country order by total desc) DR
from ABC)

 select *from ranked 
 where DR=1

 ----using cte-----

 -------Top 5 customers by number of orders-----
 select top 2 * from  customers
select top 2 *from orders
select top 2* from order_items
select top 2* from products

select *from orders 
where customer_id = 8 

select *from customers c join orders o
on c.customer_id=o.customer_id

with ABC as (
select o.customer_id,count(o.order_id) count_of_orders,row_number() over(order by count(o.order_id) desc)RN
from customers c join orders o
on c.customer_id=o.customer_id
group by o.customer_id
)

select * from ABC
where RN<=5

 ----------Repeat customers------
 select*from orders

 with ABC as (
 select customer_id,count(order_id)count
 from orders
 group by customer_id
 having count(order_id)>1
 )
 select*from ABC

 ---Customers above average orders----

 With ABC as (
 select customer_id,count(order_id)count
 from orders
 group by customer_id
 ),
 avg as (
 select *,avg(count) over( )avg_count from 


 )
 select*from avg
 where count>avg_count
--------
 With ABC as (
 select customer_id,count(order_id)count
 from orders
 group by customer_id
 ),
 avg as (
 select customer_id,avg(count)avg_c 
 from ABC
 group by customer_id
 )
 select*from avg
 where count>avg_c

---Rank customers by number of orders----
select*from orders
 
select customer_id,count(order_id)count,dense_rank() over(order by count(order_id) desc)DR
from orders
group by customer_id

---Top 3 customers in each country----

select *from customers
select*from orders

with ABC as (
select o.customer_id,c.country,count(o.order_id)count,dense_rank() over(partition by c.country order by count(o.order_id))DR
from customers c join orders o
on o.customer_id=c.customer_id
group by o.customer_id,c.country
)

with ABC as (
select o.customer_id,c.country,count(o.order_id)count
from customers c join orders o
on o.customer_id=c.customer_id
group by o.customer_id,c.country
),

rank as (
select*,dense_rank() over(partition by country order by count desc)DR
from ABC
)
select* from rank
where DR<=3
---------------------------------
--Rank products within each category----
select*from products
select*from order_items

select p.product_id,p.category,count(o.order_id)count,dense_rank() over(partition by p.category order by count(o.order_id)desc)DR
from products p join order_items o
on p.product_id=o.product_id
group by p.product_id,p.category

----customer order sequence-----
select*from orders

select*, ROW_NUMBER() over(partition by customer_id order by order_date asc)RN
from orders




---------------------------------------------------------------------------------



















