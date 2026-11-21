/*
Question: What are the most in-demand skills
- Join job postings to inner join table similar to query 2
- Identify the top 5 most frequently listed skills.
- Focus on all job postings.
- Why? Highlighting the most in-demand skills can help job seekers focus on developing the skills that are most valued by employers.
*/

SELECT
    skills,
    COUNT(skills_job_dim.job_id) AS skill_count
FROM
    job_postings_fact
INNER JOIN
    skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
GROUP BY
    skills
ORDER BY
    skill_count DESC
LIMIT
    5;
