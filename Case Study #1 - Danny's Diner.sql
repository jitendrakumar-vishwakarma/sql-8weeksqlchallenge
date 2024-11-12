-- Case Study #1 - Danny's Diner


-- All tables
select * from sales s ;
select * from members m ;
select * from menu m ;

-- 1. What is the total amount each customer spent at the restaurant?
select
	s.customer_id,
	sum(m.price) as amount_spend
from
	sales s
join menu m on
	m.product_id = s.product_id
group by
	s.customer_id
order by
	s.customer_id ;

-- 2. How many days has each customer visited the restaurant?
select
	customer_id ,
	count(distinct order_date)
from
	sales s
group by
	customer_id 
order by customer_id ;


-- 3. What was the first item from the menu purchased by each customer?
with rnk_date as (
select
	s.*,
	rank() over(partition by customer_id
order by
	order_date) as rnk
from
	sales s
)
 
select
	rd.customer_id,
	rd.order_date,
	m.product_name
from
	rnk_date rd
join menu m on
	m.product_id = rd.product_id
where
	rd.rnk = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

with product_sold_counts as (
select
	product_id,
	count(*)
from
	sales s
group by
	product_id

)

select
	m.product_name ,
	psc.count
from
	product_sold_counts psc
join menu m on
	m.product_id = psc.product_id
order by
	count desc;

-- 5. Which item was the most popular for each customer?
with count_max_items as (
select
	s.customer_id ,
	m.product_name,
	count(*),
	rank() over(partition by s.customer_id
order by
	count(*) desc) as rnk
from
	sales s
join menu m on
	m.product_id = s.product_id
group by
	s.customer_id,
	m.product_name
order by
	s.customer_id)

select
	customer_id,
	product_name,
	count
from
	count_max_items
where
	rnk = 1;

-- 6. Which item was purchased first by the customer after they became a member?

with customer_orders as (
select
	s.customer_id,
	s.order_date,
	me.product_name,
	rank() over(partition by s.customer_id
order by
	s.order_date)
from
	sales s
join members m on
	m.customer_id = s.customer_id
join menu me on
	me.product_id = s.product_id
where
	s.order_date >= m.join_date
order by
	s.customer_id )

select
	customer_id,
	product_name
from
	customer_orders
where
	rank = 1;


-- 7. Which item was purchased just before the customer became a member?

with customer_orders as (
select
	s.customer_id,
	s.order_date,
	me.product_name,
	rank() over(partition by s.customer_id
order by
	s.order_date desc)
from
	sales s
join members m on
	m.customer_id = s.customer_id
join menu me on
	me.product_id = s.product_id
where
	s.order_date < m.join_date
order by
	s.customer_id )

select
	customer_id,
	product_name
from
	customer_orders
where
	rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?

with customer_orders as (
select
	s.customer_id,
	s.order_date,
	me.product_name,
	s.product_id
from
	sales s
join members m on
	m.customer_id = s.customer_id
join menu me on
	me.product_id = s.product_id
where
	s.order_date < m.join_date
order by
	s.customer_id )

select
	co.customer_id,
	count(*) as total_items,
	concat( '$',
	sum(m.price)) as total_spend
from
	customer_orders co
join menu m on
	m.product_id = co.product_id
group by
	co.customer_id
order by
	co.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select
	s.customer_id ,
	sum(case
		when m.product_name != 'sushi' then m.price * 10
		else m.price * 20
	end) as points
from
	sales s
join menu m on
	m.product_id = s.product_id
group by
	s.customer_id
order by
	s.customer_id ;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH customer_orders AS (
    SELECT
        s.customer_id,
        s.order_date,
        me.product_name,
        s.product_id
    FROM
        sales s
    JOIN
        members m ON m.customer_id = s.customer_id
    JOIN
        menu me ON me.product_id = s.product_id
    WHERE
        s.order_date >= m.join_date 
        AND s.order_date <= (DATE_TRUNC('month', '2021-01-01'::date) + INTERVAL '1 month - 1 day')
    ORDER BY
        s.customer_id
)


SELECT
    co.customer_id,
    SUM(
        CASE
            WHEN co.order_date <= me.join_date + INTERVAL '6' DAY THEN m.price * 10 * 2
            ELSE m.price * 10
        END
    ) AS points
FROM
    customer_orders co
join menu m on m.product_id  = co.product_id
join
	members me on me.customer_id  = co.customer_id
GROUP BY
    co.customer_id;


	

































