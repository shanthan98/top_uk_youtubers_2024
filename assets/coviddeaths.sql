use covidDB;

select * from CovidDeaths;

select * from CovidVaccinations;

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not null
order by 1,2;

--total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

-- total cases vs population
--shows what percent of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as covid_percentage
from CovidDeaths
where location = 'India' and continent is not null
order by 1,2;

-- countries with highest infection rate
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
--Where location like '%India%'and continent is not null
Group by Location, Population
order by location asc;

-- countries with highest deathcount per population
Select Location,MAX(cast(total_deaths as int)) as highestDeathCount
From CovidDeaths
where continent is not null
Group by Location
order by highestDeathCount desc;

-- continents with highest deathcount per population
Select continent,MAX(cast(total_deaths as int)) as highestDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by highestDeathCount desc;

-- continents with highest deathcount
Select continent,MAX(cast(total_deaths as int)) as highestDeathCount
From CovidDeaths
where continent is not null
Group by continent
order by highestDeathCount desc;

--Global Numbers
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100) AS total_death_percent
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date,2;

--total cases vs total deaths in percentage
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS INT)) AS total_deaths,
    (SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100) AS total_death_percent
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 2;

-- total population vs vaccination

with cte as(select  
	dea.continent,
	dea.location,
	dea.date,
	dea.population as population,
	vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingcountof_peoplevaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *,(rollingcountof_peoplevaccinated/population)*100 from cte

--using temp table to perform calcualtion on partition by
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingcountof_peoplevaccinated numeric
)

insert into #percentpopulationvaccinated
select  
	dea.continent,
	dea.location,
	dea.date,
	dea.population as population,
	vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as rollingcountof_peoplevaccinated
from CovidDeaths dea join CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date

select *,(rollingcountof_peoplevaccinated/population)*100 from #percentpopulationvaccinated


-- Creating View to store data.

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingcountof_peoplevaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
 
