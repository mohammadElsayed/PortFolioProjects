use PortfolioProject
--select *
--from CovidDeaths
--order by 3,4

select*
from PortfolioProject..CovidVaccinations
where continent is not null
order by 3,4


----select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2

---looking at Total Cases vs Total Deaths

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPersentage
from CovidDeaths
where location like '%Egypt%'
and continent is not null
order by 1,2

--SELECT SUM(CAST(total_cases AS int)) 
--FROM CovidDeaths
--where location like '%Egypt%'

--looking for Total Cases vs Population
select location,date,population,total_cases, (total_cases/population)*100 as PopulationPersentage
from CovidDeaths
where location like '%Egypt%'
and continent is not null
order by 1,2

--looking for Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount , max((total_cases/population))*100 as PopulationInfectedPersentage
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by location,population
order by 4 desc

--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by location
order by totalDeathCount desc


---Let's Break Things Down By Continent


---showing continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as totalDeathCount
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
group by continent
order by totalDeathCount desc

---Global Numbers

select  sum(new_cases) as Total_Cases, sum(cast(new_deaths as int )) as Total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPersentage
from CovidDeaths
--where location like '%Egypt%'
where continent is not null
--group by date
order by 1,2


--looking at Total population vs vaccinations

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use CTE

with popvsVac (continent, location, data, population, new_vaccinations, rollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select* , (rollingPeopleVaccinated/population)*100
from popvsVac



--TEMP TABLE
Drop Table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into  #percentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select* , (rollingPeopleVaccinated/population)*100
from #percentPopulationVaccinated


--create view to store for later visualizations

Create view  percentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentPopulationVaccinated