select *
from PortfolioProject..CovidDeaths
order by 3, 4

use PortfolioProject
--select *
--from PortfolioProject..CovidVaccinations
--order by 3, 4

--SELECT DATA THAT WE ARE GOING TO BE USING

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY
SELECT location, date, total_cases, total_deaths, ROUND(total_deaths / total_cases * 100, 2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY location, date


--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date, population, total_cases, ROUND(total_cases / population * 100, 2) AS PercentPopulationInfected
FROM CovidDeaths
ORDER BY location, date


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--where location = 'India'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMEBRS

SELECT date, SUM(new_cases) as total_cases, SUM(cast (new_deaths as int)) as total_deaths, (SUM(cast (new_deaths as int))/SUM(new_cases)*100) as Death_Percentage
FROM CovidDeaths
--where location = 'india'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 


--LOOKING AT TOTAL POPULATION VS VACCINATIONS
--USE CTE
with CTE_PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null --and dea.location = 'india'
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 from CTE_PopvsVac


--temp table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)


insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100 from PercentPopulationVaccinated



--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated