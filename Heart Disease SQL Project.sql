USE project;

-- Creating a summary table grouping those with and without CHD risk and detailing averages of cholesterol, systolic blood pressure, diastolic blood pressure, BMI, heart rate, and glucose.
SELECT 
TenYearCHD AS chd_risk,
COUNT(*) AS total_patients,
ROUND(AVG(totChol), 1) AS avg_cholesterol,
ROUND(AVG(sysBP), 1) AS avg_systolic_bp,
ROUND(AVG(diaBP), 1) AS avg_diastolic_bp,
ROUND(AVG(BMI), 1) AS avg_bmi,
ROUND(AVG(heartRate), 1) AS avg_heart_rate,
ROUND(AVG(glucose), 1) AS avg_glucose

FROM project.heartdisease
GROUP BY chd_risk;

-- -----------------------------------

-- Creating a summary table grouping gender and detailing total patients, total patients at risk of CHD, and percentage of patients at risk of CHD.
SELECT 
male,
COUNT(*) AS total_patients,
SUM(TenYearCHD) AS chd_risk_total,
(SUM(TenYearCHD) / COUNT(*)) * 100 AS chd_risk_percentage

FROM project.heartdisease
GROUP BY male
ORDER BY chd_risk_percentage DESC;

-- ----------------------------------

-- Temp table creation summarizing all patients in table detailing gender, age, and CHD risk.
-- Using CASE statemetns to create a risk scoring system tied to metrics within table such as cholesterol, systolic blood pressure, cigarette usage, and whether the patient has diabetes.
CREATE TEMPORARY TABLE risk_scores

SELECT
male,
age,
TenYearCHD AS chd_risk,

(CASE
	WHEN totChol > 240 THEN 2
        WHEN totChol BETWEEN 200 AND 240 THEN 1
        ELSE 0
	END +
    
    CASE
		WHEN sysBP > 140 THEN 2
        WHEN sysBP BETWEEN 120 AND 140 THEN 1
        ELSE 0
	END +
    
    CASE
		WHEN cigsPerDay > 20 THEN 2
        WHEN cigsPerDay > 0 THEN 1
        ELSE 0
	END +
    
    CASE
		WHEN diabetes = 1 THEN 2
        ELSE 0
END) AS risk_score

FROM project.heartdisease;

-- -----------------------------------

-- Creating summary table to group risk levels and detail total patients, total patients at risk of CHD, CHD risk percentage, average male and female risk scores, and average elderly risk score over the age of 55.
-- Temp table from previous query is used through its numeric risk scoring system to categorize risk scoring into a risk level and is grouped by risk levels low, moderate, and high.
SELECT
risk_level,
COUNT(*) AS total_patients,
SUM(chd_risk) AS patient_chd_risk_total,
(SUM(chd_risk) / COUNT(*)) * 100 AS chd_risk_percentage,
ROUND(AVG(CASE WHEN male = 1 THEN risk_score END), 1) AS avg_male_risk_score,
ROUND(AVG(CASE WHEN male = 0 THEN risk_score END), 1) AS avg_female_risk_score,
ROUND(AVG(CASE WHEN age > 55 THEN risk_score END), 1) AS avg_elderly_risk_score
FROM
	(SELECT
		chd_risk,
        male,
        age,
        risk_score,
        
        CASE
			WHEN risk_score >= 6 THEN 'High'
            WHEN risk_score BETWEEN 3 AND 5 THEN 'Moderate'
            ELSE 'Low'
		END AS risk_level
	FROM risk_scores
) AS risk_summary

GROUP BY risk_level

ORDER BY chd_risk_percentage;