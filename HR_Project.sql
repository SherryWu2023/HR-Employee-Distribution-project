SELECT * FROM projects.hr;
ALTER TABLE hr
CHANGE COLUMN 癤퓁d emp_id VARCHAR(20) NULL;
SELECT * FROM hr;

##Change birthdate values to date;
UPDATE hr
SET birthdate=CASE 
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(str_to_date(birthdate,'%m-%d-%y'),'%Y-%m-%d')
    ELSE NULL
END;    

##Change birthdate column datatype
ALTER TABLE hr MODIFY COLUMN birthdate DATE;

##Convert hire_date values to date
UPDATE hr
SET hire_date=CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(str_to_date(hire_date,'%m-%d-%y'),'%Y-%m-%d')
    ELSE NULL
END;

##Change hire_date column datatype
ALTER TABLE hr MODIFY COLUMN hire_date DATE;

##Convert termdate values to date and remove time
UPDATE hr
SET termdate = date(STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

##Change termdate column datatype
SET sql_mode = 'ALLOW_INVALID_DATES';
ALTER TABLE hr MODIFY COLUMN termdate DATE;

##Add age column
ALTER TABLE hr ADD COLUMN age INT;
UPDATE hr
SET age=timestampdiff(YEAR,birthdate,CURDATE());

##1. What is the gender breakdown of employees in the company?
SELECT gender,COUNT(*) AS count
FROM hr
WHERE age>=18
GROUP BY gender;

##2. What is the race/ethnicity breakdown of employees in the company?
SELECT race,COUNT(*) AS count
FROM hr
WHERE age>=18
GROUP BY race
ORDER BY count DESC;

##3. What is the age distribution of employees in the company?
SELECT MIN(age) as youngest,
       round(AVG(age),0) as average_age,
       MAX(age) as oldest
FROM hr
WHERE age>=18;

SELECT FLOOR(age/10)*10 as age_group ,
       COUNT(*) as count
FROM hr
WHERE age>=18
GROUP BY age_group
ORDER BY age_group ASC;

SELECT 
      CASE WHEN age>=18 and age <=24 THEN '18-24'
           WHEN age>=25 and age <=34 THEN '25-34'
           WHEN age>=35 and age <=44 THEN '35-44'
           WHEN age>=45 and age <=54 THEN '45-54'
           WHEN age>=55 and age <=64 THEN '55-64'
           ELSE '65+'
	  END AS age_bracket,
      gender,
      COUNT(*) AS count
FROM hr
WHERE age>=18
GROUP BY age_bracket,gender
ORDER BY age_bracket,gender;

##4. How many employees work at headquarters versus remote locations?
SELECT location,COUNT(*) as count
FROM hr
WHERE age>=18
GROUP BY location;

##5. What is the average length of employment for employees who have been terminated?
SELECT round(avg(DATEDIFF(termdate,hire_date)/365),0) as avg_length_of_employment
FROM hr
WHERE termdate<>'0000-00-00' and age>=18 and termdate<= curdate();

##6. How does the gender distribution vary across departments?
SELECT department,gender,COUNT(*) AS count
FROM hr
WHERE age>=18
GROUP BY department,gender
ORDER BY department;

##7. What is the distribution of job titles across the company?
SELECT department,jobtitle,COUNT(*) AS count
FROM hr
WHERE age>=18 
GROUP BY jobtitle,department
ORDER BY department;

##8. Which department has the highest turnover rate?
SELECT department,COUNT(*) as total_count,
       SUM(CASE WHEN termdate<=curdate() and termdate<>'0000-00-00'THEN 1 ELSE 0 END) AS terminated_count,
       SUM(CASE WHEN termdate='0000-00-00' THEN 1 ELSE 0 END) AS active_count,
       round((SUM(CASE WHEN termdate<=curdate() THEN 1 ELSE 0 END)/COUNT(*)),2) AS termination_rate
FROM hr
WHERE age>=18
GROUP BY department
ORDER BY termination_rate DESC;

##9.What is the distribution of employees across locations by state?
SELECT location_state,COUNT(*) as count
FROM hr
WHERE age>=18
GROUP BY location_state
ORDER BY count DESC;

##10. How has the company's employee count changed over time based on hire and term dates?
SELECT year,hires,terminations,
       (hires-terminations) AS net_change,
       round(((hires-terminations)/hires)*100,2) AS net_change_percentage
FROM(
    SELECT 
       year(hire_date) as year,
	   COUNT(*) AS hires,
       SUM(CASE WHEN termdate<=curdate() and termdate<>'0000-00-00' THEN 1 ELSE 0 END) as terminations
	FROM hr
    WHERE age>=18
    GROUP BY year(hire_date)
)subquery
ORDER BY net_change_percentage DESC;

##11. What is the tenure distribution for each department?
SELECT department,round(avg(datediff(curdate(),termdate)/365),1) as avg_tenure
FROM hr
WHERE age>=18 and termdate<>'0000-00-00' and termdate<=curdate()
GROUP BY department
ORDER BY avg_tenure DESC;


       
