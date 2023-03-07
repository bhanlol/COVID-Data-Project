USE covid_portfolio_project;

SELECT *
FROM CovidDeaths
ORDER BY 3, 4;

SELECT *
FROM CovidVaccinations
ORDER BY 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2;

-- Looking at Total Cases vs Total Deaths
-- Mortality rate by country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
ORDER BY 1, 2;

-- U.S. mortality rates
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location LIKE '%united states%'
ORDER BY 1, 2;

-- Looking at total cases vs. population
-- Shows what percentage of population contracted COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Contraction_Percentage
FROM CovidDeaths
WHERE location LIKE '%united states%'
ORDER BY 1, 2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Highest_Contraction_Count, (MAX(total_cases)/population)*100 AS Total_Contraction_Percentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Death count by country
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- Death count by continent
SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

-- Global numbers
-- Mortality rate
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Mortality_Rate
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Total population vs. vaccinations
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Vaxxed_Rolling
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
		AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE

WITH Vax_Percentage (continent, location, date, population, new_vaccinations, Total_Vaxxed_Rolling)
AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Vaccinations_Rolling
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
		AND CD.date = CV.date
WHERE CD.continent IS NOT NULL
)
SELECT *, (Total_Vaxxed_Rolling/Population)*100 AS Vaxxed_Percentage_Rolling
FROM Vax_Percentage;

-- TEMP TABLE

DROP TABLE IF exists #Vaccination_Rate
CREATE TABLE #Vaccination_Rate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_Vaccinations_Rolling numeric
)

INSERT INTO #Vaccination_Rate
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Vaccinations_Rolling
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
		AND CD.date = CV.date

SELECT *, (Total_Vaccinations_Rolling/Population)*100
FROM #Vaccination_Rate;



-- Creating view to store data for later visualizations

CREATE VIEW Vaccination_Percentage AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
	SUM(CONVERT(int, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Total_Vaxxed_Rolling
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
		AND CD.date = CV.date
WHERE CD.continent IS NOT NULL;

SELECT *
FROM Vaccination_Percentage;