CREATE DATABASE IF NOT EXISTS walmart_sales;

-- --------------------table creation + data wrangling: ensure no null values--------------------
CREATE TABLE IF NOT EXISTS sales (
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10, 2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6, 4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10, 2) NOT NULL,
gross_margin_percentage	FLOAT(11, 9),
gross_income DECIMAL(12, 4) NOT NULL,
rating FLOAT(2, 1)
);

SELECT*
FROM sales;

-- --------------------feature engineering: add new columns time_of_day, day_name, and month_name--------------------

-- time_of_day
SELECT
	time,
    (CASE 
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
	END
    ) time_of_day
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE 
		WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening' 
	END
);

-- day_name
SELECT
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name
SELECT
	date,
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

SELECT*
FROM sales;

-- --------------------exploratory data analysis (EDA)--------------------

-- --------------------generic questions--------------------
-- 1. How many unique cities does the data have?
SELECT 
	COUNT(DISTINCT city) num_of_distinct_cities
FROM sales;

-- 2. In which city is each branch?
SELECT
	DISTINCT city,
    branch
FROM sales;

-- --------------------product questions--------------------
-- 1. How many unique product lines does the data have?
SELECT 
	COUNT(DISTINCT product_line) num_of_distinct_prod_line
FROM sales;

-- 2. What is the most common payment method?
SELECT
	payment_method,
    COUNT(*) count_of_pmt_method
FROM sales
GROUP BY payment_method
ORDER BY count_of_pmt_method DESC
LIMIT 1;

-- 3. What is the most selling product line?
SELECT
	product_line,
    COUNT(*) count_of_prod_line
FROM sales
GROUP BY product_line
ORDER BY count_of_prod_line DESC
LIMIT 1;

-- 4. What is the total revenue by month?
SELECT 
	month_name month,
    ROUND(SUM(total),2) total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- 5. What month had the largest COGS?
SELECT 
	month_name month,
    SUM(cogs) total_cogs
FROM sales
GROUP BY month_name
ORDER BY total_cogs DESC
LIMIT 1;

-- 6. What product line had the largest revenue?
SELECT
	product_line,
    ROUND(SUM(total),2) total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;

-- 7. What is the city with the largest revenue?
SELECT
	city,
    ROUND(SUM(total),2) total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;

-- 8. What product line had the largest VAT?
SELECT
	product_line,
    ROUND(AVG(VAT),2) avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC
LIMIT 1;

-- 9. Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- 10. What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(*) total_count
FROM sales
GROUP BY gender, product_line
ORDER BY total_count DESC;

-- 11. What is the average rating of each product line?
SELECT
	product_line,
    ROUND(AVG(rating),2) avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- --------------------sales questions--------------------
-- 1. Number of sales made in each time of the day per weekday
SELECT
	day_name,
	time_of_day,
    COUNT(*) num_of_sales
FROM sales
WHERE day_name IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
GROUP BY day_name, time_of_day;

-- 2. Which of the customer types brings the most revenue?
SELECT
	customer_type,
    ROUND(SUM(total),2) total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;

-- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
	city,
    ROUND(AVG(VAT),2) avg_tax
FROM sales
GROUP BY city
ORDER BY avg_tax DESC
LIMIT 1;

-- 4. Which customer type pays the most in VAT?
SELECT
	customer_type,
	ROUND(AVG(VAT),2) avg_tax
FROM sales
GROUP BY customer_type
ORDER BY avg_tax DESC
LIMIT 1;

-- --------------------customer questions--------------------
-- 1. How many unique customer types does the data have?
SELECT
	COUNT(DISTINCT customer_type) num_of_cust_type
FROM sales;

-- 2. How many unique payment methods does the data have?
SELECT
	COUNT(DISTINCT payment_method) num_of_pmt_method
FROM sales;

-- 3. What is the most common customer type?
SELECT
	customer_type,
    COUNT(*) count_of_cust_type
FROM sales
GROUP BY customer_type
ORDER BY count_of_cust_type DESC
LIMIT 1;

-- 4. What is the gender of most of the customers?
SELECT
	gender,
    COUNT(*) gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC
LIMIT 1;

-- 5. What is the gender distribution per branch?
SELECT
	branch,
    gender,
    COUNT(*) gender_distr_per_branch
FROM sales
GROUP BY branch, gender
ORDER BY branch, gender;

-- 6. Which time of the day do customers give highest ratings?
SELECT
	time_of_day,
    AVG(rating) avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- 7. Which time of the day do customers give most ratings per branch?
SELECT
	branch,
    time_of_day,
    AVG(rating) avg_rating
FROM sales
GROUP BY branch, time_of_day
ORDER BY branch, avg_rating DESC;

-- 8. Which day of the week has the best avg ratings?
SELECT
	day_name,
    AVG(rating) avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC
LIMIT 1;

-- 9. Which day of the week has the best average ratings per branch?
SELECT
	branch,
	day_name,
    AVG(rating) avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;