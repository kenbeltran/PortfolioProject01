--Selecting Data that I'll be using
SELECT *
FROM 
	PortfolioProject01..CovidDeaths
WHERE continent is not NULL
ORDER BY
	3,4

--Converted total_cases from nvarchar to float 
ALTER TABLE 
	PortfolioProject01..CovidDeaths 
ALTER COLUMN 
	total_cases float

--Looking at Total Cases vs Total Deaths and Aliasing it as Death_Percentage
--Shows likelihood of dying from CoViD in a specific country
SELECT 
	Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM 
	PortfolioProject01..CovidDeaths
WHERE 
	Location = 'Philippines' --in this case I used my country Philippines as an example
ORDER BY 
	1,2

--Looking at Total Cases vs Population and Aliasing it as Death_Percentage
--Shows what percentage of population got CoViD
SELECT 
	Location, date, Population, total_cases,(total_cases/Population)*100 AS Death_Percentage
FROM 
	PortfolioProject01..CovidDeaths
WHERE 
	Location = 'Philippines' --in this case I used my country Philippines as an example
ORDER BY 
	date DESC --ordered it by date in descending order to instantly check the latest data

--Looking at Countries with Highest Infection Rate compared to Population
SELECT 
	Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/Population))*100 as Percent_Population_Infected
FROM 
	PortfolioProject01..CovidDeaths
GROUP BY
	Location, Population
ORDER BY 
	Percent_Population_Infected DESC

ALTER TABLE 
	PortfolioProject01..CovidDeaths 
ALTER COLUMN 
	total_deaths int

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 
SELECT 
	Location, MAX(total_deaths) AS Total_Death_Count
FROM 
	PortfolioProject01..CovidDeaths
WHERE continent is not NULL
GROUP BY
	Location
ORDER BY 
	Total_Death_Count DESC


--ZOOMING IN AND BREAKING THINGS DOWN BY CONTINENT
SELECT 
	Continent, MAX(total_deaths) as Total_Death_Count
FROM 
	PortfolioProject01..CovidDeaths
WHERE
	CONTINENT IS NOT NULL
GROUP BY
	Continent
ORDER BY
	Total_Death_Count DESC

--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
SELECT 
	Continent, MAX(total_deaths) as Total_Death_Count
FROM 
	PortfolioProject01..CovidDeaths
WHERE
	CONTINENT IS NOT NULL
GROUP BY
	Continent
ORDER BY
	Total_Death_Count DESC

--GLOBAL NUMBERS
SELECT
	SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM 
	PortfolioProject01..CovidDeaths
WHERE
	CONTINENT IS NOT NULL
ORDER BY
	1,2


--LOOKING AT TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVacced
FROM
	PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
ORDER BY
	2,3

--USING CTE
WITH 
	PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVacced)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVacced
FROM
	PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL
)
Select *, (RollingPeopleVacced/Population)*100 --USED TO CALCULATE THE PERCENTAGE OF PEOPLE VACCINATED IN A CERTAIN LOCATION
FROM
	PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated --ADDED TO MAKE SURE THAT IF I MAKE ALTERATIONS I DON'T HAVE TO DELETE A TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVacced numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVacced
FROM
	PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVacced/Population)*100 --USED TO CALCULATE THE PERCENTAGE OF PEOPLE VACCINATED IN A CERTAIN LOCATION
FROM
	#PercentPopulationVaccinated

--Ran into some error that the file "dbo.PercentPopulationVacced" is not showing in Views folder
use PortfolioProject01 --THIS IS THE SOLUTION I FOUND, MAIN REASON WHY IT WASN'T SHOWING WAS IT'S PROBABLY BECAUSE THE QUERY I RAN IS IN THE MAIN DATABASE 

--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS
CREATE VIEW PercentPopulationVacced as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) AS RollingPeopleVacced
FROM
	PortfolioProject01..CovidDeaths dea
JOIN PortfolioProject01..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE 
	dea.continent IS NOT NULL