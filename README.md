# IBM Employee Attrition & Workforce Insights

### End-to-End Analytics Project | Snowflake + Power BI

**Enterprise-style HR analytics solution demonstrating a complete BI pipeline:**
CSV → Snowflake Data Warehouse → Dimensional Model → Power BI Semantic Model → Interactive Dashboard

---

## 🔗 Live Dashboard

Explore the interactive dashboard here:👉 [  View   ](https://app.powerbi.com/view?r=eyJrIjoiMzE3ZmNiODYtMzk1Mi00MTc0LTg5NDUtZDQyNDc4M2U3ZjgxIiwidCI6ImRjODhkNWNiLWMxMjEtNDUzYi1hMGRiLTFmMzlmYjEyMjJiMyJ9)

---

## About This Project

Employee attrition is a critical challenge for organizations, directly impacting **recruitment costs, workforce stability, productivity, and knowledge retention**.
This project delivers an **end-to-end HR analytics solution** built using **Snowflake as the cloud data warehouse** and **Power BI for reporting and visualization**.

The goal was not just to visualize HR data, but to design a **real-world, enterprise-aligned BI workflow**, including:

* Raw data ingestion
* Data quality validation and cleansing
* Dimensional modeling (star schema)
* Business-ready KPIs
* Insight-driven dashboards for HR leadership

The project mirrors how HR analytics is implemented in modern organizations, clearly separating:

* **Data engineering (Snowflake SQL)**
* **Analytical modeling (Fact & Dimensions)**
* **Business intelligence (Power BI + DAX)**

---

## Problem Statement

Organizations often collect large volumes of employee data, but without a centralized and validated analytics system, HR teams struggle to answer critical questions such as:

* Which employee groups are leaving the organization most frequently?
* How does attrition vary by **experience level, department, job role, and overtime**?
* Are junior or low-income employees at higher risk?
* What operational factors (distance, overtime, business travel) influence attrition?
* How far is current attrition from the company’s target?

The absence of structured analytics leads to **reactive HR decisions**, increased hiring costs, and reduced workforce stability.

This project addresses these challenges by building a **scalable HR analytics foundation** and delivering **executive-ready insights** through Power BI.

---

## Objectives

* Build a **Snowflake-based HR data warehouse** from raw CSV data
* Perform **data quality checks, cleansing, and deduplication** using SQL
* Design a **star schema** optimized for analytics
* Derive **business attributes** such as experience level and income band
* Develop **DAX-based KPIs** for attrition analysis
* Create a **multi-page Power BI dashboard** for HR decision-makers

---

## Architecture (End-to-End Flow)

```
CSV Files
   ↓
Snowflake Data Warehouse
   RAW → STAGING → CLEAN
   ↓
Dimensional Model (Fact & Dimensions)
   ↓
Power BI (Import Mode)
   ↓
Interactive HR Analytics Dashboards
```
![image alt](https://github.com/SatyaGanesh07/employee-attrition-analytics-snowflake-powerbi/blob/243cce7ce44af171dd6f66173152de144823d4fc/Dashboard/Architecture.png)

---

## End-to-End Methodology

### 1. Data Ingestion (CSV → Snowflake)

* Raw IBM HR employee CSV loaded into Snowflake
* Source data preserved in a **RAW layer** without modification

### 2. Data Quality & Validation (Snowflake SQL)

Comprehensive checks were performed, including:

* Null value detection (gender, business travel, etc.)
* Duplicate employee records
* Invalid numeric ranges (age, satisfaction scores, income)
* Logical consistency checks:

  * `YearsAtCompany ≤ TotalWorkingYears`
  * `YearsInCurrentRole ≤ YearsAtCompany`
* Attrition domain validation (`Yes / No`)

### 3. Data Cleansing & Standardization

* Standardized text fields (gender, department, job role)
* Handled missing values (`UNKNOWN`, default categories)
* Deduplicated employees using business rules
* Ensured analytics-ready, trusted data

### 4. Dimensional Modeling (Star Schema)

* **Fact Table:** `fct_hr_employee`
* **Dimension Tables:**

  * `dim_employee`
  * `dim_job`
  * `dim_work_arrangement`

Derived business attributes:

* **Experience Level:** Junior / Mid / Senior
* **Income Band:** Low / Medium / High
* **Attrition Flag:** Binary indicator for analytics

---

## Snowflake Architecture

**Database:** `ibm_hr_db`
**Schema:** `analytics`

**Layered Design:**

* `raw_hr_employees` – direct CSV ingestion
* `stg_hr_employees` – standardized & validated data
* `cln_hr_employees` – deduplicated, analytics-ready data
* Dimension & Fact tables for BI consumption

This layered approach ensures **traceability, auditability, and scalability**.

---

## Dashboard Overview (3 Pages)

### 1️) Overview

**Purpose:** Executive-level snapshot of workforce health

![image alt](https://github.com/SatyaGanesh07/employee-attrition-analytics-snowflake-powerbi/blob/243cce7ce44af171dd6f66173152de144823d4fc/Dashboard/Overview%201.png)

---

### 2️) Attrition Drivers

**Purpose:** Identify *why* employees are leaving

![image alt](https://github.com/SatyaGanesh07/employee-attrition-analytics-snowflake-powerbi/blob/243cce7ce44af171dd6f66173152de144823d4fc/Dashboard/Attrition%20driver.png)

---
### 3️) Conclusion

**Purpose:** Translate insights into business understanding

![image alt](https://github.com/SatyaGanesh07/employee-attrition-analytics-snowflake-powerbi/blob/243cce7ce44af171dd6f66173152de144823d4fc/Dashboard/Conclusion.png)

### 4) Data Modeling 
![image alt](https://github.com/SatyaGanesh07/Employee-Attrition-Analytics-Snowflake-PowerBi/blob/95b7e1932bcd1d46cf8f18d5b62babae24270a76/Dashboard/Data%20Modeling.png)

---

## Tools & Technologies

* **Data Warehouse:** Snowflake
* **BI Tool:** Power BI (Desktop & Service)
* **Data Mode:** Import
* **Languages:** SQL, DAX
* **Modeling:** Star Schema
* **Domain:** HR Analytics

---

## Skills Demonstrated

* End-to-end BI project ownership
* Snowflake SQL (ETL, validation, transformations)
* Data quality and business rule enforcement
* Dimensional data modeling (fact & dimensions)
* Advanced DAX for HR KPIs
* Executive-focused dashboard design
* Translating analytics into business insights

---

## Key Business Insights

* **Junior employees show significantly higher attrition**, increasing recruitment and onboarding costs
* **Overtime strongly correlates with attrition**, indicating burnout risk
* **Low-income employees are disproportionately represented in high-risk attrition groups**
* Department-level attrition variation impacts **workforce stability**
* Early exits lead to **knowledge loss and reduced team productivity**

---

## Conclusion

This project demonstrates a **real-world HR analytics workflow**, going far beyond simple dashboard creation.

By leveraging **Snowflake for data validation, cleansing, and dimensional modeling**, the analysis ensures that attrition metrics are **accurate, explainable, and reproducible**.
Power BI builds on this foundation to deliver **interactive, decision-ready insights** for HR leaders.

Overall, the project reflects an **analytics engineering mindset**, combining data engineering, analytical modeling, and business intelligence—aligned with expectations for **Data Analyst / BI Analyst roles** in enterprise environments.

---

## Business Recommendations

* Strengthen retention programs for **junior and low-income employees**
* Monitor and manage **overtime workloads** proactively
* Use experience-based segmentation for targeted HR interventions
* Align compensation and growth paths to reduce early attrition
* Treat attrition analytics as a **continuous monitoring system**, not a one-time report

---

## Contact

For any questions or suggestions, please open an issue or contact me via LinkedIn:  
[Satya Ganesh LinkedIn](https://www.linkedin.com/in/satya-ganesh-5a89b2283/)
