-- -----------------------------------------------------------------------------------------------------------
--        -----------------------------sales analysis---------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------


-- What is the total revenue and total cost of gross sales and profit of Second Quarter(JAN, FEB, MAR) 

select
       round(sum(cogs),2) as total_cogs , round(sum(revenue),2) as total_revenue , 
	   round(round(sum(revenue),2)-round(sum(cogs),2) ,2) as profit
from revenue;

-- What is total revenue by month

select
      s.month , round(sum(r.revenue),2) as revenue 
from sales_data s
inner join revenue r on s.`invoice _id` = r.`invoice _id`
group by s.month
order by revenue desc


# Total revenue by cities
select 
     s.city, s.branch,round(sum(r.revenue),2) as revenue 
from sales_data s 
inner join revenue r on s.`invoice _id` = r.`invoice _id`
group by s.city
order by revenue desc;

# Number of sales made in each time of the day per weekday

select 
    time_of_day, count(*) as sales_weekend
from sales_data 
where day_name = 'Sunday'
group by time_of_day;


-- Which of the customer types brings the most revenue?

select
      t.customer_type , round(sum(r.revenue),2) as hight_revenue 
from tax_cal t 
inner join revenue r on t.`invoice _id` = r.`invoice _id`
group by customer_type 
order by hight_revenue desc;

-- Which city has the largest tax percentage/ VAT (Value Added Tax)?

select 
     City , round(sum(`tax_12%`),2) as hight_VAT 
from tax_cal
group by city 
order by hight_VAT desc;

-- Which customer type pays the most in VAT?

select 
     customer_type ,  round(sum(`tax_12%`),2)as high_VAT 
from tax_cal
group by customer_type 
order by high_VAT desc

-- most selling days of branches  //stored procedure

select 
    s.day_name , round(sum(r.revenue),2) as revenue 
from sales_data s  
inner join revenue r on s.`invoice _id` = r.`invoice _id`
where s.branch='C'
group by s.month
order by revenue desc;



-- -------------------------------------------------------------------------------------------------------------------------
--           ---------------------------------- Product analysis-----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------

-- How many unique product types does the data have?

select
    count(distinct product_code) as number_of_diff_prod 
from sales_data;
 

-- What is the most common payment method?

select
      payment , count(*) as Common_used
from sales_data
group by payment
order by common_used desc;


-- What is the most selling product type?

select
       p.product_name , sum(s.quantity) as total_selling
from sales_data s 
inner join product_details p on s.product_code = p.Product_id
group by s.product_code
order by total_selling desc;

-- Average price rates of products

   select 
          p.product_name , round(avg(s.unit_price),2) as avg_price
   from sales_data s 
   join product_details p on s.product_code= p.product_id
   group by s.product_code;
   

-- What product type had the largest revenue?
 
 select  s.product_code, 
           p.product_name ,
           sum( r.revenue) as  product_revenue
from sales_data s 
join product_details p on s.product_code = p.product_id
join revenue r on s.`invoice _id`= r.`invoice _id`
group by p.product_name;


select 
      product_code, product_name, round(product_revenue,2) 
from product_revenue
order by product_revenue desc;


-- What product type had the largest VAT?

select 
      p.product_id  ,p.product_name, sum(r.`tax_12%`) as total_vat
from sales_data s
join product_details p on s.product_code = p.product_id
join revenue r on s.`invoice _id` = r.`invoice _id`
group by p.product_id;

select * from product_vat
order by total_vat desc 
limit 3;


-- Fetch each product line and add a column to those product Types showing 
-- "Good", "Bad". Good if it's greater than average sales

with avg_sale as (
select 
      avg(quantity) 
from sales_data)

select 
	p.product_name,avg(s.quantity) ,
                       case
                       when avg(s.quantity) > (select * from avg_sale)  then 'Good'
                       else 'Bad'
                       end as remark
from sales_data s join product_details p on s.product_code = p.product_id
group by s.product_code; 

-- Which branch sold more products than the average product sold?

with avg_sale as(
select 
     avg(quantity) 
from sales_data)

select  
       s.branch ,sum(s.quantity) as total_sales
from sales_data s 
inner join product_details p on s.product_code= p.product_id
group by s.branch
having total_sales > (select * from avg_sale)
order by total_sales desc;


-- What are the top 3 most common product types by gender?

select  
      p.product_name , 
      sum(s.quantity) as common_for_Female
from sales_data s 
inner join product_details p on s.product_code= p.product_id
where s.gender  = 'female'
group by s.product_code
order by common_for_Female desc;

select 
		p.product_name , sum(s.quantity) as common_for_male
from sales_data s 
inner join product_details p on s.product_code= p.product_id
where s.gender  = 'male'
group by s.product_code
order by common_for_male desc;
 
-- What is the average rating of each product type?

select  
        p.product_id,p.product_name , round(avg(s.rating),2) as avg_rating
from sales_data s 
inner join product_details p on s.product_code= p.product_id
group by s.product_code
order by avg_rating desc;

-- Which product has the lowest revenue 
select * 
from product_revenue
order by  product_revenue  asc
limit 3;
   
   
-- Which product has the lowest rating than the average rating
with avg_rating as (
select 
round(avg(rating),2) as avg_rating
from sales_data)

select 
       p.product_name , round(avg(s.rating),2) as avg_rating
from sales_data s 
join product_details p on s.product_code = p.product_id
group by product_code 
having  avg_rating < (select * from avg_rating);

-- monthly sales of product

select 
      s.month ,  p.product_name , sum( s.quantity) over (partition by p.product_name ) as quan
from sales_data s 
join product_details p on s.product_code= p.product_id
order by s.month, quan desc;



-- ---------------------------------------------------------------------------------------------------------
--        ---------------------------------Customer Analysis -----------------------------------
-- ---------------------------------------------------------------------------------------------------------


-- How many unique customer types does the data have?

select 
count(distinct  customer_type) 
from sales_data

-- the total number of gender types data have?

select 
      Gender , count(*) as total_number
from sales_data
group by gender;


-- Contribution of genders in sales

select 
      s.gender ,round(sum(r.revenue),2) as rev
from sales_data s 
join revenue r on s.`invoice _id` = r.`invoice _id`
group by s.gender 
order by rev desc;

-- total number of customer_type by the gender

select 
      customer_type ,count(*) as total_female  
from sales_data 
where gender ='female'
group by customer_type;


select 
      customer_type ,count(*) as total_male 
from sales_data 
where gender ='male'
group by customer_type;

-- How many unique payment methods does the data have?
select  
     count(distinct payment) 
from sales_data;

-- What is the most common customer type?

select 
    customer_type ,count(*) as order_times
from sales_data
group by customer_type
order by order_times desc;

-- Which gender is purchasing most?

select
        gender , count(*) as total_order
from sales_data
group by gender 
order by total_order desc;

-- What is the gender distribution per branch? //stored procedure

select 
     gender, count(*) 
from sales_data
where branch = 'C' 
group by gender ;

-- Which day of the week has the most sales by branch? 

select 
    day_name ,round(sum( r.revenue),1) as total_sales
from sales_data s 
inner join revenue r on s.`invoice _id` = r.`invoice _id`
where branch ='A'
group by day_name 
order by total_sales desc;
 

