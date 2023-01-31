#----------------------------------Case Study Questions-------------------------------------#
-- Each of the following case study questions can be answered using a single SQL statement:--

-- 1 | What is the total amount each customer spent at the restaurant?
SELECT 
customer_id,
COUNT(product_id)
FROM dannys_diner.sales;


SELECT *
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id;

SELECT
customer_id,
SUM(price) AS total_spent
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id;

-- 2 | How many days has each customer visited the restaurant?
SELECT
COUNT(DISTINCT(order_date)) AS count_visit
FROM dannys_diner.sales
GROUP BY customer_id;


-- 3 | What was the first item from the menu purchased by each customer?
SELECT
customer_id,
sales.product_id
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
WHERE order_date = '2021-01-01';

SELECT
customer_id,
sales.product_id,
order_date,
ROW_NUMBER() OVER(
ORDER BY order_date asc) rank_
FROM dannys_diner.sales;

SELECT 
customer_id,
sales.product_id,
order_date,
DENSE_RANK() OVER (
    PARTITION BY customer_id
    ORDER BY order_date
) sales_rank
FROM dannys_diner.sales;

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


-- 4 | What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
sales.product_id,
product_name,
COUNT(sales.product_id) AS count_by_product
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY product_id
ORDER BY product_id DESC;


SELECT  
sales.product_id, 
product_name,
COUNT(sales.product_id) AS count_product
FROM dannys_diner.sales
JOIN dannys_diner.menu ON sales.product_id = menu.product_id
WHERE sales.product_id = (SELECT MAX(sales.product_id) FROM dannys_diner.sales);


-- 5 | Which item was the most popular for each customer?

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


-- 6 |  Which item was purchased first by the customer after they became a member?
#A -2021-01-07
#B - 2021-01-11

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



-- 7 | Which item was purchased just before the customer became a member?

SELECT*
FROM dannys_diner.sales
JOIN dannys_diner.members ON sales.customer_id = members.customer_id
WHERE order_date <= join_date;


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


-- 8 | What is the total items and amount spent for each member before they became a member?
#2 a 
#3 b

SELECT*
FROM dannys_diner.sales AS s
HAVING order_date < join_date;

SELECT
COUNT(product_id)
FROM dannys_diner.sales AS s
GROUP BY s.customer_id;

SELECT*
FROM dannys_diner.sales AS s
JOIN dannys_diner.members AS m ON s.customer_id = m.customer_id
HAVING order_date < join_date;

SELECT
s.customer_id,
s.order_date,
s.product_id,
m.join_date,
COUNT(distinct s.product_id)
FROM dannys_diner.sales AS s
JOIN dannys_diner.members AS m ON s.customer_id = m.customer_id
GROUP BY s.customer_id
HAVING order_date < join_date;

SELECT 
s.customer_id, 
COUNT(s.product_id) AS unique_menu_item, 
SUM(mm.price) AS total_sales
FROM sales AS s
JOIN members AS m ON s.customer_id = m.customer_id
JOIN menu AS mm ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;


-- 9 | If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?



-- 10 | In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?