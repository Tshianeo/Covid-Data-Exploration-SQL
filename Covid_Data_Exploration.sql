-- =========================================
-- VIEWING RAW DATA
-- =========================================

SELECT *
FROM ProjectFile..CovidDeaths$
WHERE Continent IS NOT NULL
ORDER BY 3, 4;

SELECT *
FROM ProjectFile..CovidVaccinations$
ORDER BY 3, 4;


-- =========================================
-- SELECT DATA THAT WE ARE GOING TO USE
-- =========================================

SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
FROM ProjectFile..CovidDeaths$
ORDER BY 1, 2;


-- =========================================
-- TOTAL CASES VS TOTAL DEATHS
-- =========================================

SELECT Location, Date, Total_Cases, Total_Deaths,
       (Total_Deaths / Total_Cases) * 100 AS Death_Percentage
FROM ProjectFile..CovidDeaths$
WHERE Location LIKE '%states%'
ORDER BY 1, 2;


-- =========================================
-- TOTAL CASES VS POPULATION
-- =========================================

SELECT Location, Date, Total_Cases, Population,
       (Total_Cases / Population) * 100 AS Population_Percentage
FROM ProjectFile..CovidDeaths$
WHERE Location LIKE '%states%'
ORDER BY 1, 2;


-- =========================================
-- COUNTRY WITH HIGHEST INFECTION RATE
-- =========================================

SELECT Location,
       Population,
       MAX(Total_Cases) AS TotalDeathC,
       MAX((Total_Cases / Population)) * 100 AS PopulationInfectedPercentage
FROM ProjectFile..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PopulationInfectedPercentage DESC;


-- =========================================
-- HIGHEST DEATH COUNT PER COUNTRY
-- =========================================

SELECT Location,
       Population,
       MAX(CAST(Total_Deaths AS INT)) AS HighestDeathCount
FROM ProjectFile..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY HighestDeathCount DESC;


-- =========================================
-- HIGHEST DEATH COUNT BY CONTINENT
-- =========================================

SELECT Continent,
       MAX(CAST(Total_Deaths AS INT)) AS HighestDeathCount
FROM ProjectFile..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY HighestDeathCount DESC;


-- =========================================
-- GLOBAL NUMBERS BY DATE
-- =========================================

SELECT Date,
       SUM(New_Cases) AS Total_Cases,
       SUM(CAST(New_Deaths AS INT)) AS Total_Deaths,
       SUM(CAST(New_Deaths AS INT)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM ProjectFile..CovidDeaths$
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1, 2;


-- =========================================
-- TOTAL POPULATION VS VACCINATIONS (JOIN)
-- =========================================

SELECT *
FROM ProjectFile..CovidDeaths$ dea
JOIN ProjectFile..CovidVaccinations$ vac
    ON dea.Location = vac.Location
    AND dea.Date = vac.Date;


-- =========================================
-- ROLLING PEOPLE VACCINATED
-- =========================================

SELECT dea.Continent,
       dea.Location,
       dea.Date,
       dea.Population,
       vac.New_Vaccinations,
       SUM(CAST(vac.New_Vaccinations AS INT))
           OVER (PARTITION BY dea.Location
                 ORDER BY dea.Location, dea.Date) AS Rolling_People_Vaccinated
FROM ProjectFile..CovidDeaths$ dea
JOIN ProjectFile..CovidVaccinations$ vac
    ON dea.Location = vac.Location
    AND dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL
ORDER BY 2, 3;


-- =========================================
-- USING CTE
-- =========================================

WITH PopvsVac (Continent, Location, Date, Population,
               New_Vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.Continent,
           dea.Location,
           dea.Date,
           dea.Population,
           vac.New_Vaccinations,
           SUM(CAST(vac.New_Vaccinations AS INT))
               OVER (PARTITION BY dea.Location
                     ORDER BY dea.Location, dea.Date) AS Rolling_People_Vaccinated
    FROM ProjectFile..CovidDeaths$ dea
    JOIN ProjectFile..CovidVaccinations$ vac
        ON dea.Location = vac.Location
        AND dea.Date = vac.Date
    WHERE dea.Continent IS NOT NULL
)

SELECT *,
       (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;


-- =========================================
-- USING TEMP TABLE
-- =========================================

CREATE TABLE #PercentagePopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    Rolling_People_Vaccinated NUMERIC
);

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.Continent,
       dea.Location,
       dea.Date,
       dea.Population,
       vac.New_Vaccinations,
       SUM(CAST(vac.New_Vaccinations AS INT))
           OVER (PARTITION BY dea.Location
                 ORDER BY dea.Location, dea.Date) AS Rolling_People_Vaccinated
FROM ProjectFile..CovidDeaths$ dea
JOIN ProjectFile..CovidVaccinations$ vac
    ON dea.Location = vac.Location
    AND dea.Date = vac.Date;

SELECT *,
       (Rolling_People_Vaccinated / Population) * 100
FROM #PercentagePopulationVaccinated;


-- =========================================
-- CREATING VIEW FOR VISUALISATIONS
-- =========================================

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.Continent,
       dea.Location,
       dea.Date,
       dea.Population,
       vac.New_Vaccinations,
       SUM(CAST(vac.New_Vaccinations AS INT))
           OVER (PARTITION BY dea.Location
                 ORDER BY dea.Location, dea.Date) AS Rolling_People_Vaccinated
FROM ProjectFile..CovidDeaths$ dea
JOIN ProjectFile..CovidVaccinations$ vac
    ON dea.Location = vac.Location
    AND dea.Date = vac.Date
WHERE dea.Continent IS NOT NULL;

SELECT*
FROM PercentagePopulationVaccinated