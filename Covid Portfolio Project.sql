/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where location like '%states' 
order by 1,2



-- Looking at the total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states'
order by 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, date, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by PercentagePopulationInfected desc


-- Showing the countries with the Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- LETS BREAK THINGS DOWN BY CONTINENT
-- Showing the continents with the higest death count per population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null and location not like '%income%' and location not in ('World','International','European Union')
group by location 
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select sum(new_cases)as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2, 3



--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating View to store data for visulizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
