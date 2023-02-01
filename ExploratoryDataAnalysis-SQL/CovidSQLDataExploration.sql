----------------------- DATA EXPLORATION ------------------------------------

-- Select all the columns from Covid Death table
Select *
From Portfolio.dbo.CovidDeaths$
--where continent is not null
Order by 3,4

-- Select certain attributes from database
Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio.dbo.CovidDeaths$
Order by 1,2

-- Total Cases vs Total Deaths in United States
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio.dbo.CovidDeaths$
Where location like '%states%'
Order by 5

--- Looking at Number of cases per 100K Population
Select Location, date, total_cases, population, (total_cases/population)*100000 as CasesPer100KPop
From Portfolio.dbo.CovidDeaths$
Order by 5 DESC

--- Countries with highest infection rate
--- Looking at Number of cases per 100K Population
Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentagePopInfected
From Portfolio.dbo.CovidDeaths$
Group by location, population
Order by PercentagePopInfected desc


--- Looking at the countries with Highest Death Count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeaths$
where continent is not null
Group by location
Order by TotalDeathCount desc


--- Review Data based on Continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc


--- Continents with highest death count per population
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio.dbo.CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio.dbo.CovidDeaths$
Where continent is not null
Group by date
Order by 1

-- Total population vs vaccination using CTE
With PopVsVaccin (continent, location, date, population,new_vaccinations, RollingPplVaccinated)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition By d.location Order By d.location) as RollingPplVaccinated
---, (RollingPplVaccinated/population)*100
From Portfolio.dbo.CovidDeaths$ d
JOIN Portfolio.dbo.CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not null
)
Select *, (RollingPplVaccinated/population)*100
From PopVsVaccin


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition By d.location Order By d.location) as RollingPplVaccinated
From Portfolio.dbo.CovidDeaths$ d
JOIN Portfolio.dbo.CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not null

Select *, (RollingPplVaccinated/Population)*100
From #PercentPopulationVaccinated


--- Create View to store data for later

Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
, SUM(cast(v.new_vaccinations as bigint)) OVER (Partition By d.location Order By d.location) as RollingPplVaccinated
From Portfolio.dbo.CovidDeaths$ d
JOIN Portfolio.dbo.CovidVaccinations$ v
	ON d.location = v.location
	and d.date = v.date
Where d.continent is not nu_ll