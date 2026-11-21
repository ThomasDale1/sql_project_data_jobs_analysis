/*
Question: What are the most optimal skills to learn (aka it is in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries for Data Analyst roles
- Concentrates on remote positions with specified salaries
- Why: To help job seekers make informed decisions about which skills to invest time and resources into learning, based on their market value and demand.
*/

WITH skills_demand AS (
    SELECT
        skills_dim.skill_id,
        skills,
        COUNT(skills_job_dim.job_id) AS skill_count
    FROM
        job_postings_fact
    INNER JOIN
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = true
    GROUP BY
        skills_dim.skill_id
), high_salary_skills AS(
    SELECT
        skills_dim.skill_id,
        skills,
        ROUND(AVG(salary_year_avg), 2) AS average_salary
    FROM
        job_postings_fact
    INNER JOIN
        skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN
        skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = true
    GROUP BY
        skills_dim.skill_id
)
SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    skill_count,
    average_salary
FROM
    skills_demand
INNER JOIN
    high_salary_skills ON skills_demand.skill_id = high_salary_skills.skill_id
WHERE
    skill_count > 25
    AND average_salary > 70000
ORDER BY
    average_salary DESC,
    skill_count DESC
LIMIT
    25;

/*
[
  {
    "skill_id": 8,
    "skills": "go",
    "skill_count": "27",
    "average_salary": "115319.89"
  },
  {
    "skill_id": 80,
    "skills": "snowflake",
    "skill_count": "37",
    "average_salary": "112947.97"
  },
  {
    "skill_id": 74,
    "skills": "azure",
    "skill_count": "34",
    "average_salary": "111225.10"
  },
  {
    "skill_id": 76,
    "skills": "aws",
    "skill_count": "32",
    "average_salary": "108317.30"
  },
  {
    "skill_id": 79,
    "skills": "oracle",
    "skill_count": "37",
    "average_salary": "104533.70"
  },
  {
    "skill_id": 185,
    "skills": "looker",
    "skill_count": "49",
    "average_salary": "103795.30"
  },
  {
    "skill_id": 1,
    "skills": "python",
    "skill_count": "236",
    "average_salary": "101397.22"
  },
  {
    "skill_id": 5,
    "skills": "r",
    "skill_count": "148",
    "average_salary": "100498.77"
  },
  {
    "skill_id": 182,
    "skills": "tableau",
    "skill_count": "230",
    "average_salary": "99287.65"
  },
  {
    "skill_id": 7,
    "skills": "sas",
    "skill_count": "63",
    "average_salary": "98902.37"
  },
  {
    "skill_id": 186,
    "skills": "sas",
    "skill_count": "63",
    "average_salary": "98902.37"
  },
  {
    "skill_id": 61,
    "skills": "sql server",
    "skill_count": "35",
    "average_salary": "97785.73"
  },
  {
    "skill_id": 183,
    "skills": "power bi",
    "skill_count": "110",
    "average_salary": "97431.30"
  },
  {
    "skill_id": 0,
    "skills": "sql",
    "skill_count": "398",
    "average_salary": "97237.16"
  },
  {
    "skill_id": 215,
    "skills": "flow",
    "skill_count": "28",
    "average_salary": "97200.00"
  },
  {
    "skill_id": 196,
    "skills": "powerpoint",
    "skill_count": "58",
    "average_salary": "88701.09"
  },
  {
    "skill_id": 181,
    "skills": "excel",
    "skill_count": "256",
    "average_salary": "87288.21"
  },
  {
    "skill_id": 192,
    "skills": "sheets",
    "skill_count": "32",
    "average_salary": "86087.79"
  },
  {
    "skill_id": 188,
    "skills": "word",
    "skill_count": "48",
    "average_salary": "82576.04"
  }
]
*/