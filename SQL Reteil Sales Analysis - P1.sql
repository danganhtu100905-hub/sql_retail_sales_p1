--**SQL Reteil Sales Analysis - P1**
create database sql_project_p2;

DROP TABLE IF EXISTS retail_sales;
--create table
create table retail_sales
			(	
				transactions_id INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,	
				customer_id	INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),
				quantity INT,
				price_per_unit FLOAT,	
				cogs FLOAT,	
				total_sale FLOAT
			);

select * from public.retail_sales limit 10;

--Data cleaning
delete from public.retail_sales
where transactions_id is null
	or sale_date is null
	or gender is null
	or category is null
	or quantity is null
	or cogs is null
	or total_sale is null

--Data exploration

--How many sales we have?
select count(*) total_sale from public.retail_sales

--How many unique customers we have?
select count(distinct customer_id) total_sale from public.retail_sales
select distinct category as category from public.retail_sales

--Data analysis & Business key problems and answers
---retrieve all columns for sales made on '2022-11-05'
select * from retail_sales
where sale_date = '2022-11-05'

---Retrieve all transactions where the category is 'Clothing' and the quantity sold is equal or more than 4 in the month of Nov-2022
select *
from public.retail_sales
where category = 'Clothing' 
	and to_char(sale_date, 'YYYY-MM')='2022-11' 
	and quantity >= 4

--calculate the total sales (total_sale) for each category
select category, sum(total_sale) total_sales, count(*) total_orders
from public.retail_sales
group by 1

--find the average age of customers who purchased items from the 'Beauty' category
select round(avg(age),2) average_age
from public.retail_sales
where category = 'Beauty'

--find all transactions where the total_sale is greater than 1000
select *
from public.retail_sales
where total_sale > 1000

--find the total number of transactions (transaction_id) made by each gender in each category
select category, gender, count(*) transactions_number
from public.retail_sales
group by 1,2
order by 1

--calculate the average sale for each month. Find out best selling month in each year
select  to_char(sale_date, 'YYYY') as year,
		to_char(sale_date, 'MM') as month,
		avg(total_sale) average_sale
from public.retail_sales
group by 1, 2
order by 1, 3 desc
--addition
with t as (select extract(year from sale_date) as year,
				extract(month from sale_date) as month,
				avg(total_sale) average_sale
from public.retail_sales
group by 1, 2),

	x as (select *,
			min(average_sale) over(partition by year) as min_avg,
			max(average_sale) over(partition by year) as max_avg,
			dense_rank() over (partition by year order by average_sale desc) as rnk
		  from t)
select * from x
where rnk = 1

--find the top 5 customers based on the highest total_sales
select customer_id, sum(total_sale) total_sales
from public.retail_sales
group by 1
order by 2 desc
limit 5

--find the number of unique customers who purchased items from each category
select category, count(distinct customer_id) as customer_number
from public.retail_sales
group by 1

--create each shift and number of orders (Example: Morning <= 12, Afternoon between 12&17, Evening >17)

with t as (select *,
			case
			when extract(hour from sale_time) <= 12 then 'Morning'
			when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
			else 'Evening'
		end as shift
		from public.retail_sales)

select shift, count(*) as total_orders
from t
group by 1

