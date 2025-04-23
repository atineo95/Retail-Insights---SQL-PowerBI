# SQL Exploration

This folder contains exploratory SQL queries that are used to understand customer behavior, revenue trends, and engagement patterns across 38 countries.

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

## Techniques Used
- **Data Cleaning**: Removing invalid transactions and formatting timestamps
- **Window Functions**: `ROW_NUMBER()`, `SUM() OVER`, `COUNT() OVER`
- **Subqueries & CTEs**: Modular query structure for clarity and reuse
- **Join Logic**: Used to combine product and country-level aggregates
