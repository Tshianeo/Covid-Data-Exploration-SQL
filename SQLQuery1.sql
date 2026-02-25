SELECT *
FROM ProjectFile..CovidDeaths$
WHERE Continent is not null 
ORDER BY 3,4

SELECT *
FROM ProjectFile..CovidVaccinations$
ORDER BY 3,4

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProjectFile..CovidDeaths$
ORDER BY 1,2

--looking at total cases vs deaths

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM ProjectFile .. CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at the total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 as population_percentage
FROM ProjectFile .. CovidDeaths$ 
WHERE location LIKE '%states%'
ORDER BY 1,2

-- what country has the highest rate of infection rate compared to population

SELECT location, population, MAX(total_cases) as TotalDeathC, MAX((total_cases/population))*100 as populationInfectedPercentage
FROM ProjectFile .. CovidDeaths$
WHERE Continent is not null 
GROUP BY location, population
ORDER BY populationInfectedPercentage desc

-- highest death count per population

SELECT location,population, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM ProjectFile .. CovidDeaths$
WHERE Continent is not null 
GROUP BY location, population
ORDER BY HighestDeathCount DESC

--Breaking things down by continent

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM ProjectFile .. CovidDeaths$
WHERE continent is not null 
GROUP BY continent
ORDER BY HighestDeathCount DESC


-- Global Numbers
SELECT Date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths ,  SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM ProjectFile..CovidDeaths$
WHERE continent is not null
GROUP BY Date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT *
FROM ProjectFile..CovidDeaths$ dea
Join ProjectFile..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.Date ) as Rolling_people_vaccinated 
FROM ProjectFile..CovidDeaths$ dea
Join ProjectFile..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3