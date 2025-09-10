# Ola Data Analytics

## Tools: SQL,Excel, Power BI

## Dashboard Link: [![Ola Dashboard Preview](dashboard-preview.png)](https://app.powerbi.com/reportEmbed?reportId=5d41a86f-0009-4172-b571-1dc6bdc015d0&autoAuth=true&ctid=11a2b842-29b4-4064-b490-7a8f18fae202)

## GitHub Link: [Check SQL Queries, and more from here](url)

## View Data Schema: [Data Schema](https://github.com/prashanthkumarjoshi/Ola_Data_Analysis_project/blob/main/Ola%20Database%20Schema%20(1).pdf)

## Dataset: [Oladataset](https://raw.githubusercontent.com/prashanthkumarjoshi/Ola_Data_Analysis_project/refs/heads/main/OlaData.csv)

## Project Overview

This project focuses on analyzing Ola’s ride data to uncover key trends in booking success, cancellations, customer satisfaction, and operational efficiency. Using SQL, it extracts insights on ride volume, payment methods, ratings, and cancellation reasons, while Power BI visualizations bring clarity to patterns in ride distance, booking status, and revenue breakdowns. The analysis compares customer and driver behavior to identify service gaps and loyalty indicators, and evaluates vehicle performance to optimize fleet usage. By integrating transactional and behavioral data, the project aims to support data-driven decisions that enhance customer experience, streamline operations, and boost overall profitability.

## Objectives

1. Analyze booking patterns to identify trends in successful, cancelled, and incomplete rides.  
2. Evaluate customer and driver behavior through ratings and cancellation reasons.  
3. Measure vehicle performance based on ride distance and service type.  
4. Assess payment method preferences and their impact on revenue.  
5. Identify high-value customers and loyalty indicators using booking frequency and value.  
6. Visualize operational metrics to support data-driven decision-making and service optimization.

## Q1. Write a Query to find the top 5   most frequently ordered dishes by customer called  "Akhil Reddy" in the last 1 year.
<details><summary>
<strong>Description</strong>: Return the records of last 1 year with customer_id, customer_name,dishes and total count of dishes.</summary>
<br><strong>SQL Code</strong>

  ```sql

  SELECT
    customer_name,
    dishes,
    total_dishes
  FROM
    (SELECT
        c.customer_id,
        c.customer_name,
        o.order_item AS dishes,
        COUNT(order_id) AS total_dishes,
        DENSE_RANK() OVER (ORDER BY COUNT(order_id) DESC) AS RANK
      FROM
        orders o
        JOIN customers c ON o.customer_id = c.customer_id
      WHERE
        o.order_date >= CURRENT_DATE - INTERVAL '1 Year'
        AND c.customer_name = 'Akhil Reddy'
      GROUP BY
        1,
        2,
        3
      ORDER BY
        1,
        4 DESC
    ) AS t1
  WHERE
    RANK <= 5;
  ```
</details>
<details>
<summary><strong>Expected Output</strong>: A list of top 5 most frequently orderd dishes by Customer Name called "Akhil Reddy".</summary>
<br><strong>Query Output</strong>
 <br> <img src="https://github.com/prashanthkumarjoshi/SQL_PROJECT_3/blob/main/images/Q_1_output.png" height="200">
</details>
    
