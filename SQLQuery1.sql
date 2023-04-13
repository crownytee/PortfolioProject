select *
from portfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select *
--from portfolioProject.dbo.CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths. Get the total Death Pecentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Total death Percentage based on a particular Location
-- Shows the likelihood of dying if someone contract covid in this location.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject.dbo.CovidDeaths
where continent is not null and location like '%States%'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioProject.dbo.CovidDeaths
where continent is not null and location like '%Africa%'
order by 1,2

--Total Cases vs Population
--Show the percentage of population that has contracted Covid based on a location
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentInfected
from portfolioProject.dbo.CovidDeaths
where continent is not null and location like '%States%'
order by 1,2

--Show the percentage of population that has contracted Covid in Europe
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentInfected
from portfolioProject.dbo.CovidDeaths
where continent is not null and location like 'EU%'
order by 1,2

--Show the percentage of population that has contracted Covid in Africa.
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentInfected
from portfolioProject.dbo.CovidDeaths
where continent is not null and location like '%Africa%'
order by 1,2

--Get Country with Highest Infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationPercentInfected
from portfolioProject.dbo.CovidDeaths
where continent is not null
Group by location, population
order by PopulationPercentInfected Desc

--Countries with Highest Death Count per Population
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not null
Group by location
order by TotalDeathCount Desc

--
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is null
Group by location
order by TotalDeathCount desc

--Continents with Highest Death Count
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from portfolioProject.dbo.CovidDeaths
--where location like '%States%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers, Death Percentage per day
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from portfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
order by 1,2

--Death Percentage across the World
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
from portfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-- Total amount of People in the world that has been vaccinated per Day.
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 --new column created can't be used for division, so use cte or temp table to complete it. 
from portfolioProject.dbo.CovidDeaths dea
Join portfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioProject.dbo.CovidDeaths dea
Join portfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from popvsVac


-- USE TEMP TABLE
DROP Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioProject.dbo.CovidDeaths dea
Join portfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated

--Creating View to store data for visualizations
create  view percentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
,dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from portfolioProject.dbo.CovidDeaths dea
Join portfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Use for visualization later
select *
from percentPopulationVaccinated