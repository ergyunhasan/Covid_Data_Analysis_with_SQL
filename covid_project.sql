USE covid_project;

-- To see quickly what data a table contains for the observation

-- coviddeaths table

SELECT * 
FROM coviddeaths
ORDER BY 
	location,
    date;

-- covidvaccinations table

SELECT * 
FROM covidvaccinations
ORDER BY 
	location,
    date;
    
-- To eliminate the anomaly regarding  continent: NULL and location : 'Asia'
 
SELECT * 
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 
	location,
    date; 

SELECT * 
FROM coviddeaths
ORDER BY 
	location,
    date;

-- Retrieving data that we are going to using

SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 
	location,
    date;

/* The calculation  of Total Cases vs Total Deaths
   Shows the probability of dying as a result of catching covid in Turkey
*/

SELECT
	location,
	date,
	total_cases,
	total_deaths,
	ROUND((total_deaths / total_cases) * 100, 2) AS death_percentage
FROM coviddeaths
WHERE location = 'Turkey' 
ORDER BY 
    date;
    

/* The calculation  of Total Cases vs Population
  Shows what percentage of population got Covid
*/

SELECT
	location,
	date,
	population,
	total_cases,
	ROUND((total_cases / population) * 100, 2) AS percent_population_infected
FROM coviddeaths
-- WHERE location = 'Turkey'
ORDER BY 
	location,
    date;

-- Countries with the Highest Infection Rates by Population

SELECT
	location,
    population,
    MAX(total_cases) AS highest_infection_count,
    ROUND(MAX((total_cases / population)) * 100, 2) AS percent_population_infected
FROM coviddeaths
GROUP BY
	location,
    population
ORDER BY
	percent_population_infected DESC;
    
-- Countries with the Highest Deaths Per Population

SELECT
	location,
    MAX(CONVERT(total_deaths, SIGNED)) as total_death_count -- to convert a value to SIGNED datatype, which has signed 64-bit integer
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY
	location
ORDER BY 
	MAX(CONVERT(total_deaths, SIGNED)) DESC;

-- Showing the continents with the highest number of deaths per population

SELECT
	continent,
    MAX(CONVERT(total_deaths, SIGNED)) as total_death_count -- to convert a value to SIGNED datatype, which has signed 64-bit integer
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY
	continent
ORDER BY 
	MAX(CONVERT(total_deaths, SIGNED)) DESC;
    
-- The Key Numbers regarding total cases, total death and the percentage of death

SELECT
	SUM(new_cases) AS total_cases,
    SUM(CONVERT(new_deaths, SIGNED)) AS total_deaths,
    ROUND(SUM(CONVERT(new_deaths, SIGNED)) / SUM(new_cases) * 100, 2) AS death_percentage
FROM coviddeaths
WHERE continent IS NOT NULL;


-- Total Population vs Vaccinations
-- Shows Percentage of Population who have received at least one Covid Vaccine

SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccination,
    SUM(CONVERT(new_vaccinations, SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS people_vaccinated
    
FROM coviddeaths cd
	INNER JOIN covidvaccinations cv
		ON cd.location = cv.location
        AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY
	cd.location,
    cd.date;

-- Calculate the percentage of the population vaccinated with CTE

WITH vaccinated_population (continent, location, date, population, new_vaccinations, people_vaccinated) AS
(SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(CONVERT(cv.new_vaccinations, SIGNED)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS people_vaccinated
    
 FROM coviddeaths cd
		INNER JOIN covidvaccinations cv
			ON cd.location = cv.location
			AND cd.date = cv.date
 WHERE cd.continent IS NOT NULL
)
SELECT *, ROUND((people_vaccinated / population) * 100, 2)
FROM vaccinated_population;