# SQL & Power BI Retail Analysis

This project explores customer segmentation, revenue distribution, and product revenue across 38 countries. This project combines SQL queries for data exploration and the use of Power BI to deliver insights into spending tiers and customer segments.

---

## Query Types and Business Questions Answered

**Data Cleaning & Preprocessing**
- Format the invoice date and remove invalid entries such as negative quantities or unit prices
- Create a cleaned table (`cleanedTable`) to not remove original table for use in all subsequent analysis. The original table will be used for analysis to better understand returned products

**Revenue Analysis**
- What is the total spending, transaction count, and average spending per transaction by country?
- What is the monthly revenue trend across countries?

**Customer Segmentation**
- What is the difference in revenue and behavior between **engaged** (≥5 purchases) and **casual** customers?
- What % of revenue and transactions come from each group?

**Product Concentration**
- How much revenue comes from top products in each country?
- What is the gap between product unit share and revenue share?
---

## SQL Techniques Used
- **Data Cleaning**: Removing invalid transactions and formatting timestamps
- **Window Functions**: `ROW_NUMBER()`, `SUM() OVER`, `COUNT() OVER`
- **Subqueries & CTEs**: Modular query structure for clarity and reuse
- **Join Logic**: Used to combine product and country-level aggregates

## Power BI Techniques Used
- **Dynamic Titles**: Titles built using custom DAX measures (`SELECTEDVALUE`) that update automatically based on the slicer selection
- **Slicer Logic**: Tier based filters with visual interactions
 
## Dashboard Screenshot ![Online Retail Dashboard - Top Tier](https://github.com/user-attachments/assets/0a1c71e5-84ca-4165-a648-90f9a22e7657)

