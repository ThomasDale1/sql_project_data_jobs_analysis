# Introducción

Proyecto de SQL que explora el mercado laboral de analistas de datos: qué puestos remotos pagan más, qué habilidades piden, cuáles son las más demandadas y cuáles conviene aprender primero.

Consultas SQL: [project_sql/](project_sql/)

# Contexto

Hice este proyecto para practicar SQL con un conjunto de datos real y, al mismo tiempo, descubrir qué habilidades debería priorizar como aspirante a Analista de Datos.

El dataset contiene ofertas de trabajo con título, ubicación, salario, indicador de trabajo remoto y las habilidades requeridas. Está dividido en cuatro tablas (CSV en [csv_files/](csv_files/)):

- `job_postings_fact`: las ofertas (título, ubicación, tipo de jornada, salario anual promedio, indicador de remoto, ...).
- `company_dim`: la empresa detrás de cada oferta.
- `skills_dim`: el catálogo de habilidades.
- `skills_job_dim`: tabla puente que relaciona ofertas y habilidades.

Las preguntas que quería responder:

1. ¿Cuáles son los trabajos de Analista de Datos mejor pagados?
2. ¿Qué habilidades requieren esos trabajos mejor pagados?
3. ¿Cuáles son las habilidades más demandadas?
4. ¿Qué habilidades se asocian con salarios más altos?
5. ¿Cuáles son las habilidades más óptimas para aprender (alta demanda **y** alto salario)?

# Herramientas que utilicé

- **SQL**: el núcleo del análisis (joins, CTEs, agregaciones, filtros).
- **PostgreSQL**: motor de base de datos con el que ejecuté las consultas.
- **Visual Studio Code**: editor para escribir y ejecutar las consultas.
- **Git y GitHub**: control de versiones y para compartir el proyecto.

# El análisis

Cada consulta de [project_sql/](project_sql/) responde una de las preguntas anteriores.

## 1. Trabajos de Analista de Datos mejor pagados

Busqué las 10 ofertas de Analista de Datos mejor pagadas que son remotas (`Anywhere`, más ubicaciones de El Salvador) y tienen salario especificado, uniendo `job_postings_fact` con `company_dim` para obtener el nombre de la empresa.

```sql
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
```

Ofertas mejor pagadas (las que listan habilidades, tomadas de los resultados de la consulta 2):

| Puesto | Empresa | Salario anual promedio |
|---|---|---|
| Associate Director- Data Insights | AT&T | $255,829 |
| Data Analyst, Marketing | Pinterest Job Advertisements | $232,423 |
| Data Analyst (Hybrid/Remote) | Uclahealthcareers | $217,000 |
| Principal Data Analyst (Remote) | SmartAsset | $205,000 |
| Director, Data Analyst - HYBRID | Inclusively | $189,309 |
| Principal Data Analyst, AV Performance Analysis | Motional | $189,000 |
| Principal Data Analyst | SmartAsset | $186,000 |
| Senior Data Analyst | Patterned Learning AI | $185,000 |

Conclusiones:

- Los salarios van desde **$185K hasta ~$256K** al año, muy por encima del salario típico de un analista.
- Los puestos mejor pagados son senior (Principal, Director, Associate Director), pero un simple "Data Analyst" en Pinterest o UCLA Health también llega a $217K–$232K.
- Hay una gran variedad de empleadores: telecomunicaciones, redes sociales, salud, fintech y vehículos autónomos.

## 2. Habilidades de los trabajos mejor pagados

Usando la consulta anterior como CTE, uní los trabajos mejor pagados con `skills_job_dim` y `skills_dim` para ver qué habilidades piden.

```sql
WITH top_paying_jobs AS (
    SELECT
        job_id,
        job_title,
        name AS company_name,
        job_location,
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
    LIMIT 10
)
SELECT
    top_paying_jobs.*,
    skills
FROM
    top_paying_jobs
INNER JOIN
    skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN
    skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC;
```

Frecuencia de habilidades entre las 8 ofertas mejor pagadas que listan habilidades:

| Habilidad | Ofertas (de 8) |
|---|---|
| SQL | 8 |
| Python | 7 |
| Tableau | 6 |
| R, Excel, AWS, Snowflake, Pandas | 3 cada una |
| Azure, Power BI, Oracle | 2 cada una |

Conclusiones:

- **SQL aparece en todas las ofertas** y **Python en 7 de 8**, por lo que son la base de un perfil de analista bien pagado.
- **Tableau** es la herramienta de visualización más pedida (6 de 8), por delante de Power BI.
- Las herramientas de nube y data warehouse (AWS, Azure, Snowflake) y las de Atlassian (Jira, Confluence, Bitbucket) aparecen en los puestos más senior.

## 3. Habilidades más demandadas

Conté cuántas veces aparece cada habilidad en **todas** las ofertas del dataset y me quedé con las 5 primeras.

```sql
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
```

| Habilidad | Menciones |
|---|---|
| SQL | 385,750 |
| Python | 381,863 |
| AWS | 145,718 |
| Azure | 132,851 |
| R | 131,285 |

Conclusiones:

- **SQL y Python** son, por mucho, las habilidades más demandadas, con casi 3 veces las menciones de las siguientes.
- Las plataformas de nube (AWS, Azure) vienen justo después. Esta consulta abarca todos los puestos del dataset (no solo Analista de Datos), por eso las habilidades de nube aparecen tan arriba.

## 4. Habilidades mejor pagadas

Calculé el salario promedio de las ofertas de Analista de Datos para cada habilidad y me quedé con las 25 más altas.

```sql
SELECT
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
GROUP BY
    skills
ORDER BY
    average_salary DESC
LIMIT
    25;
```

Top 10 (la lista completa de 25 está en el archivo SQL):

| Habilidad | Salario promedio |
|---|---|
| SVN | $400,000 |
| Solidity | $179,000 |
| Couchbase | $160,515 |
| DataRobot | $155,486 |
| Golang | $155,000 |
| MXNet | $149,000 |
| dplyr | $147,633 |
| VMware | $147,500 |
| Terraform | $146,734 |
| Twilio | $138,500 |

Conclusiones:

- Las habilidades mejor pagadas son **herramientas de nicho orientadas a ingeniería**: DevOps/infraestructura (Terraform, VMware, Puppet, Ansible, GitLab), big data (Kafka, Cassandra, Airflow, Scala) y machine learning (PyTorch, TensorFlow, Keras, Hugging Face, MXNet).
- Muchas tienen muy pocas ofertas detrás. Los $400K de SVN son claramente un valor atípico (probablemente una sola oferta), por lo que los promedios de habilidades poco frecuentes deben leerse con cautela.

## 5. Habilidades más óptimas para aprender

Combiné demanda y salario con dos CTEs. Se enfoca en trabajos remotos de Analista de Datos con salario especificado, y conserva las habilidades con más de 25 ofertas y un salario promedio superior a $70K.

```sql
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
), high_salary_skills AS (
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
```

| Habilidad | Ofertas | Salario promedio |
|---|---|---|
| Go | 27 | $115,320 |
| Snowflake | 37 | $112,948 |
| Azure | 34 | $111,225 |
| AWS | 32 | $108,317 |
| Oracle | 37 | $104,534 |
| Looker | 49 | $103,795 |
| Python | 236 | $101,397 |
| R | 148 | $100,499 |
| Tableau | 230 | $99,288 |
| SAS | 63 | $98,902 |
| SQL Server | 35 | $97,786 |
| Power BI | 110 | $97,431 |
| SQL | 398 | $97,237 |
| Flow | 28 | $97,200 |
| PowerPoint | 58 | $88,701 |
| Excel | 256 | $87,288 |
| Sheets | 32 | $86,088 |
| Word | 48 | $82,576 |

Conclusiones:

- **Lenguajes de programación:** Python (236 ofertas, ~$101K) y R (148, ~$100K) combinan fuerte demanda con buen salario. Go paga más, pero se pide mucho menos.
- **Nube y data warehouses:** Snowflake, Azure y AWS ofrecen salarios más altos ($108K–$113K) con demanda moderada: un buen segundo paso después de lo básico.
- **Visualización:** Tableau (230) y Power BI (110) son muy demandadas, con ~$97K–$99K; Looker paga un poco más con menor demanda.
- **Fundamentos:** SQL es la habilidad más pedida (398 ofertas) con un promedio de ~$97K. Excel sigue siendo muy común (256), pero es la que menos paga de las herramientas centrales (~$87K).

# Lo que aprendí

- **Joins:** combinar la tabla de hechos con las tablas de dimensiones y la tabla puente (`skills_job_dim`) para pasar de ofertas a habilidades y empresas.
- **CTEs:** dividir preguntas complejas en pasos legibles, reutilizar una consulta dentro de otra y combinar dos agregaciones (demanda + salario) en la consulta 5.
- **Agregación:** `COUNT`, `AVG` y `ROUND` con `GROUP BY` para convertir ofertas en bruto en conclusiones.
- **Filtrado:** patrones con `LIKE`, `IS NOT NULL` e indicadores booleanos para aislar los puestos que me interesan.
- **La calidad de los datos importa:** los valores atípicos (SVN con $400K) y las entradas duplicadas del catálogo (`sas` aparece dos veces con distinto `skill_id`) pueden distorsionar los resultados, por eso son importantes los umbrales mínimos como `skill_count > 25`.
- **Hacer la pregunta correcta:** los mismos datos cuentan historias distintas según los filtros (todos los puestos vs. Analista de Datos, remoto vs. cualquier ubicación).

# Conclusiones

1. **Trabajos mejor pagados:** los puestos remotos de Analista de Datos pueden pagar desde $185K hasta ~$256K al año, con los títulos senior y de liderazgo en la cima.
2. **Habilidades de los trabajos mejor pagados:** SQL es requerido en todos, seguido de Python y Tableau.
3. **Habilidades más demandadas:** SQL y Python lideran todo el mercado laboral por un amplio margen.
4. **Habilidades mejor pagadas:** los promedios más altos vienen de habilidades de ingeniería de nicho (DevOps, big data, ML), pero las muestras pequeñas las hacen poco fiables.
5. **Habilidades óptimas:** empezar por **SQL, Python y Tableau/Power BI** por la demanda, y luego sumar **nube (AWS/Azure) y Snowflake** para aumentar el potencial salarial.

En conjunto, dominar SQL y Python y complementarlos con una herramienta de visualización y algo de conocimiento de nube es el camino más sólido hacia un puesto de Analista de Datos bien remunerado.
