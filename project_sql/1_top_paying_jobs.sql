/*
Question: What are the top paying jobs in the dataset?
- Identify the top 10 highest paying Data Analyst jobs that are available remotely in the dataset.
- Focused on job postings with specified salaries (remove nulls)
- Why? Highlight the top paying jobs to help job seekers identify lucrative opportunities in the field of Data Analysis.
*/

SELECT 
    job_id,
    job_title_short AS job_title,
    name AS company_name,
    job_location,
    job_schedule_type,
    salary_year_avg
FROM 
    job_postings_fact
LEFT JOIN 
    company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    (job_title_short LIKE '%Data%Analyst%'
    OR job_title LIKE '%Data%Analyst%')
    AND (job_location = 'Anywhere' OR job_location LIKE '%Salvador%')
    AND salary_year_avg IS NOT NULL
ORDER BY 
    salary_year_avg DESC
LIMIT 10;