# 🏦 Bank Loan Portfolio Report

[![SQL](https://img.shields.io/badge/SQL-PLpgSQL-blue? style=flat&logo=postgresql)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-green. svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-brightgreen. svg)](https://github.com/TusharVarma1322/Bank-Loan-Portfolio-Report/graphs/commit-activity)

> Comprehensive analysis of consumer credit risk and loan portfolio health.  Features SQL scripts for cleaning data and calculating financial KPIs like DTI and Interest Rates.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Project Structure](#-project-structure)
- [KPIs & Metrics](#-kpis--metrics)
- [SQL Reports](#-sql-reports)
- [Getting Started](#-getting-started)
- [Database Schema](#-database-schema)
- [Use Cases](#-use-cases)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This project provides a robust SQL-based solution for analyzing bank loan portfolios.  It enables financial institutions and analysts to: 

- Monitor loan application trends and funding patterns
- Assess credit risk through Good vs Bad loan classification
- Track Month-to-Date (MTD) and Previous Month-to-Date (PMTD) performance
- Analyze borrower demographics and loan purposes
- Identify high-risk segments for proactive risk management

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 📊 **Overall KPIs** | Total applications, funded amounts, interest rates, and DTI ratios |
| 📅 **MTD/PMTD Analysis** | Month-over-month performance tracking |
| ✅ **Good vs Bad Loans** | Risk classification (Fully Paid/Current vs Charged Off) |
| 🗺️ **Geographic Analysis** | State-wise loan distribution and performance |
| 📈 **MoM Growth** | Month-over-month growth calculations |
| 🏷️ **Grade Analysis** | Interest rates by loan grade and subgrade |
| 👤 **Borrower Profiling** | Analysis by employment length, home ownership, and loan purpose |

---

## 📁 Project Structure

```
Bank-Loan-Portfolio-Report/
├── 📂 sql/
│   └── bank_loan_solution.sql    # Main SQL script with all reports
├── 📂 data/
│   └── [dataset files]           # Raw loan data
├── 📂 docs/
│   └── [documentation]           # Additional documentation
└── 📄 README.md
```

---

## 📊 KPIs & Metrics

### Primary KPIs

| Metric | Description | Formula |
|--------|-------------|---------|
| **Total Applications** | Count of all loan applications | `COUNT(*)` |
| **Total Funded Amount** | Sum of all loan amounts disbursed | `SUM(loan_amount)` |
| **Total Amount Received** | Sum of all payments received | `SUM(total_payment)` |
| **Average Interest Rate** | Mean interest rate across portfolio | `AVG(int_rate)` |
| **Average DTI** | Mean Debt-to-Income ratio | `AVG(dti)` |

### Risk Metrics

| Metric | Description |
|--------|-------------|
| **Good Loan %** | Percentage of loans that are Fully Paid or Current |
| **Bad Loan %** | Percentage of loans that are Charged Off |
| **Charged-Off Risk** | Default probability by borrower segment |

---

## 📑 SQL Reports

The `bank_loan_solution.sql` script generates the following reports:

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

## 🚀 Getting Started

### Prerequisites

- MySQL 8.0+ or compatible database
- Access to loan portfolio data

### Installation

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
   mysql -u your_username -p financial_db < sql/bank_loan_solution. sql
   ```

---

## 🗄️ Database Schema

### `financial_loan` Table

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

---

## 💼 Use Cases

- **Credit Risk Teams**: Identify high-risk borrower segments
- **Portfolio Managers**: Track loan performance and trends
- **Business Analysts**: Generate executive dashboards
- **Data Scientists**: Base analysis for ML credit scoring models
- **Auditors**: Compliance and portfolio health reporting

---

## 🤝 Contributing

Contributions are welcome!  Please feel free to submit a Pull Request. 

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Tushar Varma**
- GitHub: [@TusharVarma1322](https://github.com/TusharVarma1322)

---

<p align="center">
  ⭐ Star this repository if you found it helpful! 
</p>
