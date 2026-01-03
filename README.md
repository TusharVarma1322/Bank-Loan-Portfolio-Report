# 🏦 Bank Loan Portfolio Report

<p align="center">
  <img src="images/dashboard_preview.png" alt="Dashboard Preview" width="500">
</p>

> ⚠️ **Note:** Dashboard preview image coming soon! 

## 📋 Table of Contents
- [Project Overview](#-project-overview)
- [Business Questions](#-business-questions)
- [Dataset Description](#-dataset-description)
- [Methodology](#-methodology)
- [SQL Solution Approach](#-sql-solution-approach)
- [Results](#-results)
- [Key Insights & Interpretation](#-key-insights--interpretation)
- [Technical Skills Demonstrated](#-technical-skills-demonstrated)
- [Project Structure](#-project-structure)
- [How to Run](#-how-to-run)
- [Future Improvements](#-future-improvements)

---

## 🎯 Project Overview

This project provides a comprehensive analysis of **consumer credit risk and loan portfolio health** for a financial institution. The goal is to monitor loan performance, assess credit risk, and track key financial KPIs to support data-driven decision making.

**Key Objective:** Analyze loan portfolio metrics including DTI (Debt-to-Income), interest rates, funding amounts, and identify patterns in loan performance across different borrower segments.

---

## ❓ Business Questions

This analysis answers the following critical business questions:

| # | Question |
|---|----------|
| 1 | What is the **overall health** of the loan portfolio (total applications, funded amounts, payments received)? |
| 2 | What is the **Month-to-Date (MTD)** and **Previous Month-to-Date (PMTD)** performance comparison? |
| 3 | What is the **Good vs Bad loan ratio** and how does it impact portfolio risk? |
| 4 | How do loan metrics vary by **state, term, employment length, purpose, and home ownership**? |
| 5 | What is the **Month-over-Month growth** in applications and disbursements? |
| 6 | How do **interest rates vary by loan grade and subgrade**? |
| 7 | Which borrower segments have the **highest charged-off risk**? |

---

## 🗄️ Dataset Description

### Database: `financial_db`

The analysis uses a single comprehensive table:

| Table | Description | Key Fields |
|-------|-------------|------------|
| `financial_loan` | Contains all loan application and performance data | `loan_amount`, `total_payment`, `int_rate`, `dti`, `loan_status`, `issue_date`, etc. |

### Data Schema

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT | Primary key |
| `loan_amount` | DECIMAL | Loan principal amount |
| `total_payment` | DECIMAL | Total payments received |
| `int_rate` | DECIMAL | Interest rate |
| `dti` | DECIMAL | Debt-to-Income ratio |
| `loan_status` | VARCHAR | Status (Fully Paid/Current/Charged Off) |
| `issue_date` | DATE | Loan issue date |
| `address_state` | VARCHAR | Borrower's state |
| `term` | VARCHAR | Loan term (36/60 months) |
| `emp_length` | VARCHAR | Employment length |
| `purpose` | VARCHAR | Loan purpose |
| `home_ownership` | VARCHAR | Home ownership status |
| `grade` | VARCHAR | Loan grade (A-G) |
| `sub_grade` | VARCHAR | Loan subgrade (A1-G5) |

### Loan Status Classification

```
┌─────────────────────────────────────────────────────────┐
│                    ALL LOANS                            │
├────────────────────────┬────────────────────────────────┤
│     GOOD LOANS         │         BAD LOANS              │
│  ┌────────────────┐    │    ┌────────────────┐          │
│  │  Fully Paid    │    │    │  Charged Off   │          │
│  │  Current       │    │    │                │          │
│  └────────────────┘    │    └────────────────┘          │
└────────────────────────┴────────────────────────────────┘
```

**Key Insight:** Good loans (Fully Paid + Current) represent healthy portfolio assets, while Charged Off loans indicate defaults and credit losses.

---

## 🔬 Methodology

### Approach Overview

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   PHASE 1       │     │   PHASE 2       │     │   PHASE 3       │
│   Overall       │ ──► │   Segmented     │ ──► │   Risk          │
│   KPIs          │     │   Analysis      │     │   Assessment    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### Phase 1: Overall KPIs

**Objective:** Calculate portfolio-wide summary metrics

| Metric | Formula | Description |
|--------|---------|-------------|
| `total_applications` | `COUNT(*)` | Total number of loan applications |
| `total_funded_amount` | `SUM(loan_amount)` | Total amount disbursed |
| `total_amount_received` | `SUM(total_payment)` | Total payments collected |
| `avg_interest_rate` | `AVG(int_rate)` | Average interest rate |
| `avg_dti` | `AVG(dti)` | Average Debt-to-Income ratio |

### Phase 2: Segmented Analysis

**Objective:** Break down metrics by various dimensions

| Dimension | Purpose |
|-----------|---------|
| **Time** | MTD, PMTD, Monthly trends, MoM growth |
| **Geography** | State-wise distribution |
| **Loan Terms** | 36-month vs 60-month analysis |
| **Borrower Profile** | Employment length, home ownership |
| **Loan Purpose** | Debt consolidation, credit card, etc. |
| **Credit Grade** | A through G grade analysis |

### Phase 3: Risk Assessment

**Objective:** Identify high-risk segments and default patterns

| Analysis | Description |
|----------|-------------|
| Good vs Bad Loans | Portfolio quality classification |
| Charged-Off Risk | Default probability by segment |
| Grade Analysis | Risk-adjusted interest rates |

---

## 💻 SQL Solution Approach

### Report A: Overall KPIs

```sql
SELECT
  'Overall KPIs - Total Applications & Metrics' AS report,
  COUNT(*) AS total_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS avg_dti
FROM financial_loan;
```

**Why COALESCE()?**
- Handles NULL values gracefully
- Prevents NULL propagation in calculations
- Ensures accurate aggregations

### Report B: MTD & PMTD Comparison

```sql
-- Define reference dates dynamically
SET @ref_month_start = CAST(DATE_FORMAT(CURDATE(), '%Y-%m-01') AS DATE);
SET @prev_month_start = DATE_SUB(@ref_month_start, INTERVAL 1 MONTH);

-- MTD KPIs
SELECT
  'MTD KPIs (current month)' AS report,
  COUNT(*) AS mtd_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS mtd_funded_amount
FROM financial_loan
WHERE issue_date >= @ref_month_start AND issue_date < @ref_month_end;
```

**Why Dynamic Dates?**
- Automatically adjusts to current month
- No manual updates required
- Ensures consistent MTD/PMTD calculations

### Report C: Good vs Bad Loans

```sql
SELECT
  'Good vs Bad Loans' AS report,
  COUNT(*) AS total_applications,
  SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN 1 ELSE 0 END) AS good_applications,
  ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*),0),2) AS good_pct,
  SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS bad_applications,
  ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*),0),2) AS bad_pct
FROM financial_loan;
```

**Why CASE WHEN?**
- Enables conditional counting within a single query
- Allows multiple classifications simultaneously
- More efficient than multiple subqueries

**Why NULLIF()?**
- Prevents division by zero errors
- Returns NULL instead of error if denominator is 0

### Report L: Month-over-Month Growth

```sql
WITH month_aggs AS (
  SELECT
    CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE) AS issue_month_start,
    COUNT(*) AS applications,
    ROUND(SUM(COALESCE(loan_amount,0)),2) AS amount_disbursed
  FROM financial_loan
  GROUP BY CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE)
)
SELECT
  DATE_FORMAT(m.issue_month_start, '%Y-%m') AS issue_month,
  m.applications,
  m.amount_disbursed,
  ROUND(100.0 * (m.applications - p.applications) / p.applications, 2) AS applications_mom_pct
FROM month_aggs m
LEFT JOIN month_aggs p
  ON p.issue_month_start = DATE_SUB(m.issue_month_start, INTERVAL 1 MONTH)
ORDER BY m.issue_month_start;
```

**Why CTE (WITH clause)?**
- Improves query readability
- Allows self-join for month-over-month comparison
- Calculates growth rates efficiently

---

## 📈 Results

<p align="center">
  <img src="images/results_overview.png" alt="Results Overview" width="800">
</p>

> ⚠️ **Note:** Results screenshot coming soon!

### Summary of Reports Generated: 

| Section | Report Name | Purpose |
|---------|-------------|---------|
| A | Overall KPIs | Portfolio-wide summary metrics |
| B | MTD & PMTD KPIs | Current vs previous month comparison |
| C | Good vs Bad Loans | Loan quality classification |
| D | Loan Status - Overall | Breakdown by loan status |
| E | Loan Status - MTD | Current month status breakdown |
| F | Monthly Overview | Time-series analysis |
| G | State Overview | Geographic distribution |
| H | Term Overview | Analysis by loan term (36/60 months) |
| I | Employment Length | Borrower employment analysis |
| J | Purpose Overview | Loan purpose distribution |
| K | Home Ownership | Ownership status analysis |
| L | Month-over-Month Growth | Growth rate calculations |
| M | Interest Rate by Grade | Rate analysis by credit grade |
| N | Top States & Purposes | Top performers ranking |
| O | Charged-Off Risk | Risk analysis by employment |

---

## 💡 Key Insights & Interpretation

### 1. Portfolio Quality Analysis

**Good vs Bad Loan Classification:**
- **Good Loans:** Fully Paid + Current status
- **Bad Loans:** Charged Off status

**Business Implication:**
- Higher good loan percentage indicates healthy underwriting standards
- Track bad loan percentage trends to identify early warning signs
- Use for provisioning and reserve calculations

### 2. Geographic Risk Distribution

**State-wise Analysis Purpose:**
- Identify high-performing vs high-risk regions
- Support regional lending strategy decisions
- Compliance with geographic concentration limits

**Business Implication:**
- Diversify portfolio across states to reduce concentration risk
- Adjust marketing spend based on regional performance

### 3. Borrower Segment Analysis

**Employment Length Insights:**
- Longer employment typically correlates with lower default risk
- New employees may require stricter underwriting

**Home Ownership Insights:**
- Homeowners often have lower default rates
- Renters may require additional verification

### 4. Interest Rate by Grade

**Grade Analysis Purpose:**
- Validates risk-based pricing model
- Ensures adequate risk premium for lower grades

**Expected Pattern:**
```
Grade A ──► Lowest Interest Rate (Lowest Risk)
Grade B ──► 
Grade C ──► 
Grade D ──► 
Grade E ──► 
Grade F ──► 
Grade G ──► Highest Interest Rate (Highest Risk)
```

---

## 🛠️ Technical Skills Demonstrated

| Category | Skills |
|----------|--------|
| **SQL Aggregations** | COUNT(), SUM(), AVG(), MIN(), MAX(), GROUP BY |
| **Conditional Logic** | CASE WHEN, COALESCE(), NULLIF() |
| **Date Functions** | DATE_FORMAT(), DATEDIFF(), DATE_SUB(), CURDATE() |
| **CTEs** | WITH clause for complex calculations |
| **Self-Joins** | Month-over-month growth calculations |
| **Variables** | MySQL user-defined variables for dynamic dates |
| **Formatting** | ROUND() for decimal precision |
| **Business Logic** | KPI calculations, risk classification |
| **Data Quality** | NULL handling, data validation |

---

## 📁 Project Structure

```
Bank-Loan-Portfolio-Report/
│
├── README.md                         # Project documentation (this file)
│
├── data/
│   └── [dataset files]               # Raw loan data
│
├── sql/
│   └── bank_loan_solution.sql        # Complete SQL analysis script
│
├── docs/
│   └── [documentation]               # Additional documentation
│
└── images/                           # Screenshots and visualizations
    ├── dashboard_preview.png         # (Coming Soon)
    └── results_overview.png          # (Coming Soon)
```

---

## 🚀 How to Run

### Prerequisites
- MySQL Server 8.0+
- MySQL Workbench (recommended) or any SQL client

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/TusharVarma1322/Bank-Loan-Portfolio-Report. git
   cd Bank-Loan-Portfolio-Report
   ```

2. **Set up the database**
   ```sql
   CREATE DATABASE financial_db;
   USE financial_db;
   ```

3. **Import your loan data** into the `financial_loan` table

4. **Run the analysis**
   ```bash
   mysql -u your_username -p financial_db < sql/bank_loan_solution.sql
   ```

5. **Review the results** - Each report section outputs with a descriptive label

---

## 🔜 Future Improvements

- [ ] **Add Dashboard Images:** Include screenshots of results and visualizations
- [ ] **Python Integration:** Add pandas analysis for additional statistics
- [ ] **Visualization:** Create charts using Python (matplotlib/seaborn) or BI tools
- [ ] **Cohort Analysis:** Track loan performance by origination month
- [ ] **Predictive Modeling:** Build ML model for default prediction
- [ ] **Data Pipeline:** Automate data refresh and report generation

---

## 📚 What I Learned

1. **Complex SQL Aggregations** - Multi-dimensional analysis with GROUP BY
2. **Dynamic Date Handling** - Using variables for MTD/PMTD calculations
3. **Risk Classification** - Translating business rules into SQL logic
4. **CTE Usage** - Common Table Expressions for readable, maintainable code
5. **Financial KPIs** - Understanding DTI, interest rates, and portfolio metrics
6. **Data Quality** - Proper NULL handling and edge case management

---

## 👤 Author

**Tushar Varma**
- GitHub: [@TusharVarma1322](https://github.com/TusharVarma1322)

---

*Project completed:  January 2026*
