--Project: Zepto Analyzing Revenue and inventory
--1.Database setup
drop table if exists zepto;
create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity integer,
discountedSellingPrice NUMERIC(8,2)
weightInGms integer,
outOfStock BOOLEAN,
quantity integer

);
--2.Data exploration
--counts of rows
select count(*) from zepto;
--sample data 
select * from zepto
limit 10;
--null values
select * from zepto 
where name IS NULL 
or 
category  is null
or
mrp is null
or
discountpercent is null
or
availablequantity is null
or
discountedsellingprice is null
or 
weightingms is null
or
outofstock is null
or
quantity is null;

--seeing unique products
select distinct category from zepto
order by category;
--data cleaning
--products with price 0;
select * from zepto
where mrp=0;
--need to delete this row
DELETE FROM zepto 
where mrp=0;
--convert paise to rupies
update zepto
set mrp= mrp/100.0,
discountedsellingprice=discountedsellingprice/100;
--4.buisness analysis
--find the top 10 value product by the discountpercentage
select distinct name ,mrp,discountpercent from zepto
order by discountpercent desc
limit 10;
--what are the product with high mrp but out of stock
select distinct name,mrp from zepto
where mrp >250 and outofstock = TRUE
order by mrp desc;
--''company needs to restock this product to get more revenue.
--higest discounts
SELECT category, MAX(discountpercent) AS max_discount
FROM  zepto 
GROUP BY category
order by max_discount DESC
limit 5;

--seeing if there is out of stock or in stock
SELECT 
    CASE 
        WHEN outofstock = true THEN 'Out of Stock'
        ELSE 'In Stock'
    END AS availability_status,
    COUNT(sku_id) AS total_items
FROM zepto
GROUP BY outofstock;
-- find the top 5 categories offering the highest average discount percentage
select category,round(avg(discountpercent),2) as discount from zepto
group by category 
order by discount desc
limit 5;
--Revenue analysis
select
   category,
   sum(discountedsellingprice * availablequantity) as total_revenue
from zepto
group by category
order by total_revenue desc;
--Potential revenue vs Actual revenue 
 SELECT
    category,
    SUM(mrp * quantity) AS potential_revenue,
    SUM(discountedsellingprice * quantity) AS actual_revenue,
    SUM((mrp - discountedsellingprice) * quantity) AS total_discount_given
FROM zepto
GROUP BY category
ORDER BY total_discount_given DESC;
-- Weight Categorization for Logistics (Used in Tableau Treemap)
SELECT name, weightingms,
    CASE 
        WHEN weightingms < 1000 THEN 'Low'
        WHEN weightingms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category 
FROM zepto;
-- what is the total inventory weight per category;
 select category , sum(weightingms *availablequantity) as total_inventory
 from zepto 
 group by category 
 order by total_inventory ;

