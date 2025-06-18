use [Loan Analysis];

SELECT * FROM loan

-- Indexing frequently used columns

-- For MoM analysis (where issue_date and aggregation are used)
CREATE INDEX idx_loan_issue_status ON loan(issue_date, loan_status);


-- Total loan application
SELECT FORMAT(COUNT(DISTINCT id),'N0') AS total_application FROM loan;

-- Total Month to Date loan application
SELECT MAX(running_total) total_mtd_application FROM (
SELECT COUNT(id) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE YEAR(issue_date) = 2021) t1;

-- Total Previous Month to Date loan application
SELECT MAX(running_total) total_mtd_application_prev_month FROM (
SELECT COUNT(id) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE MONTH(issue_date) <=11 AND YEAR(issue_date) = 2021) t1;

-- MoM increase % in loan application
WITH T1 AS (
  SELECT YEAR(issue_date) AS year, MONTH(issue_date) AS month, COUNT(id) AS total_loan_application,
  LAG(COUNT(id), 1) OVER(ORDER BY MONTH(issue_date)) AS lagged_count
  FROM loan
  GROUP BY YEAR(issue_date), MONTH(issue_date)
)
SELECT *, ROUND((total_loan_application - lagged_count) * 100.0 / lagged_count, 2) AS percent_change FROM T1;

-- Total loan amount disbursed
SELECT FORMAT(SUM(loan_amount),'N0') AS total_disbursed FROM loan;

-- Total Month to Date loan amount disbursed
SELECT FORMAT(MAX(running_total),'N0') total_mtd_loan_amt_disbursed FROM (
SELECT SUM(loan_amount) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE YEAR(issue_date) = 2021) t1;

-- Total Previous Month to Date loan amount disbursed
SELECT FORMAT(MAX(running_total),'N0') total_mtd_loan_amt_disbursed_prev_month FROM (
SELECT SUM(loan_amount) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE MONTH(issue_date) <=11 AND YEAR(issue_date) = 2021) t1;

-- MoM increase % in loan disbursement
WITH T1 AS (
  SELECT YEAR(issue_date) AS year, MONTH(issue_date) AS month, SUM(loan_amount) AS loan_amt_disbursed,
  LAG(SUM(loan_amount), 1) OVER(ORDER BY MONTH(issue_date)) AS lagged_amt
  FROM loan
  GROUP BY YEAR(issue_date), MONTH(issue_date)
)
SELECT *, ROUND((loan_amt_disbursed - lagged_amt) * 100.0 / lagged_amt, 2) AS percent_change FROM T1;

-- Total loan amount paid
SELECT FORMAT(SUM(total_payment),'N0') AS total_payment FROM loan;

-- Total Month to Date loan amount paid
SELECT FORMAT(MAX(running_total),'N0') total_mtd_loan_amt_paid FROM (
SELECT SUM(total_payment) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE YEAR(issue_date) = 2021) t1;

-- Total Previous Month to Date loan amount paid
SELECT FORMAT(MAX(running_total),'N0') total_mtd_loan_amt_paid_prev_month FROM (
SELECT SUM(total_payment) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE MONTH(issue_date) <=11 AND YEAR(issue_date) = 2021) t1;

-- MoM increase % in loan amount paid
WITH T1 AS (
  SELECT YEAR(issue_date) AS year, MONTH(issue_date) AS month, SUM(total_payment) AS loan_amt_paid,
  LAG(SUM(total_payment), 1) OVER(ORDER BY MONTH(issue_date)) AS lagged_loan_amt_paid
  FROM loan
  GROUP BY YEAR(issue_date), MONTH(issue_date)
)
SELECT *, ROUND((loan_amt_paid - lagged_loan_amt_paid) * 100.0 / lagged_loan_amt_paid, 2) AS percent_change FROM T1;

-- Average interest rate
SELECT ROUND(AVG(int_rate) * 100.0,2) AS avg_int_rate FROM loan;

-- Average DTI
SELECT ROUND(AVG(dti) * 100.0,2) AS avg_dti FROM loan;

-- Average Month to Date DTI
SELECT ROUND(MAX(running_total),2) avg_mtd_dti FROM (
SELECT AVG(dti) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE YEAR(issue_date) = 2021) t1;

-- Average Previous Month to Date DTI
SELECT ROUND(MAX(running_total),2) avg_mtd_dti_prev_month FROM (
SELECT AVG(dti) OVER(ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total FROM loan
WHERE MONTH(issue_date) <=11 AND YEAR(issue_date) = 2021) t1;

-- Good Loan Percentage
SELECT 
  ROUND(SUM(CASE WHEN loan_status IN ('Fully Paid', 'Current') THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM loan),2)
 AS percentage_good_loan FROM loan;

-- Count of good loans
SELECT FORMAT(COUNT(id),'N0') AS count_good_loan FROM loan
WHERE loan_status IN ('Fully Paid', 'Current');

-- Amount of good loan disbursed
SELECT FORMAT(SUM(loan_amount),'N0') AS good_loan_amt_disbursed FROM loan
WHERE loan_status IN ('Fully Paid', 'Current');

-- Amount of good loan paid back
SELECT FORMAT(SUM(total_payment),'N0') AS good_loan_amt_paid FROM loan
WHERE loan_status IN ('Fully Paid', 'Current');

-- Bad Loan Percentage
SELECT 
  ROUND(
    SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM loan), 
    2
  ) AS percentage_bad_loan
FROM loan;

-- Count of bad loans
SELECT COUNT(id) AS count_bad_loan FROM loan
WHERE loan_status = 'Charged Off';

-- Amount of bad loan disbursed
SELECT FORMAT(SUM(loan_amount),'N0') AS bad_loan_amt_disbursed FROM loan
WHERE loan_status = 'Charged Off';

-- Amount of bad loan paid back
SELECT FORMAT(SUM(total_payment),'N0') AS bad_loan_amt_paid FROM loan
WHERE loan_status = 'Charged Off';

-- Loan Status Grid View
SELECT loan_status, 
COUNT(id) AS total_loan_application,
FORMAT(SUM(loan_amount),'N0') AS total_funded_amount,
FORMAT(SUM(total_payment),'N0') AS total_amount_received,
ROUND(AVG(int_rate) * 100.0,2) AS avg_interest_rate,
ROUND(AVG(dti) * 100.0,2) AS avg_dti_score
FROM loan
GROUP BY loan_status;

-- Loan Status by Month
SELECT 
  MONTH(issue_date) AS month_number,
  DATENAME(MONTH, issue_date) AS month_name,
  COUNT(id) AS total_loan_applications,
  FORMAT(SUM(loan_amount),'N0') AS total_funded_amount,
  FORMAT(SUM(total_payment),'N0') AS total_amount_received
FROM loan
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date);

-- State-wise Loan Analysis
SELECT 
  address_state AS state,
  COUNT(id) AS total_loan_applications,
  FORMAT(SUM(loan_amount),'N0') AS total_funded_amount,
  FORMAT(SUM(total_payment),'N0') AS total_amount_received
FROM loan
GROUP BY address_state
ORDER BY address_state;

-- Term-wise Loan Analysis
SELECT 
  term,
  FORMAT(COUNT(id),'N0') AS total_loan_applications,
  FORMAT(SUM(loan_amount),'N0') AS total_funded_amount,
  FORMAT(SUM(total_payment),'N0') AS total_amount_received
FROM loan
GROUP BY term
ORDER BY term;

-- Employment Tenure-wise Loan Analysis
SELECT 
  emp_length AS employment_tenure,
  COUNT(id) AS total_loan_applications,
  SUM(loan_amount) AS total_funded_amount,
  SUM(total_payment) AS total_amount_received
FROM loan
GROUP BY emp_length
ORDER BY emp_length;

-- Purpose-wise Loan Analysis
SELECT 
  purpose AS loan_purpose,
  COUNT(id) AS total_loan_applications,
  SUM(loan_amount) AS total_funded_amount,
  SUM(total_payment) AS total_amount_received
FROM loan
GROUP BY purpose
ORDER BY total_funded_amount DESC,total_amount_received DESC;

-- Home Ownership-wise Loan Analysis
SELECT 
  home_ownership AS home_ownership,
  COUNT(id) AS total_loan_applications,
  SUM(loan_amount) AS total_funded_amount,
  SUM(total_payment) AS total_amount_received
FROM loan
GROUP BY home_ownership
ORDER BY home_ownership;

-- Grade-wise Loan Analysis by Purpose

--Grade-A
SELECT 
  purpose AS purpose,
  COUNT(id) AS total_loan_applications,
  SUM(loan_amount) AS total_funded_amount,
  SUM(total_payment) AS total_amount_received
FROM loan
WHERE grade = 'A'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade-B
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'B'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade-C
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'C'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade-D 
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'D'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade -E
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'E'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade-F
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'F'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;

-- Grade-G
SELECT 
	purpose AS PURPOSE, 
	COUNT(id) AS Total_Loan_Applications,
	SUM(loan_amount) AS Total_Funded_Amount,
	SUM(total_payment) AS Total_Amount_Received
FROM loan
WHERE grade = 'G'
GROUP BY purpose
ORDER BY Total_Funded_Amount DESC,Total_Amount_Received DESC;









