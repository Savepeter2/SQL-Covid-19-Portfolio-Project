
select * from
 PortfolioProject..CovidDeathsUpdated
--CASE 1 SCENARIO

--Let's explore the total cases, the total_deaths, PercentageDeathRate--which indicates the likelihood of dying when diagnosed with covid daily
--Let's Explore for Nigeria

select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as PercentDeathRate
from PortfolioProject..CovidDeathsUpdated
where location = 'Nigeria'
Order by 2 

--CASE 2 SCENARIO 

--Exploring Countries with their total cases, total deaths, PercentOfthePopulationInfected, PercentPopulationDead
--and their population in descending order of total cases


select location,sum(CAST(new_cases as INT)) as TotalCases, sum(CAST(new_deaths as INT)) as TotalDeaths, population,
sum(CAST(new_cases as INT))/population*100 as PercentPopulationInfected,
sum(CAST(new_deaths as INT))/population*100 as PercentPopulationDead
from PortfolioProject..CovidDeathsUpdated
where continent is not null
group by location, population
order by PercentPopulationInfected desc


--CASE 3 SCENARIO

--Looking Countries and their Population, HighestInfectionCount, HighestDeathCount, PercentDeathRatePerPopulation,PercentPopulationInfected 

select location, population,max(total_cases) as HighestInfectionCount,
MAX(CONVERT(INT,total_deaths)) as HighestDeathCount,
MAX(CONVERT(INT, total_deaths)/population)*100 as PercentDeathRatePerPopulation,
max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeathsUpdated
where continent is not null
GROUP by location, population
order by PercentPopulationInfected desc) 




--Looking at Global Numbers (Total Cases, Total Deaths, Total Population, Death Percentage, Cases Percentage

select SUM(new_cases) as Total_Cases, SUM(CONVERT(INT, new_deaths)) as Total_Deaths, 
SUM(CONVERT(INT, new_deaths))/SUM(new_cases)*100 as WorldsDeathPercentage, 
SUM(new_cases)/sum(population)*100 as WorldsCasesPercentage, 
sum(population) as Total_Population

from PortfolioProject..CovidDeathsUpdated
where continent is not null
order by 1,2;


--Looking at Countries daily cases,cumulative cases, deaths, cumulative deaths, vaccinations and cumulative vaccinations.
 
 With CountriesExplore (continent, location, date, population, new_cases, CummulativeCases, new_deaths, CummulativeDeaths, new_vaccinations, 
 CummulativeVaccinations) as 

 (
select dea.continent, dea.location, dea.date, dea.population,
dea.new_cases, SUM(dea.new_cases) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeCases,
dea.new_deaths, SUM(CAST(dea.new_deaths AS BIGINT)) OVER (Partition by dea.location order by dea.location, dea.date) as CummulativeDeaths,


vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (Partition by dea.location Order by
dea.location, dea.date) as CummulativeVaccinations

from PortfolioProject..CovidDeathsUpdated dea
join PortfolioProject..CovidVaccinationUpdated vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 2,3)

--select * from CountriesExplore 

--In order to explore daily percentage of population vaccinated, percentage of population dead, percentage of cases
select continent, location, date, population, CummulativeCases/population*100 as PercentCases
, CummulativeDeaths/population*100 as PercentPopulationDead, CummulativeVaccinations/population*100 as PercentPopulationVaccinated
from CountriesExplore


--CASE 6 SCENARIO

--Looking at Continents and their Total Cases and Deaths in descending order of Total Cases
select continent,sum(CAST(new_cases as INT)) as TotalCases, sum(CAST(new_deaths as INT)) as TotalDeaths
from PortfolioProject..CovidDeathsUpdated
where continent is not null 
group by continent
order by TotalCases desc

--Looking at Continents and their Total Deaths in descending order of Total Deaths
select continent, sum(CAST(new_deaths as INT)) as TotalDeaths
from PortfolioProject..CovidDeathsUpdated
where continent is not null 
group by continent
order by TotalDeaths desc


--Looking at Continent and their Total Vaccinations in descending order of Total Vaccinations
select continent,sum(CAST(new_vaccinations as BIGINT)) as TotalVaccinations
from PortfolioProject..CovidVaccinationUpdated
where continent is not null 
group by continent
order by TotalVaccinations desc