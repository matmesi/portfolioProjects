select *
from PortfolioProjectCovid..CovidDeaths
order by 3,4;
;
--select *
--from PortfolioProjectCovid..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, total_deaths
FROM PortfolioProjectCovid..CovidDeaths
where continent is not null 
ORDER BY 1,2
;
--Looking at Total Cases vs Total Deaths
--Show likelihood of dying when contracting Covid

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2
;
--Looking at Total Cases vs Total Deaths per country
--Show likelihood of dying when contracting Covid per country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
WHERE location like '%canada%'
AND continent is not null 
ORDER BY 1,2
;
--Looking at Total Cases vs Population
--Shows percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
WHERE location like '%canada%'
AND continent is not null 
ORDER BY 1,2
;
--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not null 
GROUP BY location, population
ORDER BY PercentPopulationInfected desc
;
--Looking at countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc
;
--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProjectCovid..CovidDeaths
Where continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc
;

--Showing global death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null 
--Group By date
order by 1,2
;
-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
;
-- Using CTE to perform calculation on partition by in previous query

WITH cte_1 (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProjectCovid..CovidDeaths AS dea
JOIN PortfolioProjectCovid..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as POP_Vaccinated
FROM cte_1
ORDER BY 2,3
;

-- Creating View to store data for later visualizations

-- Total Population vs Vaccinations
-- Shows percentage of population that has recieved at least one covid vaccine

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjectCovid..CovidDeaths dea
Join PortfolioProjectCovid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
;

--Looking at Total Cases vs Total Deaths
--Show likelihood of dying when contracting Covid

Create View TotalCasesvsTotalDeaths as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjectCovid..CovidDeaths
WHERE continent is not null 
--ORDER BY 1,2

--Showing global death percentage

Create View GlobalDeathPercentage as
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProjectCovid..CovidDeaths
where continent is not null 
--Group By date
--order by 1,2