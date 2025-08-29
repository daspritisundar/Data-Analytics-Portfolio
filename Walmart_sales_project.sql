select * from walmart_updated_data;
select count(*) from walmart_updated_data;
select 
      payment_method,
      count(*)
from walmart_updated_data
group by payment_method;

select count(distinct Branch) as 'no of branch'
from walmart_updated_data;

select max(Quantity) from walmart_updated_data;

#Business Problems
##Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select payment_method,
      count(*) as no_of_payments,
      sum(quantity)as no_of_quantity_sold
from walmart_updated_data
group by payment_method;

## Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

select * from walmart_updated_data;
select branch, category,avg_rating
from 
(select 
	 Branch,
     category, 
     AVG(rating) as avg_rating,
     RANK()over(partition by Branch order by avg(rating) desc) as rnk
   from walmart_updated_data
	group by Branch,category
)as ranked
where rnk= 1;
 
 
 ## Q3: Identify the busiest day for each branch based on the number of transactions

SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart_updated_data
    GROUP BY branch, day_name
) AS ranked
WHERE rnk = 1;


## Q4: Calculate the total quantity of items sold per payment method

select payment_method,
sum(quantity) as quantity_of_items_sold
from walmart_updated_data
group by payment_method;

## Q5: Determine the average, minimum, and maximum rating of categories for each city

select 
      city,
      category,
      avg(rating) as avg_rating,
      min(rating) as min_rating,
      max(rating) as max_rating 
	from walmart_updated_data
    group by city, category;


## Q6: Calculate the total profit for each category

select 
     category,
     sum(total_price*profit_margin) as total_profit
	from walmart_updated_data
    group by category
    order by total_profit desc;

## Q7: Determine the most common payment method for each branch

select Branch,
       payment_method as Preffered_Payment_method
from(

   SELECT 
        Branch,
        payment_method,
        COUNT(payment_method) AS no_payment_method,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart_updated_data
    GROUP BY branch, payment_method
    )as ranked
where rnk=1;

## Q8: Categorize sales into Morning, Afternoon, and Evening shifts

 select * from walmart_updated_data;

SELECT
    Branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart_updated_data
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

##Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
with 2022_revenue as 
(SELECT 
    Branch,
    SUM(total_price) AS revenue,
    YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS yr
FROM walmart_updated_data
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
GROUP BY  Branch,YEAR(STR_TO_DATE(date, '%d/%m/%Y'))
order by Branch 
),
2023_revenue as
(SELECT 
    Branch,
    SUM(total_price) AS revenue,
    YEAR(STR_TO_DATE(date, '%d/%m/%Y')) AS yr
FROM walmart_updated_data
WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
GROUP BY  Branch,YEAR(STR_TO_DATE(date, '%d/%m/%Y'))
order by Branch)

select 
	r2022.Branch,
    r2022.revenue as last_yr_revenue,
    r2023.revenue as current_yr_revenue,
    ((r2022.revenue-r2023.revenue)/r2022.revenue)*100 as revenue_decrease_ratio
from 2022_revenue as r2022 join 2023_revenue as r2023 on r2022.Branch=r2023.Branch
where r2022.revenue>r2023.revenue
order by revenue_decrease_ratio desc
limit 5;

      
      

  



