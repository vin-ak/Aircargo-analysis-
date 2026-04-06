create database aircargo;
use aircargo;
select * from aircargo;
SELECT * FROM fact_flights;

-- total revenue --
SELECT SUM(revenue) AS total_revenue
FROM fact_flights;

-- tickets ssold by class --
select class_id,sum(no_of_tickets) as tickets_sold
from fact_flights
group by class_id;

-- top customer --
SELECT customer_id, SUM(revenue) AS total_spent
FROM fact_flights
GROUP BY customer_id
ORDER BY total_spent DESC;

-- Busiest routes --
select route_id,count(*) as total_flights
from fact_flights
group by route_id
order by total_flights desc;

-- revenue by aircraft --
select aircraft_id,sum(revenue) as total_revenue
from fact_flights
group by aircraft_id;

select * from fact_flights;

-- top customers ---
select c.first_name,c.last_name,sum(f.revenue) as total_spent
from fact_flights f
join dim_customers c
on f.customer_id = c.customer_id
group by c.first_name,c.last_name
order by total_spent desc;

-- Route analysis --
select r.origin_airport,r.destination_airport,sum(f.revenue) as revenue
from fact_flights f
join dim_routes r 
on f.route_id=r.route_id
group by r.origin_airport,r.destination_airport
order by revenue desc;

-- monthly revenue --
select month(travel_date) as month,sum(revenue) as revenue
from fact_flights
group by month(travel_date)
order by month;

-- windows fn --
-- top customers with ranking --
select 
	customer_id,
    sum(revenue) as total_spent,
    rank() over (order by sum(revenue) desc) as rank_num
from fact_flights
group by customer_id;

-- top 3 customers only --
select * from ( --
	select 
		customer_id,
        sum(revenue) as total_spent,
        rank() over (order by sum(revenue) desc) as rank_num
	from fact_flights
    group by customer_id
 ) t 
 where rank_num <=3; 

-- rank customers within each aircraft

select 
	aircraft_id,
    customer_id,
    sum(revenue) as total_spent,
    rank() over (partition by aircraft_id order by sum(revenue) desc) as rank_num
from fact_flights
group by aircraft_id,customer_id;

-- row_number vs rank vs dense rank

select 
	customer_id,
    sum(revenue) as total_spent,
    row_number() over (order by sum(revenue) desc) as row_num,
    rank() over (order by sum(revenue) desc) as rank_num,
    rank() over (order by sum(revenue) desc) as dense_rank_num
from fact_flights
group by customer_id;

-- categorize customers 
select 
	customer_id,
    sum(revenue) as total_spent,
    case
		when sum(revenue) > 500 then 'high value'
        when sum(revenue) between 200 and 500 then 'medium'
        else 'low'
	end as customer_type
from fact_flights
group by customer_id;

-- full business view
select
    c.first_name,
    r.origin_airport,
    r.destination_airport,
    f.revenue
from fact_flights f
join dim_customers c on f.customer_id = c.customer_id
join dim_routes r on f.route_id = r.route_id;

-- revenue by year and month
select 
    year(travel_date) as year,
    month(travel_date) as month,
    sum(revenue) as total_revenue
from fact_flights
group by year, month;

-- cte 

with customer_revenue as (
	select 
		customer_id,
        sum(revenue) as total_spent
    from fact_flights
    group by customer_id
)
select * from customer_revenue
where total_spent >300;

-- time analysis (lag/lead)
select
	customer_id,
    travel_date,
    revenue,
    lag(revenue) over (partition by customer_id order by travel_date) as prev_revenue
from fact_flights;


-- second highest revenue customer
with customer_revenue as (
	select 
    customer_id,
    sum(revenue) as total_spent,
    dense_rank() over (order by sum(revenue) desc) as rnk
from fact_flights
group by customer_id
)
select * from customer_revenue
where rnk = 2;

SELECT 
    customer_id,
    travel_date,
    revenue,
    LEAD(revenue) OVER (
        PARTITION BY customer_id 
        ORDER BY travel_date
    ) AS next_revenue
FROM fact_flights;


-- running total
SELECT 
    customer_id,
    travel_date,
    revenue,
    
    SUM(revenue) OVER (
        PARTITION BY customer_id 
        ORDER BY travel_date
    ) AS running_total
FROM fact_flights;


