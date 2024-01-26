-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio.dbo.CovidDeaths2024
where location like '%states%'
and (total_deaths/total_cases)*100 is not null
and location not like '%virgin%'
order by 2

-- Looking at Total Cases_USA vs Population_USA
-- Shows what percentage of US population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from ProjectPortfolio.dbo.CovidDeaths2024
where location like '%states%'
and (total_cases/population)*100 is not null
and location not like '%virgin%'
order by 2

-- Looking at Countries with Highest Infection Rate compared to Population
select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/ population))*100 as PercentPopulationInfected
from ProjectPortfolio.dbo.CovidDeaths2024
Group by location, population 
Order by PercentPopulationInfected desc

-- Showing Countries with highest death count per Population
select location, MAX(total_deaths) as TotalDeathCount
from ProjectPortfolio.dbo.CovidDeaths2024
where continent is not null
Group by location
Order by TotalDeathCount desc

-- Breaking down by Continent
select location, MAX(total_deaths) as TotalDeathCount
from ProjectPortfolio.dbo.CovidDeaths2024
where continent is null
and location not like '%income%'
Group by location
Order by TotalDeathCount desc

-- Showing continents with highest death count
select continent, MAX(total_deaths) as TotalDeathCount
from ProjectPortfolio.dbo.CovidDeaths2024
where continent is not null
and location not like '%income%'
Group by continent
Order by TotalDeathCount desc

-- Global numbers
Select SUM(new_cases) Total_Cases, sum(new_deaths) Total_Deaths, 
			sum(new_deaths)/sum(new_cases)*100 DeathPercentage
from ProjectPortfolio.dbo.CovidDeaths2024
where continent is not null
and new_cases is not null
--Group by date
order by 1,2



-- Looking at Total Population vs Vaccinations
-- Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio.dbo.CovidDeaths2024 dea
join ProjectPortfolio.dbo.covid_vac_2024  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
from PopvsVac

-- Creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio.dbo.CovidDeaths2024 dea
join ProjectPortfolio.dbo.covid_vac_2024  vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated

