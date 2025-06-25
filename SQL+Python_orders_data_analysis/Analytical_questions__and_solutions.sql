--Checking weather data loaded correctly
--select * from df_orders;
--1. Find top 10 highest revenue generating products

select product_id,sum(sale_price) as revenue from df_orders
group by product_id
order by revenue DESC;

--2. Find top 5 highest selling products in each region
with cte as(
select region,product_id,sum(sale_price) as sales
from df_orders
group by region,product_id)
--order by region,sales desc;
select * from (select *,ROW_NUMBER() over(partition by region order by sales desc) as rn from cte) t
where rn <=5;

--3. find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
select month,sum(case when year=2022 then sales else 0 end) as sales_2022, sum(case when year=2023 then sales else 0 end) as sales_2023 
from(
select month(order_date) as month,year(order_date) as year,sum(sale_price) as sales
from df_orders	
group by month(order_date),year(order_date)) t
group by month;

--4. For each category which month had highest sales
with cte as(
select category,FORMAT(order_date,'yyyyMM') as year_month,sum(sale_price) as sales
from df_orders
group by category,FORMAT(order_date,'yyyyMM'))

select * from(
select *,ROW_NUMBER() over(partition by category order by sales desc) as rn
from cte)t
where rn = 1



--5. Which sub-category had highest growth by profit in 2023 compare to 2022
with cte as(
select sub_category,year(order_date) as year,sum(profit) as sale_profit
from df_orders	
group by sub_category,year(order_date)
),
cte2 as
(
select sub_category,sum(case when year=2022 then sale_profit else 0 end) as profit_2022, 
sum(case when year=2023 then sale_profit else 0 end) as profit_2023
from cte
group by sub_category)

select *,(profit_2023 - profit_2022)*100/profit_2022 as pct_growth 
from
cte2
order by pct_growth desc

