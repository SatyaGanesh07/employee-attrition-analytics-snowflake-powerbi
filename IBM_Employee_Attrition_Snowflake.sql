

   /*    IBM HR Analytics Project  */

------------------------ Database & Schema ---------------------------------------
USE WAREHOUSE IBM_EMPLOYEES;
CREATE OR REPLACE DATABASE ibm_hr_db;
CREATE OR REPLACE SCHEMA ibm_hr_db.analytics;

USE DATABASE ibm_hr_db;
USE SCHEMA analytics;

-----  RAW TABLE: Direct ingestion from CSV ------
CREATE OR REPLACE TABLE raw_hr_employees (
    EmployeeNumber INT,
    Age INT,
    Attrition STRING,
    BusinessTravel STRING,
    DailyRate INT,
    Department STRING,
    DistanceFromHome INT,
    Education INT,
    EducationField STRING,
    EmployeeCount INT,
    EnvironmentSatisfaction INT,
    Gender STRING,
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole STRING,
    JobSatisfaction INT,
    MaritalStatus STRING,
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 STRING,
    OverTime STRING,
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);

select * from raw_hr_employees;

select COUNT_IF(gender IS NULL)AS gender_nulls from raw_hr_employees; -- 64 nulls

------------- Staging Table ------------------
CREATE OR REPLACE TABLE stg_hr_employees AS
SELECT
    EmployeeNumber            AS employee_number,
    Age                       AS age,
    Attrition                 AS attrition,
    UPPER(TRIM(BusinessTravel)) AS business_travel,
    DailyRate                 AS daily_rate,
    UPPER(TRIM(Department))   AS department,
    DistanceFromHome          AS distance_from_home,
    Education                 AS education,
    UPPER(TRIM(EducationField)) AS education_field,
    EnvironmentSatisfaction  AS environment_satisfaction,

    CASE
    WHEN UPPER(TRIM(Gender)) IN ('M', 'MALE') THEN 'Male'
    WHEN UPPER(TRIM(Gender)) IN ('F', 'FEMALE') THEN 'Female'
    ELSE NULL
END AS gender,


    HourlyRate                AS hourly_rate,
    JobInvolvement            AS job_involvement,
    JobLevel                  AS job_level,
    UPPER(TRIM(JobRole))      AS job_role,
    JobSatisfaction           AS job_satisfaction,
    UPPER(TRIM(MaritalStatus)) AS marital_status,
    MonthlyIncome             AS monthly_income,
    MonthlyRate               AS monthly_rate,
    NumCompaniesWorked        AS num_companies_worked,
    UPPER(TRIM(OverTime))     AS over_time,
    PercentSalaryHike         AS percent_salary_hike,
    PerformanceRating         AS performance_rating,
    RelationshipSatisfaction AS relationship_satisfaction,
    StockOptionLevel          AS stock_option_level,
    TotalWorkingYears         AS total_working_years,
    TrainingTimesLastYear     AS training_times_last_year,
    WorkLifeBalance           AS work_life_balance,
    YearsAtCompany            AS years_at_company,
    YearsInCurrentRole        AS years_in_current_role,
    YearsSinceLastPromotion   AS years_since_last_promotion,
    YearsWithCurrManager      AS years_with_curr_manager
FROM raw_hr_employees;

select  * from stg_hr_employees;

select distinct gender from stg_hr_employees;

----------------— Data Quality Checking ----------------------

-- Check for NULL values
SELECT
    COUNT_IF(employee_number IS NULL)        AS employee_number_nulls,
    COUNT_IF(age IS NULL)                    AS age_nulls,
    COUNT_IF(attrition IS NULL)              AS attrition_nulls,
    COUNT_IF(business_travel IS NULL)        AS business_travel_nulls, -- got 11 null
    COUNT_IF(department IS NULL)             AS department_nulls,
    COUNT_IF(distance_from_home IS NULL)     AS distance_from_home_nulls,
    COUNT_IF(education IS NULL)              AS education_nulls,
    COUNT_IF(education_field IS NULL)        AS education_field_nulls,
    COUNT_IF(gender IS NULL)                 AS gender_nulls, -- 64 nulls
    COUNT_IF(job_role IS NULL)               AS job_role_nulls,
    COUNT_IF(marital_status IS NULL)         AS marital_status_nulls,
    COUNT_IF(monthly_income IS NULL)         AS monthly_income_nulls,
    COUNT_IF(performance_rating IS NULL)     AS performance_rating_nulls
FROM stg_hr_employees;

-- Check for duplicates
SELECT
    employee_number,
    COUNT(*) AS dup_count
FROM stg_hr_employees
GROUP BY employee_number
HAVING COUNT(*) > 1;  -- 9 duplicates

-- Check for invalid numeric values

SELECT
    COUNT_IF(age < 18 OR age > 65)                            AS invalid_age,
    COUNT_IF(daily_rate <= 0)                                 AS invalid_daily_rate,
    COUNT_IF(distance_from_home < 0)                          AS invalid_distance,
    COUNT_IF(education NOT BETWEEN 1 AND 5)                   AS invalid_education,
    COUNT_IF(environment_satisfaction NOT BETWEEN 1 AND 4)   AS invalid_environment_satisfaction,
    COUNT_IF(job_satisfaction NOT BETWEEN 1 AND 4)            AS invalid_job_satisfaction,
    COUNT_IF(relationship_satisfaction NOT BETWEEN 1 AND 4)  AS invalid_relationship_satisfaction,
    COUNT_IF(work_life_balance NOT BETWEEN 1 AND 4)           AS invalid_work_life_balance,
    COUNT_IF(monthly_income < 0)                              AS invalid_monthly_income,
    COUNT_IF(percent_salary_hike < 0)                         AS invalid_percent_salary_hike,
    COUNT_IF(total_working_years < 0)                         AS invalid_total_working_years,
    COUNT_IF(years_at_company < 0)                            AS invalid_years_at_company,
    COUNT_IF(years_in_current_role < 0)                       AS invalid_years_in_current_role,
    COUNT_IF(years_since_last_promotion < 0)                  AS invalid_years_since_last_promotion,
    COUNT_IF(years_with_curr_manager < 0)                     AS invalid_years_with_curr_manager
FROM stg_hr_employees; 

-- Attrition column should be ‘Yes’ or ‘No’ only:
SELECT COUNT(*) AS invalid_attrition
FROM stg_hr_employees
WHERE attrition NOT IN ('Yes', 'No');

-- Check for derived mismatch
SELECT
    job_level,
    MIN(monthly_income) AS min_income,
    MAX(monthly_income) AS max_income
FROM stg_hr_employees
GROUP BY job_level
ORDER BY job_level;

-- Ensure MonthlyIncome and rates are positive
SELECT COUNT(*) AS invalid_income_amounts
FROM stg_hr_employees
WHERE
    monthly_income < 0
    OR daily_rate <= 0
    OR hourly_rate <= 0;

-- Check YearsAtCompany vs TotalWorkingYears
SELECT COUNT(*) AS inconsistent_work_years
FROM stg_hr_employees
WHERE years_at_company > total_working_years;

-- Check YearsInCurrentRole vs YearsAtCompany
SELECT COUNT(*) AS inconsistent_role_years
FROM stg_hr_employees
WHERE years_in_current_role > years_at_company;

------------ Clean Table: Remove invalids,deduplicate ---------------------

CREATE OR REPLACE TABLE cln_hr_employees AS
WITH dedup AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY employee_number
            ORDER BY monthly_income DESC NULLS LAST
        ) AS rn
    FROM stg_hr_employees
)
SELECT
    employee_number,

    CASE 
        WHEN age BETWEEN 18 AND 65 THEN age 
        ELSE NULL 
    END AS age,

    attrition,

    CASE
        WHEN gender IS NULL OR TRIM(gender) = '' THEN 'UNKNOWN'
        ELSE gender
    END AS gender,

    COALESCE(marital_status, 'UNKNOWN') AS marital_status,
    education,
    education_field,
    
    department,
    job_role,
    job_level,
    job_involvement,

    COALESCE(business_travel, 'TRAVEL_RARELY') AS business_travel,
    over_time,
    distance_from_home, -- 
    
    environment_satisfaction,
    job_satisfaction,
    relationship_satisfaction,
    work_life_balance,
    performance_rating,
    training_times_last_year,

    daily_rate,
    hourly_rate,
    monthly_income,
    monthly_rate,
    percent_salary_hike,
    stock_option_level,

    total_working_years,
    years_at_company,
    years_in_current_role,
    years_since_last_promotion,
    years_with_curr_manager

FROM dedup
WHERE rn = 1;

select distinct job_role from cln_hr_employees;


-- Gender domain check
SELECT DISTINCT gender FROM cln_hr_employees;

-- Dedup validation
SELECT COUNT(*) FROM stg_hr_employees;
SELECT COUNT(*) FROM cln_hr_employees;

-- Business key uniqueness
SELECT employee_number, COUNT(*)
FROM cln_hr_employees
GROUP BY employee_number
HAVING COUNT(*) > 1;

--------------------- Dim Tables -----------------------

------------ dim_employee -------------
CREATE OR REPLACE TABLE dim_employee (
    employee_sk INT AUTOINCREMENT PRIMARY KEY,
    employee_number INT NOT NULL,
    gender STRING,
    age INT,
    marital_status STRING,
    education INT,
    education_field STRING
);
INSERT INTO dim_employee (
    employee_number,
    gender,
    age,
    marital_status,
    education,
    education_field
)
SELECT DISTINCT
    employee_number,
    gender,
    age,
    marital_status,
    education,
    education_field
FROM cln_hr_employees;

------------ Dim job ---------------------- 
CREATE OR REPLACE TABLE dim_job (
    job_sk INT AUTOINCREMENT PRIMARY KEY,
    job_role STRING,
    department STRING,
    job_level INT
);
INSERT INTO dim_job (job_role, department, job_level)
SELECT DISTINCT
    job_role,
    department,
    job_level
FROM cln_hr_employees;

select distinct job_role from dim_job;
---------- dim work -----------------

CREATE OR REPLACE TABLE dim_work_arrangement (
    work_profile_sk INT AUTOINCREMENT PRIMARY KEY,
    business_travel STRING,
    over_time STRING
);
INSERT INTO dim_work_arrangement (
    business_travel,
    over_time
)
SELECT DISTINCT
    business_travel,
    over_time
FROM cln_hr_employees;

------------------------- Fact TAble ------------------------------

CREATE OR REPLACE TABLE fct_hr_employee AS
SELECT
    de.employee_sk,
    dj.job_sk,
    dwa.work_profile_sk,

    ce.daily_rate,
    ce.hourly_rate,
    ce.monthly_income,
    ce.monthly_rate,
    ce.percent_salary_hike,
    ce.stock_option_level,

    ce.distance_from_home,
    ce.total_working_years,
    ce.years_at_company,
    ce.years_in_current_role,
    ce.years_since_last_promotion,
    ce.years_with_curr_manager,

    ce.training_times_last_year,
    ce.performance_rating,

    ce.job_involvement,
    ce.environment_satisfaction,
    ce.job_satisfaction,
    ce.relationship_satisfaction,
    ce.work_life_balance,

    CASE WHEN UPPER(ce.attrition) = 'YES' THEN 1 ELSE 0 END AS attrition_flag,

    CASE
        WHEN ce.total_working_years < 5 THEN 'Junior'
        WHEN ce.total_working_years BETWEEN 5 AND 10 THEN 'Mid'
        ELSE 'Senior'
    END AS experience_level,

    CASE
        WHEN ce.monthly_income < 3000 THEN 'Low'
        WHEN ce.monthly_income BETWEEN 3000 AND 8000 THEN 'Medium'
        ELSE 'High'
    END AS income_band

FROM cln_hr_employees ce
JOIN dim_employee de
    ON ce.employee_number = de.employee_number
JOIN dim_job dj
    ON ce.job_role = dj.job_role
   AND ce.department = dj.department
   AND ce.job_level = dj.job_level
JOIN dim_work_arrangement dwa
    ON ce.business_travel = dwa.business_travel
   AND ce.over_time = dwa.over_time;

   
SELECT COUNT(*)
FROM fct_hr_employee f
LEFT JOIN dim_job j ON f.job_sk = j.job_sk
WHERE j.job_sk IS NULL;

------------------- Business Queries -------------------------

-- 1. Total Employees
SELECT COUNT(*) AS total_employees
FROM fct_hr_employee;

-- 2. Overall Attrition Rate (%)
SELECT
    ROUND(100.0 * SUM(attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee;

-- 3. Attrition Rate by Department
SELECT
    dj.department,
    COUNT(*) AS employees,
    ROUND(100.0 * SUM(f.attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee f
JOIN dim_job dj ON f.job_sk = dj.job_sk
GROUP BY dj.department
ORDER BY attrition_rate_pct DESC;

-- 4. Average Monthly Income (Company)
SELECT
    ROUND(AVG(monthly_income), 2) AS avg_monthly_income
FROM fct_hr_employee;

-- 5. Average Monthly Income by Job Level
SELECT
    dj.job_level,
    ROUND(AVG(f.monthly_income), 2) AS avg_monthly_income
FROM fct_hr_employee f
JOIN dim_job dj ON f.job_sk = dj.job_sk
GROUP BY dj.job_level
ORDER BY dj.job_level;

-- 6. Gender-wise Attrition Rate
SELECT
    e.gender,
    COUNT(*) AS employees,
    ROUND(100.0 * SUM(f.attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee f
JOIN dim_employee e ON f.employee_sk = e.employee_sk
GROUP BY e.gender
ORDER BY attrition_rate_pct DESC;

-- 7. Average Years at Company
SELECT
    ROUND(AVG(years_at_company), 2) AS avg_years_at_company
FROM fct_hr_employee;

-- 8. Average Years at Company by Job Role
SELECT
    dj.job_role,
    ROUND(AVG(f.years_at_company), 2) AS avg_years_at_company
FROM fct_hr_employee f
JOIN dim_job dj ON f.job_sk = dj.job_sk
GROUP BY dj.job_role
ORDER BY avg_years_at_company DESC;

-- 9. Average Performance Rating by Job Level
SELECT
    dj.job_level,
    ROUND(AVG(f.performance_rating), 2) AS avg_performance_rating
FROM fct_hr_employee f
JOIN dim_job dj ON f.job_sk = dj.job_sk
GROUP BY dj.job_level
ORDER BY dj.job_level;

-- 10. Average Work-Life Balance by Department
SELECT *
FROM (
    SELECT
        dj.department,
        ROUND(AVG(f.work_life_balance), 2) AS avg_work_life_balance
    FROM fct_hr_employee f
    JOIN dim_job dj ON f.job_sk = dj.job_sk
    GROUP BY dj.department
)
ORDER BY avg_work_life_balance;

-- 11. Attrition Rate by Tenure Bucket (Lifecycle Analysis)
SELECT *
FROM (
    SELECT
        CASE
            WHEN years_at_company < 2 THEN '0–1 Years'
            WHEN years_at_company BETWEEN 2 AND 5 THEN '2–5 Years'
            WHEN years_at_company BETWEEN 6 AND 10 THEN '6–10 Years'
            ELSE '10+ Years'
        END AS tenure_bucket,
        COUNT(*) AS employees,
        ROUND(100.0 * SUM(attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
    FROM fct_hr_employee
    GROUP BY tenure_bucket
)
ORDER BY attrition_rate_pct DESC;

-- 12. Department Attrition vs Company Average (Benchmark)
SELECT
    department,
    attrition_rate_pct,
    ROUND(attrition_rate_pct - company_avg, 2) AS deviation_from_company_avg
FROM (
    SELECT
        dj.department,
        ROUND(100.0 * SUM(f.attrition_flag) / COUNT(*), 2) AS attrition_rate_pct,
        ROUND(
            100.0 * SUM(f.attrition_flag) / COUNT(*) OVER (), 2
        ) AS company_avg
    FROM fct_hr_employee f
    JOIN dim_job dj ON f.job_sk = dj.job_sk
    GROUP BY dj.department
)
ORDER BY deviation_from_company_avg DESC;

-- 13. Top 3 Job Roles with Highest Attrition (Ranking)
SELECT *
FROM (
    SELECT
        dj.job_role,
        COUNT(*) AS employees,
        ROUND(100.0 * SUM(f.attrition_flag) / COUNT(*), 2) AS attrition_rate_pct,
        RANK() OVER (
            ORDER BY SUM(f.attrition_flag) * 1.0 / COUNT(*) DESC
        ) AS rnk
    FROM fct_hr_employee f
    JOIN dim_job dj ON f.job_sk = dj.job_sk
    GROUP BY dj.job_role
)
WHERE rnk <= 3;

-- 14.Attrition Rate by Experience Level
SELECT
    experience_level,
    COUNT(*) AS employees,
    ROUND(100.0 * SUM(attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee
GROUP BY experience_level
ORDER BY attrition_rate_pct DESC;

-- 15. Overtime Impact on Attrition
SELECT
    dwa.over_time,
    COUNT(*) AS employees,
    ROUND(100.0 * SUM(f.attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee f
JOIN dim_work_arrangement dwa ON f.work_profile_sk = dwa.work_profile_sk
GROUP BY dwa.over_time
ORDER BY attrition_rate_pct DESC;

-- 16. Experience Level vs Attrition
SELECT
    experience_level,
    COUNT(*) AS employees,
    ROUND(100.0 * SUM(attrition_flag) / COUNT(*), 2) AS attrition_rate_pct
FROM fct_hr_employee
GROUP BY experience_level
ORDER BY attrition_rate_pct DESC;
