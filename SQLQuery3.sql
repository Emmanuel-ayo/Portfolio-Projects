SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

--Data to be using
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

--Total Cases vs Total Deaths in Nigeria
SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location ='Nigeria'
ORDER BY 2

--Total Cases vs Population
SELECT Location,date,population,total_cases, (total_cases/population)*100 AS PopulationInfected_Percentage
FROM CovidDeaths
--WHERE location ='Nigeria'
ORDER BY 2
--Countries with the highest infection rate
SELECT Location,population,MAX(total_cases) AS Highest_Cases, MAX((total_cases/population))*100 AS PopulationInfected_Percentage
FROM CovidDeaths
--WHERE location ='Nigeria'
GROUP BY Location,population
ORDER BY 4 DESC

--Countries with highest death count
SELECT Location,MAX(cast(total_deaths as int)) AS Highest_Deaths, MAX((total_deaths/population))*100 AS PopulationInfected_Percentage
FROM CovidDeaths
--WHERE location ='Nigeria'
WHERE continent is not null
GROUP BY Location
ORDER BY 2 DESC

--Continent list of deaths
SELECT continent,MAX(cast(total_deaths as int)) AS Highest_Deaths
FROM CovidDeaths
--WHERE location ='Nigeria'
WHERE continent is not null
GROUP BY continent
ORDER BY 2 DESC


--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths
,SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER by 1,2


--Total population vs vaccinations
SELECT dea.continent,dea.location,dea.date,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--Using CTE

WITH PopVsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopVsVac

--Temporary Table
DROP TABLE IF exists PopulationPercentVaccinated
CREATE TABLE PopulationPercentVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PopulationPercentVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 FROM PopulationPercentVaccinated

--Creating views for visuals
CREATE VIEW 
PopulationPercentVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PopulationPercentVaccinated