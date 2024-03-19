
--Check the overall data on CovidDeaths
--
select *
FROM Portfolio..CovidDeaths
ORDER BY 3,4
--


--Select Data that we are going to using
--
Select location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
ORDER BY 1,2
--


--Looking at Total cases vs Total deaths
--Indicate the probability of dying if you contract covid in your country.
--
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Deathpercentage
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2
--


--Looking at the Total cases vs Population
--Indicate the infection rate of your country.
--
Select location, date, population, total_cases, (total_cases / population)*100 as infection_rate
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2
--


--Looking at Countries with Highest Infection Rate compared to Population
--
Select location, population, MAX(total_cases) as highest_total_cases, MAX((total_cases / population)*100) as infection_rate
FROM Portfolio..CovidDeaths
GROUP BY location, population
ORDER BY infection_rate desc
--


--Looking at Population Density vs Infection rate
--Indicate these two variables have no correlation
--
Select location, population, population_density, MAX(total_cases) as highest_total_cases, MAX((total_cases / population)*100) as infection_rate
FROM Portfolio..CovidDeaths
GROUP BY location, population, population_density
ORDER BY population_density desc
--


--Looking at Countries with Highest Death Count per Population
--
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC
--
--And Let's see the Highest Death Count on Continent
--
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC
--


--Global Numbers
--Indicate the daily cases and deaths throughout the world.
--
Select date, 
       SUM(new_cases) as global_dailycases, 
       SUM(cast(new_deaths as int)) as global_dailydeaths,
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
--
--Indicate Covid's DeathPercentage globaly is around 2.11%
--
Select SUM(new_cases) as global_dailycases, 
       SUM(cast(new_deaths as int)) as global_dailydeaths,
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2
--




--Join tables for further analysis
--
select *
FROM Portfolio..CovidDeaths as dea
JOIN Portfolio..CovidVaccinations as vac
    ON dea.date = vac.date
    and dea.location = vac.location
--

--Looking at Total Population vs Total Vaccination
--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccinated)
as
(
select dea.continent, 
       dea.location, 
       dea.date,
       dea.population, 
       vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as vaccinated
FROM Portfolio..CovidDeaths as dea
JOIN Portfolio..CovidVaccinations as vac
    ON dea.date = vac.date
    and dea.location = vac.location
WHERE dea.continent is not null
)
SELECT date, location, population, vaccinated, vaccinated/population*100 as vaccination_percentage
FROM PopvsVac
WHERE vaccinated/population*100 is not null
--


--Looking at Total Population vs Total Vaccination
--Use TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
vaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as vaccinated
FROM Portfolio..CovidDeaths as dea
JOIN Portfolio..CovidVaccinations as vac
    ON dea.date = vac.date
    and dea.location = vac.location
WHERE dea.continent is not null

SELECT *, vaccinated/population*100 as vaccination_percentage
FROM #PercentPopulationVaccinated
--


--Creating View to store data for visualiztions
CREATE VIEW Global_vaccination_percentage AS
WITH PopvsVac (continent, location, date, population, new_vaccinations, vaccinated)
as
(
select dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations,
       SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as vaccinated
FROM Portfolio..CovidDeaths as dea
JOIN Portfolio..CovidVaccinations as vac
    ON dea.date = vac.date
    and dea.location = vac.location
WHERE dea.continent is not null
)
SELECT date, location, population, vaccinated, vaccinated/population*100 as vaccination_percentage
FROM PopvsVac
WHERE vaccinated/population*100 is not null
--
CREATE VIEW Global_DailyCases AS
Select date, 
       SUM(new_cases) as global_dailycases, 
       SUM(cast(new_deaths as int)) as global_dailydeaths,
       SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
--
CREATE VIEW Continent_TotalDeathCount AS
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is null
GROUP BY location
--
CREATE VIEW USA_covid_Deathrate AS
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as Deathpercentage
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
--
CREATE VIEW USA_infection_rate AS
Select location, date, population, total_cases, (total_cases / population)*100 as infection_rate
FROM Portfolio..CovidDeaths
WHERE location like '%states%'
--
CREATE VIEW Global_infection_rate AS
Select location, population, MAX(total_cases) as highest_total_cases, MAX((total_cases / population)*100) as infection_rate
FROM Portfolio..CovidDeaths
GROUP BY location, population
--
CREATE VIEW Global_TotalDeathCount AS
Select location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY location, population
--
