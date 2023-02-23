SELECT * FROM DAPortfolioProj..Covid_Deaths
ORDER BY 3,4;

--SELECT * FROM DAPortfolioProj..CovidVaccines$
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, population, total_deaths
FROM DAPortfolioProj..Covid_Deaths
ORDER BY 1,2;

-- Looking at Deaths vs Cases Gives 1.2% chance of dyibg by Covid in India
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as 'Death Percentage'
FROM DAPortfolioProj..Covid_Deaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Cases vs Population gives 3.15% chance of getting oneself covid in India
SELECT location, date, total_cases,population, total_deaths, round((total_cases/population)*100,2) as 'Case Percentage'
FROM DAPortfolioProj..Covid_Deaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at countries with highest infection compared to its population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount , MAX(round((total_cases/population)*100,2)) as PercentPopulationInfected
FROM DAPortfolioProj..Covid_Deaths
GROUP BY location, population
ORDER BY 4 DESC;

-- Looking at countries with highest deaths to its population
SELECT location, population, MAX(cast(total_deaths as int)) AS HighestDeaths , MAX(round((total_deaths/population)*100,2)) as PercentPopulationDied
FROM DAPortfolioProj..Covid_Deaths
where continent is not null
GROUP BY location, population
ORDER BY 3 DESC;

-- Breaking them down by Continent
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeaths , MAX(round((total_deaths/population)*100,2)) as PercentPopulationDied
FROM DAPortfolioProj..Covid_Deaths
where continent is  null
GROUP BY location
ORDER BY 2 DESC;

SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeaths , MAX(round((total_deaths/population)*100,2)) as PercentPopulationDied
FROM DAPortfolioProj..Covid_Deaths
where continent is not null
GROUP BY continent
ORDER BY 2 DESC;

-- Looking at Global Numbers
SELECT date, SUM(new_cases) AS TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100,2)
as PercentPopulationDied
FROM DAPortfolioProj..Covid_Deaths
where continent is not null
GROUP BY date
ORDER BY 1;

SELECT SUM(new_cases) AS TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, ROUND((SUM(cast(new_deaths as int))/SUM(new_cases))*100,2)
as DeathPercentage
FROM DAPortfolioProj..Covid_Deaths
where continent is not null
ORDER BY 1;


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DAPortfolioProj..Covid_Deaths dea
JOIN DAPortfolioProj..CovidVaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DAPortfolioProj..Covid_Deaths dea
JOIN DAPortfolioProj..CovidVaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 FROM PopvsVac

-- Creating Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated  -- Helps when you are doing changes
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DAPortfolioProj..Covid_Deaths dea
JOIN DAPortfolioProj..CovidVaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated


-- Creating Views to store data for later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM DAPortfolioProj..Covid_Deaths dea
JOIN DAPortfolioProj..CovidVaccines$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated
