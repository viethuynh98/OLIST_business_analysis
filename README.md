# OLIST_business_analysis
This repository contains scripts and SQL queries to process and analyze the OLIST dataset, focusing on geolocation data, customer and seller information, review translations, and order distance calculations. Additionally, Power BI dashboards are included to visualize business performance, customer sentiment, and the root causes of customer dissatisfaction.

## Overview
The OLIST dataset includes information about e-commerce transactions in Brazil. The main focus of this project is to clean and enhance the geolocation data, fix potential data quality issues with customer and seller records, translate Portuguese reviews to English reviews, calculate distances between sellers and customers using the Haversine formula, and create insightful dashboards in Power BI to help the business make data-driven decisions.

## Project Structure
- SQL Scripts: Scripts for cleaning geolocation data and fixing issues with customer and seller information.
- Python Scripts: Scripts for review translation, special character handling, and distance calculation using the Haversine formula.
- Power BI Dashboards: Dashboards to visualize key business insights, customer sentiment, and issues identified in customer reviews.
## Dataset Cleaning
1. Geolocation Data
  The geolocation table in the OLIST dataset contains latitude and longitude data for various locations in Brazil. However, some records have coordinates that are outside of Brazil but match valid Brazilian ZIP codes. This seems to be an error, possibly due to data entry mistakes.

  Steps Taken:
- Identified and removed records with invalid latitude and longitude data that were outside of Brazil, but still had matching Brazilian ZIP codes.
- Calculated average lat-long coordinates for each state in Brazil and replaced outliers with the state's average values.
  Removed duplicate or unused records to clean up the dataset.

2. Customer and Seller Geolocation
Some customer and seller records were missing geolocation data or were not present in the dataset due to potential typos in names or ZIP codes. To resolve this:

Filled missing geolocation data for customers and sellers by cross-referencing available data.
Handled incorrect or inconsistent data, ensuring all active customers and sellers had valid geolocation entries.
3. Review Translation
The reviews in the OLIST dataset were written in various languages. Since the primary language in Brazil is Portuguese, I used Google Translate to automatically translate reviews from Spanish and other languages into Portuguese. After translation:

Used Python scripts to clean special characters and ensure the reviews were properly formatted for analysis.

## Distance Calculation
I created a Python script named calculate_distance.py to calculate the distance between sellers and customers using the Haversine formula. This formula computes the shortest distance over the earth's surface, given the latitude and longitude of two points.

Steps:
- Extract latitude and longitude values from the cleaned geolocation dataset for both customers and sellers.
- Apply the haversine() function to calculate the distance between these two points in kilometers.
- Store the calculated distances for further analysis (e.g., understanding delivery times, cost implications).

## Power BI Dashboards
I developed several dashboards in Power BI to provide insights into the business's performance, customer sentiment, and key areas that need improvement. These dashboards analyze both structured and unstructured data (customer reviews).
1. Business Performance Dashboard
- Metrics:
  - Sales volume by product category
  - Revenue trends over time
  - Average order value by region
- Insights:
  - Identify top-performing product categories
  - Spot regional trends in sales and customer preferences
2. Customer Sentiment Analysis
By analyzing customer reviews, this dashboard helps gauge customer satisfaction and identifies positive and negative feedback trends.

- Metrics:
  - Overall sentiment scores (positive/negative/neutral) by product and logistics
  - Word clouds showing frequently used terms in reviews
  - Sentiment breakdown by product category and delivery time
- Insights:
  - Discover how product quality and logistics affect customer perception
  - Identify which products and services are receiving the most praise or criticism
3. Root Cause of Customer Dissatisfaction
This dashboard focuses on identifying the primary reasons behind negative reviews, helping the business pinpoint issues and take corrective actions.

- Analysis:
  - Reviews categorized by topic (e.g., product quality, delivery issues, wrong or missing items)
  - Word clouds highlighting common complaints (e.g., late delivery, damaged products)
  - Breakdown of issues by region and seller
- Insights:
  - Identify the most common issues such as late deliveries, incorrect items, or product quality complaints.
  - Analyze the frequency of specific issues across different regions or sellers to understand where improvements are needed.