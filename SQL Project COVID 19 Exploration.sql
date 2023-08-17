
/* 
Covid 19 Data Exploration
Dataset retrieved from https://ourworldindata.org/covid-deaths

SQL Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Views, Data Type Conversion, Subqueries
*/


--Previewing the Data
SELECT *
From PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

SELECT *
From PortfolioProject..CovidVaccinations
Where continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at the Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
Where location like '%states%' and continent is not null
Order by 1,2


-- TOTAL CASES VS POPULATION
-- Shows percentage of the United States population that got Covid.
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths 
Where location like '%states%' and continent is not null
Order by 1,2

-- Shows Countries with the highest infection rate
SELECT Location, MAX(total_cases) as MaxCases, population, MAX((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by InfectedPercentage DESC

--Show Countries with the highest death
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC

--CONTINENTAL DATA 
--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Global Numbers 
--Shows daily total cases, total deaths, and death percentage sorted by date.
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Shows Global cases, deaths, and death percentage.
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations
-- Shows a rolling number of the population that has received a COVID vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Using CTE to perform calculations on partition by to find percent population that is vaccinated.
With PopVac (continent, location, date, population, New_Vaccinations, RollingVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinated/Population)*100 AS PercentVaccinated
From PopVac

-- Using Temp Table to perform calculations on partition by to find percent population that is vaccinated.
DROP TABLE IF EXISTS #PercentVaccinated
Create Table #PercentVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingVaccinated numeric
)

Insert Into #PercentVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingVaccinated/Population)*100 AS PercentVaccinated
From #PercentVaccinated

-- Create View to store data for later visualizations
Create View PercentVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

