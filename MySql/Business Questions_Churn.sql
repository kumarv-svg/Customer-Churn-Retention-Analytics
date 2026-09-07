USE customer_churn_analytics;

-- How many total customers are in the database?
SELECT DISTINCT COUNT(*)
FROM customers;

-- How many customers are Active?
SELECT COUNT(*)
FROM customers
WHERE customer_status = 'Active';

-- How many customers are Inactive?
SELECT COUNT(*)
FROM customers
WHERE customer_status = 'Inactive';

-- How many customers belong to each customer segment?
SELECT customer_segment, COUNT(*) Total_Customers
FROM customers
GROUP BY customer_segment;

-- What is the average annual income by customer segment?
SELECT customer_segment, ROUND(AVG(annual_income), 2) avg_income
FROM customers
GROUP BY customer_segment;

-- How many customers are there in each region?
SELECT region, COUNT(*) Total_Customers
FROM customers
GROUP BY region
ORDER BY Total_Customers DESC;

-- What is the overall customer churn rate?
SELECT ROUND((SUM(churn_flag)/ COUNT(*)) * 100, 2) Overall_Churn_Rate
FROM customers;

-- Which customer segment has the highest churn rate?
SELECT customer_segment, ROUND((SUM(churn_flag)/ COUNT(*)) * 100, 2) Overall_Churn_Rate
FROM customers
GROUP BY customer_segment
ORDER BY Overall_Churn_Rate DESC
LIMIT 1;

-- Which subscription plan generates the highest total net revenue?
SELECT s.plan_name, SUM(t.net_amount) as Total_net
FROM subscriptions s
INNER JOIN transactions t
	ON t.subscription_id = s.subscription_id
GROUP BY s.plan_name
ORDER BY Total_net DESC
LIMIT 1;

-- What is the average monthly fee for each plan?
SELECT plan_name, ROUND(AVG(monthly_fee), 2) avg_monthly_fee
FROM subscriptions
GROUP BY plan_name
ORDER BY avg_monthly_fee DESC;

-- Which payment method has the highest number of failed transactions?
SELECT payment_method, COUNT(*) total_failed_transactions
FROM transactions
GROUP BY payment_method
ORDER BY total_failed_transactions DESC
LIMIT 1;

-- What is the average number of support tickets per customer?
SELECT customer_id, COUNT(*) total_tickets
FROM support_tickets
GROUP BY customer_id
ORDER BY total_tickets DESC;

-- Which service-usage level has the highest churn rate?
SELECT service_usage_level, ROUND(((SUM(churn_flag) / Count(*)) * 100), 2) overall_churn_rate
FROM service_usage
GROUP BY service_usage_level
ORDER BY overall_churn_rate DESC
LIMIT 1;

-- What are the top 5 churn reasons by number of churned customers?
SELECT churn_reason, COUNT(*) as churned_customers
FROM churn_history
GROUP BY churn_reason
ORDER BY churned_customers DESC
LIMIT 5;

-- Which region has the highest average customer satisfaction?
SELECT c.region Region, ROUND(AVG(cf.satisfaction_score), 2) as avg_satisfaction_score
FROM customers c
RIGHT JOIN customer_feedback cf
	ON cf.customer_id = c.customer_id
GROUP BY c.region
ORDER BY avg_satisfaction_score DESC
LIMIT 1;

-- Find the top 5 customers by total net revenue and show their plan and region?
SELECT c.customer_id, c.region, s.plan_name, SUM(t.net_amount) as total_net_value
FROM transactions t
JOIN subscriptions s
	ON s.subscription_id = t.subscription_id
JOIN customers c
	ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.region, s.plan_name
ORDER BY total_net_value DESC
LIMIT 5;

-- Rank subscription plans by total revenue using a window function?
SELECT s.plan_name, SUM(t.net_amount) RowNumber, 
	ROW_NUMBER() OVER(ORDER BY SUM(t.net_amount) DESC) total_net
FROM subscriptions s
JOIN transactions t
	ON t.subscription_id = s.subscription_id
GROUP BY s.plan_name;

-- Find customers who have churned but generated above-average revenue before churn?
SELECT AVG(net_amount)
FROM transactions;

-- Find the top 3 regions by revenue at risk from churned customers.
WITH monthly_revenue_at_risk AS (
	SELECT c.customer_id, c.region, SUM(s.monthly_fee) monthly_revenue_risk
	FROM customers c
	JOIN subscriptions s
		ON s.customer_id = c.customer_id
	WHERE c.churn_flag = 1
	GROUP BY c.customer_id, c.region
)
SELECT mr.region, SUM(mr.monthly_revenue_risk) as Monthly_Risk
FROM monthly_revenue_at_risk mr
GROUP BY mr.region
ORDER BY Monthly_Risk DESC
LIMIT 3;

-- Compare churn rate between customers with low, medium and high service usage.
SELECT service_usage_level, 
(COUNT(DISTINCT CASE WHEN churn_flag = 1 THEN customer_id END) / COUNT(DISTINCT customer_id)) * 100 as churn_rate
FROM service_usage
GROUP BY service_usage_level
ORDER BY churn_rate DESC;
