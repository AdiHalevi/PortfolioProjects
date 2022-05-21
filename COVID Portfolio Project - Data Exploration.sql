/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


*/



-- Select Data that we are going to be starting with

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE location like '%israel%'
ORDER BY 1,2 ;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location,population,total_cases,(total_cases/population)*100 AS PercentPoulationInfected
FROM CovidDeaths
WHERE location like '%israel%'
ORDER BY 1,2 


-- Countries with Highest Infection Rate compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPoulationInfected
FROM CovidDeaths
--WHERE location like '%israel%'
GROUP BY location,population
ORDER BY PercentPoulationInfected DESC


-- Countries with Highest Death Count per Population


SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%israel%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS


SELECT date, SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 


SELECT  SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


SELECT dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(convert(int,vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query


WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(SELECT dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations )) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT  *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations )) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date
--WHERE dea.continent is not null

SELECT  *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population ,vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations )) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date
WHERE dea.continent is not null

