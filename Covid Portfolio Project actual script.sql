Select *
From PortfolioProject..cvdDeaths
Where continent is not null
order by 3,4

-- Changing the format for Location on cvdDeath table

ALTER TABLE PortfolioProject..cvdDeaths 
ALTER COLUMN Location  nvarchar(150)

-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CvdDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CvdDeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CvdDeaths
--Where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CvdDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing the countries with the highest death count per population

Select Location, MAX(CAST (Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CvdDeaths
where continent is not null
Group by Location
order by TotalDeathCount desc

-- CONSIDERING BREAKDOWN BY CONTINENT


Select continent, MAX(CAST (Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..cvdDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing the continents with the highest death count per population


Select continent, MAX(CAST (Total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CvdDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

---GLOBAL NUMBERS

Select date, SUM(new_cases)as Total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100 
as DeathPercentage
From PortfolioProject..CvdDeaths
where continent is not null
Group by date
Order by 1,2



Select  SUM(new_cases)as Total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(New_cases)*100
as DeathPercentage
From PortfolioProject..CvdDeaths
where continent is not null
--Group by date
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..cvdDeaths dea
Join PortfolioProject..cvdvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- To do a rolling count of the new vaccinations per day

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPopulationVaccinated

From PortfolioProject..cvdDeaths dea
Join PortfolioProject..cvdvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
Order by 2,3


-- USE CTE

With PopvsVac (Continent, location, date, Population,new_vaccinations, RollingPopulationVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT (bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.date) as RollingPopulationVaccinated

From PortfolioProject..cvdDeaths dea
Join PortfolioProject..cvdvaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPopulationVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(150),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CvdDeaths dea
Join PortfolioProject..CvdVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *
--(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

DROP VIEW if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..cvdDeaths dea
Join PortfolioProject..cvdvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * 
From PercentPopulationVaccinated