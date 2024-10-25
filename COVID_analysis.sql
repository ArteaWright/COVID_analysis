SELECT * 
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL;

SELECT 
	location, 
	date,
	total_cases, 
	new_cases,
	total_deaths,
	population
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL;

-- What percentage of people who contracted COVID died in the United States? 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE location = 'United States' AND continent IS NOT NULL
ORDER BY location, date;


-- What has been the total percentage of COVID cases reported in the United States in relation to the population?

SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_percentage 
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE location = 'United States'  AND continent IS NOT NULL
ORDER BY location, date;

-- What country has the highest infection rate considering its population?

SELECT location, population, MAX(total_cases) AS highest_total_cases, MAX((total_cases/population))*100 AS infection_percentage 
FROM [COVID_analysis].[dbo].[CovidDeaths]
GROUP BY population, location
ORDER BY infection_percentage DESC;


-- Which countries had the highest death count?

SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_death_count
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_death_count DESC;


-- Which continent has the highest death count?

SELECT continent, MAX(CAST(total_deaths AS INT)) AS highest_death_count
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;


-- Death cases globally by date 
 
SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS global_death_percentage
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;


-- Death globally in total

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS global_death_percentage
FROM [COVID_analysis].[dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- What was the progresive count of new vaccination after vaccination were made available in each country?

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS INT)) 
OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS num_people_vaccinated
FROM [COVID_analysis].[dbo].[CovidDeaths] DEA
JOIN [COVID_analysis].[dbo].[CovidVaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3;


-- CTE

WITH NumOfVaccs (continent, location, date, population, new_vaccinations, num_people_vaccination) 
AS (
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS INT)) 
OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS num_people_vaccinated
FROM [COVID_analysis].[dbo].[CovidDeaths] DEA
JOIN [COVID_analysis].[dbo].[CovidVaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
)
SELECT *, (num_people_vaccination/population)*100
FROM NumOfVaccs
ORDER BY 2, 3

-- Temp Table 

DROP TABLE IF EXISTS #percent_pop_vacc;
CREATE TABLE #percent_pop_vacc(
continent nvarchar(255), 
location nvarchar(255),
Date datetime, 
population numeric, 
new_vaccinations numeric, 
num_people_vaccinated numeric
)

INSERT INTO #percent_pop_vacc 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS INT)) 
OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS num_people_vaccinated
FROM [COVID_analysis].[dbo].[CovidDeaths] DEA
JOIN [COVID_analysis].[dbo].[CovidVaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
ORDER BY 2, 3;


SELECT *, (num_people_vaccinated/population)*100
FROM #percent_pop_vacc;


-- Global View
USE COVID_analysis;

CREATE VIEW death_rate_view AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations AS INT)) 
OVER(PARTITION BY DEA.location ORDER BY DEA.location, DEA.date) AS num_people_vaccinated
FROM [COVID_analysis].[dbo].[CovidDeaths] DEA
JOIN [COVID_analysis].[dbo].[CovidVaccinations] VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL

SELECT *
FROM death_rate_view;


