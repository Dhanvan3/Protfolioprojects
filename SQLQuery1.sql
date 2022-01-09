select *
From SQL1..coviddeath
where continent is not null
order by 3,4;


--select *
--from SQL1..vaccinations
--where continent is not null
--order by 3,4;

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From sql1..coviddeath
where continent is not null
order by 1,2;

-- looking at total cases vs total death

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From sql1..coviddeath
where location like '%india%'
and continent is not null
order by 1,2;



-- Looking at the total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as PresentPopulationInfected
From sql1..coviddeath
-- where location like '%india%'
where continent is not null
order by 1,2;


-- Looking at countries with highest infection rate compared to population

select location, population,  max(total_cases) as Highestinfectionrate, max((total_cases/population))*100 as PresentPopulationInfected
From sql1..coviddeath
-- where location like '%india%'
where continent is not null
group by population,location
order by PresentPopulationInfected desc;



-- Showing the countries with highest death count per Population


select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From sql1..coviddeath
-- where location like '%india%'
where continent is not null
group by location
order by TotalDeathCount desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with highest death counts

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From sql1..coviddeath
-- where location like '%india%'
where continent is not null
group by continent
order by TotalDeathCount desc;



-- Global Numbers


select sum(new_cases) as TotalCases
,sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From sql1..coviddeath
--where location like '%india%'
 where continent is not null
 --group by date
order by 1,2;

-- Looking at Total Population vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From sql1..coviddeath dea
join Sql1..vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL1..CovidDeath dea
Join SQL1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3







-- USE CTE

with popvsvac ( Continent, Location, date, Population,New_Vaccinations,RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From sql1..coviddeath dea
join Sql1..vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from popvsvac;





-- Temp Table

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From sql1..coviddeath dea
join Sql1..vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated;

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Sql1..CovidDeath dea
Join SQL1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- creating view to store data for later visualizations


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From SQL1..CovidDeath dea
Join Sql1..Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null ;

select * from
PercentPopulationVaccinated;