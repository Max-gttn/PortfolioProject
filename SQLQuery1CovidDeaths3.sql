ALTER TABLE PortfolioProject..covid_deaths
  ALTER COLUMN total_deaths int;
ALTER TABLE PortfolioProject..covid_deaths
  ALTER COLUMN new_deaths int;
ALTER TABLE PortfolioProject..covid_vaccinations
  ALTER COLUMN new_vaccinations int;

--SELECT location, population
--FROM PortfolioProject.dbo.covid_deaths
--WHERE continent is null
--GROUP BY location, population
--ORDER BY 2;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths
ORDER BY 1,2

--Looking at Total cases vs Total Deaths
-- Shows likelihood of dying if you contract the covid
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE location like '%France%'
ORDER BY 1,2

--Looking at Total Cases vs Population
-- Show percentage of cases in the population
SELECT location, date, population, total_deaths, total_cases, ROUND((total_cases/population)*100,2) AS cases_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX(ROUND((total_cases/population)*100,2)) AS max_cases_percentage
FROM PortfolioProject..covid_deaths
GROUP BY location, population
ORDER BY 4 DESC;


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC;

-- Highest Death count by continent
SELECT location, population, MAX(total_deaths) AS total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is null
GROUP BY location, population
ORDER BY 3 DESC;

-- GLOBAL NUMBERS
--Cumulated World Cases and Deaths over time
SELECT date, SUM(total_cases) AS total_cases_world, SUM(total_deaths) AS total_deaths_world, ROUND((SUM(total_cases)/SUM(population))*100,2) AS cases_percentage, ROUND((SUM(total_deaths)/SUM(total_cases))*100,2) AS death_rate
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1;

--New World Cases and Deaths over time
SELECT date, SUM(new_cases) AS new_cases_world, SUM(new_deaths) AS new_deaths_world, ROUND((SUM(new_cases)/SUM(population))*100,2) AS new_cases_percentage, ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS new_death_rate
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1;

-- Looking at Total Population vs Vaccinations
-- Join covid_deaths table and covid_vaccinations table based on location & date variables

-- Calculate the most update percentage of population vaccinated
SELECT dea.location,  (SUM(vac.new_vaccinations)/MAX(dea.population))*100 AS percentage_vaccinated
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.location
ORDER BY 2

-- USE CTE to calculate evolution of percentage_population_vaccinated based on a temporary table
WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccinations_agg)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS vaccinations_agg
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--	AND dea.location = 'France'
)
SELECT *, ROUND((vaccinations_agg/population)*100,2) AS percentage_population_vaccinated
FROM PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinations_agg numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS vaccinations_agg
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--	AND dea.location = 'France'
--ORDER BY 2,3

SELECT *, ROUND((vaccinations_agg/population)*100,2) AS percentage_population_vaccinated
FROM #PercentPopulationVaccinated

-- CReating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS vaccinations_agg
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--	AND dea.location = 'France'

SELECT *
FROM PercentPopulationVaccinated