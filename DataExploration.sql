select * 
from PortfolioProject#1..CovidDeaths
order by 3, 4;



-- Select data for using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject#1..CovidDeaths
where continent is not null
order by 1, 2;

-- Total cases vs total deaths
-- Refer it to show numbers in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject#1..CovidDeaths
where continent is not null
--and location = 'Vietnam'
order by 1, 2;

-- Total cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InfectionRateByCountry
from PortfolioProject#1..CovidDeaths
where continent is not null
--and location = 'Vietnam'
order by 1, 2;

-- Highest Infection rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject#1..CovidDeaths
where continent is not null
group by location, population
order by 4 desc;

-- Showing highest death count per population by countries

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject#1..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc;

-- Showing total new death count by continent

select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from PortfolioProject#1..CovidDeaths
where continent is null
and location not in ('Upper middle income','European Union','High Income','World','Lower middle income','Low income', 'International')
group by location
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) TotalNewDeaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject#1..CovidDeaths
where continent is not null;


-- Total population vs new vaccinations

--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) 
--	as RollingPeopleVaccinated
--from PortfolioProject#1..CovidDeaths dea
--join PortfolioProject#1..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3;

-- CTE:

with vacvspop 
as 
(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject#1..CovidDeaths dea
join PortfolioProject#1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from vacvspop;

-- Temp table:

drop table if exists #VaccinatedPercentage
create table #VaccinatedPercentage
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #VaccinatedPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) 
	as RollingPeopleVaccinated
from PortfolioProject#1..CovidDeaths dea
join PortfolioProject#1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from #VaccinatedPercentage;


-- Create view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.date) 
	as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated


