# Dannys Diner | case one
## Solutions Above
To see the documentation, click [here](https://medium.com/analytics-vidhya/8-week-sql-challenge-case-study-week-1-dannys-diner-2ba026c897ab).

### 1. What is the total amount each customer spent at the restaurant?

````sql
SELECT
customer_id,
SUM(price) AS total_spent
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id;
````

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

### 2. How many days has each customer visited the restaurant?
````sql
SELECT
COUNT(DISTINCT(order_date)) AS count_visit
FROM dannys_diner.sales
GROUP BY customer_id;
````
#### Answer:
 | count_visit |
 | ----------- |
 | 4           |
 | 6           |
 | 2           |

### 3. What was the first item from the menu purchased by each customer?

````sql
SELECT *
FROM
	(SELECT
    customer_id,
    sales.product_id,
    product_name,
      DENSE_RANK() OVER (PARTITION BY customer_id ORDER BY order_date) sales_rank
	FROM dannys_diner.sales
    JOIN dannys_diner.menu ON sales.product_id = menu.product_id) AS sub_rank
WHERE sales_rank=1;
````
#### Answer:
| customer_id | product_id | product_name | sales_rank |
| ----------- | ---------- | ------------ | ---------- |
| A           |      1     |     curry    | 1          |
| A           |      2     |     sushi    | 1          |
| B           |      2     |     curry    | 1          |
| C           |      3     |     ramen    | 1          |
| C           |      3     |     ramen    | 1          |


### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

````sql
SELECT  
sales.product_id, 
product_name,
COUNT(sales.product_id) AS count_product
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
WHERE sales.product_id = (SELECT MAX(sales.product_id) FROM dannys_diner.sales);
````


### 5. Which item was the most popular for each customer?


````sql
WITH fav_item_ AS
(
   SELECT sales.customer_id, menu.product_name, COUNT(sales.product_id) AS order_count,
      DENSE_RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(sales.customer_id) DESC) rank_
   FROM dannys_diner.sales 
   JOIN dannys_diner.menu ON sales.product_id = menu.product_id
   GROUP BY sales.customer_id, menu.product_name
)
SELECT customer_id, product_name, order_count
FROM fav_item_
WHERE rank_ = 1;
````


### 6. Which item was purchased first by the customer after they became a member?

````sql
SELECT*
FROM dannys_diner.sales
JOIN dannys_diner.members ON sales.customer_id = members.customer_id
WHERE order_date >= join_date;

WITH first_member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) _rank2
   FROM sales AS s
   JOIN members AS m ON s.customer_id = m.customer_id
   WHERE s.order_date >= m.join_date
)
SELECT customer_id, order_date
FROM first_member_sales 
WHERE _rank2 = 1;
````


### 7. Which item was purchased just before the customer became a member?


````sql
WITH last_member_sales AS 
(
   SELECT s.customer_id, m.join_date, s.order_date, s.product_id,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date DESC) _rank2
   FROM sales AS s
   JOIN members AS m ON s.customer_id = m.customer_id
   WHERE s.order_date < m.join_date
)
SELECT customer_id, order_date
FROM last_member_sales 
WHERE _rank2 = 1;
````


### 8. What is the total items and amount spent for each member before they became a member?


````sql
SELECT 
s.customer_id, 
COUNT(s.product_id) AS unique_menu_item, 
SUM(mm.price) AS total_sales
FROM sales AS s
JOIN members AS m ON s.customer_id = m.customer_id
JOIN menu AS mm ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
````


### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?





### 10. 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?
