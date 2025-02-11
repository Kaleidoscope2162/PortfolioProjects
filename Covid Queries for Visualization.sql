-- Queries used for Tablaeu Project

-- 1.

SELECT
    SUM(TRY_CAST(new_cases AS float)) AS total_cases,
    SUM(TRY_CAST(new_deaths AS float)) AS total_deaths,
    SUM(TRY_CAST(new_deaths AS float)) * 100.0 / NULLIF(SUM(TRY_CAST(new_cases AS float)), 0) AS DeathPercentage
From 
	PortfolioProject..CovidDeath
where 
	continent is not null 
order by 
	1,2

--2.

SELECT 
    location,
    SUM(ISNULL(TRY_CAST(NULLIF(new_deaths, '') AS INT), 0)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeath
WHERE 
    continent IS NULL
    AND location NOT IN ('World', 'European Union', 'International')
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;

--3.

Select 
    Location, 
    Population, 
    MAX(total_cases) as HighestInfectionCount,  
    Max((CAST(total_cases AS float)/CAST(population AS float)))*100 as PercentPopulationInfected
From 
	PortfolioProject..CovidDeath
Group by 
	Location, Population
order by 
	PercentPopulationInfected desc

--4.

Select 
    Location, 
    Population, 
	date,
    MAX(total_cases) as HighestInfectionCount,  
    Max((CAST(total_cases AS float)/CAST(population AS float)))*100 as PercentPopulationInfected
From 
	PortfolioProject..CovidDeath
Group by 
	Location, Population, date
order by 
	PercentPopulationInfected desc