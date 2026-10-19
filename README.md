# Brazilian E-Commerce Data Analysis | Olist

## Project Overview

In this project, I analyzed the Brazilian E-Commerce Public Dataset by Olist to understand sales performance, customer purchasing behavior, delivery performance, customer reviews and seller activity.

I used PostgreSQL and SQL to explore the data, check relationships between tables and prepare metrics for reporting. I then connected the analysis to Power BI and built a four-page dashboard to present the main findings.

My goal was to understand not only how much revenue the business generated, but also which product categories performed well, how frequently customers returned, and whether delivery performance was associated with customer satisfaction.

## Tools and Technologies

* **PostgreSQL** : database management and SQL analysis
* **pgAdmin** : managing the database and running queries
* **SQL** : data validation, joins, aggregations, and analytical views
* **Power BI Desktop** : interactive dashboards and visual reporting
* **DAX** : calculated measures and report calculations
* **GitHub** : project documentation and version sharing

## Dataset

I used the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), available on Kaggle.

The dataset contains information about orders, customers, products, sellers, payments, reviews, and geographic locations. These tables allowed me to compare business performance across different parts of the e-commerce process.

### Dataset availability

The file `olist_geolocation_dataset.csv` is not included in this repository because it exceeds GitHub's browser upload limit.

To reproduce the analysis, download the original dataset from Kaggle and place the CSV files in your local project folder before importing them into PostgreSQL. Other smaller CSV files may be included in the repository.

## Data Preparation and Validation

Before building the dashboards, I checked the imported tables, reviewed row counts, and examined relationships between the datasets. I also checked for orphaned records in selected relationships and investigated duplicate review identifiers before finalizing the review table.

Some of the main table counts were:

| Table          |      Rows |
| -------------- | --------: |
| Customers      |    99,441 |
| Geolocation    | 1,000,163 |
| Order items    |   112,650 |
| Order payments |   112,650 |
| Orders         |    99,441 |
| Order reviews  |    99,224 |
| Products       |    32,951 |
| Sellers        |     3,095 |

The review count reflects the prepared table used in this analysis.

I also checked the order status distribution and the date range of the available orders. The order dates in the dataset range from September 2016 to October 2018.

During this stage, I paid attention to how joins affected the results. Some views use different subsets of orders, so their totals do not always match the overall order count exactly.

## SQL Analysis

I used SQL to examine the main business metrics and prepare data for Power BI. My analysis covered:

* Overall product revenue, freight, order count, and average order value
* Monthly revenue and order trends
* Product category performance
* State-level revenue and order activity
* Customer purchasing patterns
* Payment method usage and payment value
* Delivery duration and late deliveries
* Customer review scores
* Seller revenue and order performance

I created analytical views, including `vw_overall_kpis`, `vw_monthly_sales`, `vw_total_orders`, and `vw_payment_performance`, to make the results easier to use in the report.

The SQL scripts are available in the `sql/` folder.

## Power BI Dashboard

I organized the report into four pages so that each page focuses on a different business question.

### 1. Executive Overview

This page provides a summary of overall business performance.

**Key metrics**

* Total product revenue: **R$13.59 million**
* Total orders: **99,441**
* Total freight: **R$2.25 million**
* Average order value: **R$136.68**

I included a monthly revenue trend, the top 10 product categories by revenue, the top 10 states by revenue, and a breakdown of orders by status. A period slicer allows users to explore the monthly results.

![Executive Overview](screenshots/01-executive-overview.png)

### 2. Sales & Customer Analysis

On this page, I compared sales trends, customer purchasing behavior, product category revenue, and payment methods.

One finding was the difference between one-time and repeat customers in the customer classification used for the report. One-time customers represented approximately **96.88%**, while repeat customers represented approximately **3.12%**.

I also found that the health and beauty category generated around **R$1.26 million** in product revenue. Credit cards accounted for the largest share of recorded payment value.

The page includes monthly revenue, monthly order volume, top product categories, customer type distribution, revenue by payment method, and order counts by payment method.

![Sales and Customer Analysis](screenshots/02-sales-customer-analysis.png)

**Payment method note**

While checking payment performance, I found that adding the order counts across payment methods produced a total higher than the number of unique orders. This is because an order can use multiple payment methods. The category counts therefore overlap and should not be interpreted as unique orders when added together.

### 3. Delivery & Customer Experience

For this page, I compared delivery performance with customer review scores to see whether the two were associated in the dataset.

The average delivery time was approximately **12.55 days**, and the delivery KPI view showed a late delivery rate of around **8.11%**.

I found a noticeable difference in average review scores: approximately **2.57 for late deliveries** compared with **4.29 for on-time deliveries** in the review analysis.

I also compared revenue, average order value, order volume, and delivery performance across states. These comparisons help identify regions that may deserve closer investigation.

![Delivery and Customer Experience](screenshots/03-delivery-customer-experience.png)

The results show an association between delivery status and customer ratings, but they do not prove that delivery delays alone caused lower review scores. The metric totals can also vary between views depending on which records are included.

### 4. Seller Performance

On this page, I compared sellers by revenue and order activity and explored how seller performance varied geographically.

The dashboard reports:

* Total sellers: **3,095**
* Total orders: **99,441**
* Total product revenue: **R$13.59 million**
* Items sold: **112,650**

I included the top 10 sellers by revenue, the top 10 sellers by order count, seller revenue versus items sold by state, seller revenue by state, the number of sellers by state, and average item price by state.

I found that the five highest-revenue sellers generated approximately **R$1.04 million**, or about **7.61% of total product revenue**.

![Seller Performance](screenshots/04-seller-performance.png)

This comparison shows that seller contributions vary and provides a starting point for further analysis of seller activity and performance.

## Key Findings

After comparing the results across the four dashboard pages, I identified several patterns worth investigating further.

### Product categories contribute differently to revenue

Some categories generate considerably more product revenue than others. This makes category-level reporting useful when deciding where to focus inventory planning and marketing efforts.

### Repeat purchasing is relatively limited

The customer classification showed a much larger share of one-time customers than repeat customers. This suggests an opportunity to investigate customer retention, although the result depends on the definition used to classify repeat customers.

### Delivery performance is associated with customer satisfaction

The difference in average review scores between late and on-time deliveries stood out in the analysis. Delivery reliability is therefore an area worth investigating alongside customer feedback.

### Payment methods have different levels of usage

Credit cards accounted for the largest share of recorded payment value. Other payment methods also contributed, and their order counts need to be interpreted with the overlap between payment categories in mind.

### Seller performance varies

The comparison of seller revenue and order activity showed differences in seller contributions. Looking more closely at these differences could help identify patterns in seller performance.

### Performance differs across states

Revenue, order volume, and late-delivery rates varied geographically. These differences provide a starting point for further investigation into regional sales and logistics performance.

## Recommendations

Based on the patterns I found, I would investigate the following areas:

1. **Customer retention:** Look more closely at repeat purchasing and test ways to encourage customers to return.
2. **Delivery performance:** Investigate states with higher late-delivery rates and review possible logistics bottlenecks.
3. **Product categories:** Use revenue trends to help prioritize inventory and marketing efforts.
4. **Seller performance:** Compare seller revenue and order activity to understand the differences between high-performing and other sellers.
5. **Payment experience:** Monitor payment method usage and checkout performance while accounting for orders that use multiple payment methods.

These are recommendations based on the observed data. Further analysis would be needed to evaluate their potential impact.

## Metric Definitions and Notes

To make the dashboard results easier to interpret, I used the following definitions and considerations:

* **Product revenue:** Sum of product item prices, excluding freight.
* **Freight:** Sum of recorded freight charges for order items.
* **Average order value:** The overall KPI is approximately R$136.68, as calculated in the analytical view.
* **Total orders:** The overall order KPI counts distinct orders from the orders table.
* **Orders by payment method:** Counts distinct orders within each payment category. An order can appear in multiple categories.
* **Late delivery rate:** Calculated within the scope of the delivery analysis and its eligible orders.
* **Review metrics:** Calculated from the review records included in the relevant analysis.

I checked these metric definitions because different joins and record eligibility rules can affect the totals shown in individual visuals. For example, monthly sales views based on order items may exclude orders without associated items, while the overall order KPI counts orders from the orders table.

## Project Structure

```text
Olist-dataset/
├── sql/
│   └── analysis_queries.sql
├── powerbi/
│   └── Olist_Analysis.pbix
├── screenshots/
│   ├── 01-executive-overview.png
│   ├── 02-sales-customer-analysis.png
│   ├── 03-delivery-customer-experience.png
│   └── 04-seller-performance.png
└── README.md
```

The repository may also contain smaller CSV files. The large geolocation CSV is downloaded separately from Kaggle.

## How to Reproduce the Analysis

1. Download the [Brazilian E-Commerce Public Dataset by Olist from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
2. Extract the CSV files into a local project folder.
3. Create a PostgreSQL database and import the required tables.
4. Run the SQL scripts in the `sql/` folder to create the analytical views and perform the analysis.
5. Open `Olist_Analysis.pbix` in Power BI Desktop.
6. Update the PostgreSQL connection settings to match your local environment.
7. Refresh the report and explore the four dashboard pages.

Database settings, connection details, and local file paths may need to be adjusted for your setup.

## What I Learned

Working through this project gave me practical experience with relational data, SQL analysis, data validation, and Power BI reporting.

One important lesson was to check how a metric is calculated before interpreting it. I found that overlapping payment method counts and differences in join scope can affect totals, even when the underlying data is correct. Understanding those details helped me present the dashboard results more clearly.

The project also gave me experience connecting SQL analysis to business questions and presenting the results in a format that users can explore.

## Author

**Arista Kayirangwa Aimee**

Data analysis portfolio project using PostgreSQL, SQL and Power BI.
