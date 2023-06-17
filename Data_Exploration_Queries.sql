/* GUIDED PROJECT ON DATA EXPLORATION (MSsql)- THE ALEX ANALYST
   
   DATA SET - COVID-19 
   
   Website: https://ourworldindata.org/coronavirus 


1> At frst, we have placed the population column after the date column in the excel sheet 
	and then we have splitted the data set in to 2
      - CovidDeaths
      - CovidVaccination
2> We have converted the dataset CSV format to .xlsx format whihc would help to connect to MSsql
3> Using the option 'SQL server 2019 import and export' option we can import the data from excel to sql.
*/

***********************************************************************************************************************************

---- To fetch the data from both CovidDeath and CovidVaccination tables----

select *
from PortfolioProject..CovidDeaths;

select *
from PortfolioProject..CovidVaccinations;

---- Fetch the data where the continent is not null ----

select *
from PortfolioProject..CovidDeaths
--where continent is not null --303723 rows
where continent is null --16309 row
order by 3,4;

---- To fetch the data from CovideDeaths ----

select location,date,population,total_cases,new_cases
from PortfolioProject..CovidDeaths
order by 1,2;

--- In date column, there is no need of time.We can update the column ----

select date, convert(date,[date])
from PortfolioProject..CovidDeaths;

Alter table PortfolioProject..CovidDeaths
add ConvertedDate date;

update PortfolioProject..CovidDeaths
set ConvertedDate=convert(date,[date]);

select *
from PortfolioProject..CovidDeaths;

select location,ConvertedDate,population,total_cases,new_cases
from PortfolioProject..CovidDeaths
order by 1,2;

----  1> To fetch how many total deaths happened in total cases, which gives death percentage 
---- OR
---- Dying cases in our country [ Logic: (total death/total case)*100]

select location,ConvertedDate,population,total_cases,total_deaths,
(convert(float,[total_deaths])/convert(float,[total_cases]))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location='United Kingdom'
order by 2 desc ;

---- 2> To fetch what percent of total population has got COVID
---- Total cases Vs Population
---- What percent of population got COVID [Logic : (total case/population)*100]

select location,ConvertedDate,population,total_cases,
(convert(float,total_cases)/population)*100 as Percentage_Population_Infected
from PortfolioProject..CovidDeaths
where location='United Kingdom'
order by Percentage_Population_Infected desc;

---- 3> To fetch the countries with highest infection rate compared to population
---- Logic : to get the countries with maximum of total case 

select location,population,max(total_cases) as Highest_infected_rate,
max((convert(float,total_cases)/population)*100) as Percentage_Population_Infected
from PortfolioProject..CovidDeaths
group by location,population
order by Percentage_Population_Infected desc;

---- 4> Showing countries with highest death count per population

Select Location,continent,
MAX(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location,continent
order by TotalDeathCount desc;


---- BREAK DOWN BY CONTINENTS ----

---- 5>To fetch continents with the highest death count per population ----

select continent,max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc;


	*************************** GLOBAL NUMBERS *************************************

---- 6> To get the GLOBAL NUMBERS on death cases comparing the new cases with new deaths
---  Overall across the world we are looking at the  death percentage of 0.9% ~ 1%
---- Total new cases:768272973
---- Total_new deaths :6959019

select 
sum(new_cases) as total_new_cases,
sum(new_deaths) as total_new_deaths,
CASE
	when sum(new_cases)<>0 then (sum(new_deaths)/sum(new_cases))*100
	else 'Cannot divide by 0'
END as Total_New_Death_Percentage

from PortfolioProject..CovidDeaths
where continent is not null
order by Total_New_Death_Percentage desc;


--- In date column, there is no need of time.We can update the column ----

select date, convert(date,[date])
from PortfolioProject..CovidVaccinations;

Alter table PortfolioProject..CovidVaccinations
add ConvertedDate date;

update PortfolioProject..CovidVaccinations
set ConvertedDate=convert(date,[date]);

select *
from PortfolioProject..CovidVaccinations;
use 

---- 7>To fetch the population percentage who have atleast vaccinted once ----

select CD.continent,CD.location,CD.ConvertedDate,CD.population,CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by CD.location)
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
on CD.ConvertedDate=CV.ConvertedDate
where CD.continent is not null
--order by 1,2,3;


--- USE CTE to compute the population percentage i.e,Total amount of people in the world that have been vaccinated
--- Analysis:

with CTE1 (Continent,Location,Date,Population,New_Vaccinations,rolling_people_vaccinated)
as (
select CD.continent,
	   CD.location,
	   CD.date,
	   CD.population,
	   CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by CD.location order by CD.location,CD.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
on CD.date=CV.date AND
	CD.location=CV.location
where CD.continent is not null
			)
select *,(rolling_people_vaccinated/Population)*100 as percent_population_vaccinated
from CTE1
--order by percent_population_vaccinated desc; 



---- Use TEMP Table 
---- USE DROP Table table_name; if table is previously existed

DROP Table Temp;
Create table Temp
( Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  rolling_people_vaccinated numeric
)

Insert into Temp
select CD.continent,
	   CD.location,
	   CD.date,
	   CD.population,
	   CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by CD.location order by CD.location,CD.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
on CD.date=CV.date AND
	CD.location=CV.location
where CD.continent is not null

select *,(rolling_people_vaccinated/Population)*100 as percent_population_vaccinated
from Temp;


---- View ----

Create View ViewTemp as
select CD.continent,
	   CD.location,
	   CD.date,
	   CD.population,
	   CV.new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by CD.location order by CD.location,CD.date) as rolling_people_vaccinated
from PortfolioProject..CovidDeaths CD
join PortfolioProject..CovidVaccinations CV
on CD.date=CV.date AND
	CD.location=CV.location
where CD.continent is not null;

















