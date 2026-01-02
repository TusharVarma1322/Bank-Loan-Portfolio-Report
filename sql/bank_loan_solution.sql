USE financial_db;

-- ===== Define reference month (current calendar month for MTD / previous month for PMTD) =====
SET @ref_month_start = CAST(DATE_FORMAT(CURDATE(), '%Y-%m-01') AS DATE);
SET @prev_month_start = DATE_SUB(@ref_month_start, INTERVAL 1 MONTH);
SET @ref_month_end = DATE_ADD(@ref_month_start, INTERVAL 1 MONTH);
SET @prev_month_end = DATE_ADD(@prev_month_start, INTERVAL 1 MONTH);

-- ===== A: Overall KPIs =====
SELECT
  'Overall KPIs - Total Applications & Metrics' AS report,
  COUNT(*) AS total_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS avg_dti
FROM financial_loan;

-- ===== B: MTD & PMTD KPIs (current / previous month) =====
SELECT
  'MTD KPIs (current month)' AS report,
  COUNT(*) AS mtd_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS mtd_funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS mtd_amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS mtd_avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS mtd_avg_dti
FROM financial_loan
WHERE issue_date >= @ref_month_start AND issue_date < @ref_month_end;

SELECT
  'PMTD KPIs (previous month)' AS report,
  COUNT(*) AS pmtd_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS pmtd_funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS pmtd_amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS pmtd_avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS pmtd_avg_dti
FROM financial_loan
WHERE issue_date >= @prev_month_start AND issue_date < @prev_month_end;

-- ===== C: Good vs Bad Loans =====
SELECT
  'Good vs Bad Loans' AS report,
  COUNT(*) AS total_applications,
  SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN 1 ELSE 0 END) AS good_applications,
  ROUND(SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN COALESCE(loan_amount,0) ELSE 0 END),2) AS good_funded_amount,
  ROUND(SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN COALESCE(total_payment,0) ELSE 0 END),2) AS good_amount_received,
  ROUND(100.0 * SUM(CASE WHEN loan_status IN ('Fully Paid','Current') THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS good_pct,
  SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS bad_applications,
  ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN COALESCE(loan_amount,0) ELSE 0 END),2) AS bad_funded_amount,
  ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN COALESCE(total_payment,0) ELSE 0 END),2) AS bad_amount_received,
  ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS bad_pct
FROM financial_loan;

-- ===== D: Loan Status - Overall =====
SELECT
  'Loan Status - Overall' AS report,
  COALESCE(loan_status,'Unknown') AS loan_status,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS avg_dti
FROM financial_loan
GROUP BY COALESCE(loan_status,'Unknown')
ORDER BY applications DESC;

-- ===== E: Loan Status - MTD (current month) =====
SELECT
  'Loan Status - MTD (current month)' AS report,
  COALESCE(loan_status,'Unknown') AS loan_status,
  COUNT(*) AS mtd_applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS mtd_funded_amount,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS mtd_amount_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS mtd_avg_interest_rate,
  ROUND(AVG(COALESCE(dti,0)),4) AS mtd_avg_dti
FROM financial_loan
WHERE issue_date >= @ref_month_start AND issue_date < @ref_month_end
GROUP BY COALESCE(loan_status,'Unknown')
ORDER BY mtd_applications DESC;

-- ===== F: Monthly Overview (remove report column per reviewer) =====
SELECT
  CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE) AS issue_month_start,
  DATE_FORMAT(issue_date, '%Y-%m') AS issue_month,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE), DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY issue_month_start;

-- ===== G: State Overview (remove report column) =====
SELECT
  COALESCE(address_state,'Unknown') AS state,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY COALESCE(address_state,'Unknown')
ORDER BY total_funded DESC;

-- ===== H: Term Overview (remove report column) =====
SELECT
  (COALESCE(NULLIF(TRIM(REPLACE(REPLACE(term,'months',''), 'month','')), ''), '-1') + 0) AS term_months,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY (COALESCE(NULLIF(TRIM(REPLACE(REPLACE(term,'months',''), 'month','')), ''), '-1') + 0)
ORDER BY term_months;

-- ===== I: Employment Length Overview (remove report column) =====
SELECT
  COALESCE(emp_length,'Unknown') AS emp_length,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY COALESCE(emp_length,'Unknown')
ORDER BY applications DESC;

-- ===== J: Purpose Overview (remove report column) =====
SELECT
  COALESCE(purpose,'Unknown') AS purpose,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY COALESCE(purpose,'Unknown')
ORDER BY total_funded DESC;

-- ===== K: Home Ownership Overview (remove report column) =====
SELECT
  COALESCE(home_ownership,'Unknown') AS home_ownership,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded,
  ROUND(SUM(COALESCE(total_payment,0)),2) AS total_received,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY COALESCE(home_ownership,'Unknown')
ORDER BY total_funded DESC;

-- ===== L: Month-over-Month Growth (applications + disbursed) =====
WITH month_aggs AS (
  SELECT
    CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE) AS issue_month_start,
    COUNT(*) AS applications,
    ROUND(SUM(COALESCE(loan_amount,0)),2) AS amount_disbursed
  FROM financial_loan
  GROUP BY CAST(CONCAT(DATE_FORMAT(issue_date, '%Y-%m'), '-01') AS DATE)
)
SELECT
  'Month-over-Month Growth' AS report,
  DATE_FORMAT(m.issue_month_start, '%Y-%m') AS issue_month,
  m.applications,
  m.amount_disbursed,
  p.applications AS prev_applications,
  p.amount_disbursed AS prev_amount_disbursed,
  CASE WHEN p.applications IS NULL OR p.applications = 0 THEN NULL ELSE ROUND(100.0 * (m.applications - p.applications) / p.applications, 2) END AS applications_mom_pct,
  CASE WHEN p.amount_disbursed IS NULL OR p.amount_disbursed = 0 THEN NULL ELSE ROUND(100.0 * (m.amount_disbursed - p.amount_disbursed) / p.amount_disbursed, 2) END AS amount_disbursed_mom_pct
FROM month_aggs m
LEFT JOIN month_aggs p
  ON p.issue_month_start = DATE_SUB(m.issue_month_start, INTERVAL 1 MONTH)
ORDER BY m.issue_month_start;

-- ===== M: Interest Rate by Grade & Subgrade (keep report titles) =====
SELECT
  'Interest Rate by Grade' AS report,
  COALESCE(grade,'Unknown') AS grade,
  COUNT(*) AS num_loans,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate,
  ROUND(MIN(COALESCE(int_rate,0)),4) AS min_interest_rate,
  ROUND(MAX(COALESCE(int_rate,0)),4) AS max_interest_rate
FROM financial_loan
GROUP BY COALESCE(grade,'Unknown')
ORDER BY grade;

SELECT
  'Interest Rate by Subgrade' AS report,
  COALESCE(grade,'Unknown') AS grade,
  COALESCE(sub_grade,'Unknown') AS sub_grade,
  COUNT(*) AS num_loans,
  ROUND(AVG(COALESCE(int_rate,0)),4) AS avg_interest_rate
FROM financial_loan
GROUP BY COALESCE(grade,'Unknown'), COALESCE(sub_grade,'Unknown')
ORDER BY grade, sub_grade;

-- ===== N: Top States & Purposes (keep report titles) =====
SELECT
  'Top 10 States by Funded Amount' AS report,
  COALESCE(address_state,'Unknown') AS state,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded
FROM financial_loan
GROUP BY COALESCE(address_state,'Unknown')
ORDER BY total_funded DESC
LIMIT 10;

SELECT
  'Top 20 Purposes by Funded Amount' AS report,
  COALESCE(purpose,'Unknown') AS purpose,
  COUNT(*) AS applications,
  ROUND(SUM(COALESCE(loan_amount,0)),2) AS total_funded
FROM financial_loan
GROUP BY COALESCE(purpose,'Unknown')
ORDER BY total_funded DESC
LIMIT 20;

-- ===== O: Charged-Off Risk by Employment Length (keep report title) =====
SELECT
  'Charged-Off Risk by Employment Length' AS report,
  COALESCE(emp_length,'Unknown') AS emp_length,
  COUNT(*) AS applications,
  ROUND(AVG(COALESCE(dti,0)),4) AS avg_dti,
  SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) AS charged_off_count,
  ROUND(100.0 * SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) / NULLIF(COUNT(*),0),2) AS charged_off_pct
FROM financial_loan
GROUP BY COALESCE(emp_length,'Unknown')
ORDER BY charged_off_pct DESC, applications DESC;

-- ===== END =====
SELECT 'REPORTS COMPLETE' AS status;





