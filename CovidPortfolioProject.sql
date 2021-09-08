-- 2. Global Numbers
SELECT location as Country, SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_Cases) as DeathPercentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null 
GROUP BY location
ORDER BY 1,2;

-- 3. Death Count by continent
SELECT location as Continent, SUM(new_deaths) as TotalDeathCount
FROM PortfolioProject..covid_deaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
-- We take these out as they are redundant with continent records
-- European Union is part of Europe
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 4. Percentage of population infected
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population) as PercentPopulationInfected
FROM PortfolioProject..covid_deaths
--Where location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- 5. Evolution of population infected
SELECT location, population,date, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population) as PercentPopulationInfected
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

--6. Evolution of new cases, new deaths and death rate 
--Focus France evolutoin of new cases, new deaths and death rate 
SELECT location, date, new_cases, new_deaths, (total_deaths/total_cases) AS death_rate
FROM PortfolioProject..covid_deaths
WHERE continent is not null
--AND location like 'France'
ORDER BY 1,2

-- 7. Evolution of total cases, deaths and death rate 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) AS death_rate
FROM PortfolioProject..covid_deaths
WHERE continent is not null
--AND location like 'France'
ORDER BY 1,2

-- 8. Evolution of vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as Vaccinations
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
GROUP BY dea.continent, dea.location, dea.date, dea.population
ORDER BY 1,2,3;