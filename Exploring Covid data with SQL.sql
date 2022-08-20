/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

select *
from Portfolio_Project..Covid_Deaths$ 
where continent is not null
order by 3,4

-- selecting data from the database that is going to be used

select location, date, total_cases, new_cases, total_deaths,  population
from Portfolio_Project..Covid_Deaths$
where continent is not null
order by 1,2

--comparing total cases and total deaths as per country; shows likelyhood of dying if you contract covid in India
select location, date, total_cases, total_deaths,  (total_deaths/total_cases*100) as deathpercent
from Portfolio_Project..Covid_Deaths$
where location = 'India'
and continent is not null
order by 1,2

-- shows what percentage of deaths per population
select location, Max(cast(total_deaths as int))as TotalDeathCount
from Portfolio_Project..Covid_Deaths$
where continent is not null
group by location
order by TotalDeathCount desc

-- Countries with Highest Death Count per Population

select location, Max(cast(total_deaths as int))as TotalDeathCount 
from ..Covid_Deaths$
where continent is null
group by location
order by TotalDeathCount desc

--looking at the total cases and population
-- shows what percentage of population got covid
select location, population, Max(total_cases)as HighestInfectionCount, MAX((total_cases/population*100)) as infection_rate
from Portfolio_Project..Covid_Deaths$
group by location, population
order by infection_rate desc

--showing countries with highest death count
Select location, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project..Covid_Deaths$
where continent is NOT NULL
group by location
order by HighestDeathCount desc


--showing countries with highest death rate per population
select location, population, Max(cast(total_deaths as int))as HighestDeathCount, MAX((total_deaths/population*100)) as death_rate
from Portfolio_Project..Covid_Deaths$
where continent is NOT NULL
group by location, population
order by death_rate desc

-- Let's break things down as per the continent


--showing continents with highest death count

Select continent, MAX(cast(total_deaths as int)) as HighestDeathCount
From Portfolio_Project..Covid_Deaths$
where continent is not NULL
group by continent
order by HighestDeathCount desc


--showing continents with highest death rate per population
select continent, population, Max(cast(total_deaths as int))as HighestDeathCount, MAX((total_deaths/population*100)) as death_rate
from Portfolio_Project..Covid_Deaths$
where continent is NOT NULL
group by continent, population
order by death_rate desc


-- GLOBAL NUMBERS

select date, sum(new_cases) as tot_cases, sum(cast(new_deaths as int)) as tot_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from Portfolio_Project..Covid_Deaths$
where continent is not null
group by date
order by 1, 2


--COVID VACCINATION TABLE
-- joining two table using date and location
select *
from Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_Vaccination
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, Population, New_vaccinations, Rolling_Vaccination)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_Vaccination
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, Rolling_Vaccination/Population
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE if exists #percentage_Vaccination
Create Table #Percentage_Vaccination
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Rolling_vaccination numeric
)
Insert into #Percentage_Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_Vaccination
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, Rolling_Vaccination/Population
From #Percentage_Vaccination
order by Location, Date

-- Creating View to store data for later visualizations

Create View Percentage_Vaccination as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.date) as Rolling_Vaccination
From Portfolio_Project..Covid_Deaths$ dea
Join Portfolio_Project..Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

	select * 
	from Percentage_Vaccination
