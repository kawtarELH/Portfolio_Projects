USE PortfolioProject;

-- Select Data that we gonna use

select Location, date, total_cases, new_cases, total_deaths, Population
from PortfolioProject..covidDeaths
where continent is not null
order by 1, 2


-- Looking at total cases vs total deaths
-- Shows likelihood of hying if you contract covid in your country 
select Location, date, total_cases, total_deaths, (total_deaths / population)*100 as DeathPercentage
from PortfolioProject..covidDeaths
where location like '%morocco%' and continent is not null
order by 1, 2

-- Looking at Total Cases vs Population
-- shows what percentage of population got covid
select Location, date, Population, total_cases, (total_cases / Population)*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%morocco%'
order by 1, 2


-- Looking at countries with Highest infection rate compared to Population

select Location,Population ,MAX(total_cases) as HighestInfectionCount, MAX((total_cases / Population)*100) as PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%morocco%'
where continent is not null
group by location, Population
order by PercentPopulationInfected desc


-- Showing countries with Highest Death Count per Population

select Location, MAX(total_deaths) as HighestDeathCount
from PortfolioProject..covidDeaths
--where location like '%morocco%'
where continent is not null
group by location
order by HighestDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per Population

select continent, MAX(total_deaths) as HighestDeathCount
from PortfolioProject..covidDeaths
--where location like '%morocco%'
where continent is not null
group by continent
order by HighestDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(NULLIF(new_cases, 0))*100 AS DeathPercentage
from PortfolioProject..covidDeaths
--where location like '%morocco%' 
where continent is not null
--group by date
order by 1, 2


-- looking at total population vs vaccination

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeapleVaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location 
order by dea.location, dea.date) RollingPeapleVaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (RollingPeapleVaccinated/population)*100 vaccinated_percentage
from PopvsVac

-- USE TEMP TABLE

DROP TABLE IF exists #PercentPopVac
create table #PercentPopVac
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date date,
    Population numeric,
    new_vaccinations numeric,
    RollingPeapleVaccinated numeric
)

INSERT INTO #PercentPopVac
SELECT dea.continent, dea.location, dea.date, dea.population,
       CAST(vac.new_vaccinations AS numeric) AS new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS numeric)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeapleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
--WHERE vac.continent IS NOT NULL
--ORDER BY 2, 3;

-- Select the result with the vaccinated percentage
SELECT *, (RollingPeapleVaccinated / population) * 100 AS vaccinated_percentage
FROM #PercentPopVac;


-- creating view to store data for later visualizations

DROP VIEW IF EXISTS PercentPopVac;

CREATE VIEW PercentPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population,
       CAST(vac.new_vaccinations AS numeric) AS new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS numeric)) 
           OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeapleVaccinated
FROM PortfolioProject..covidDeaths dea
JOIN PortfolioProject..covidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE vac.continent IS NOT NULL;
--ORDER BY 2, 3;


select *
from PercentPopVac
