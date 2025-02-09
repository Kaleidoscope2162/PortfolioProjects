SELECT
    location,
    date,
    population,
    total_cases,
    total_deaths,
    CASE 
        WHEN TRY_CAST(total_cases AS BIGINT) = 0 THEN NULL
        ELSE (TRY_CAST(total_deaths AS FLOAT) / TRY_CAST(total_cases AS FLOAT)) * 100 
    END AS death_percentage,
    CASE 
        WHEN TRY_CAST(population AS BIGINT) = 0 THEN NULL
        ELSE (TRY_CAST(total_cases AS FLOAT) / TRY_CAST(population AS FLOAT)) * 100 
    END AS infection_percentage
FROM
    PortfolioProject..CovidDeath
WHERE
	location like '%Philippines%'
ORDER BY
	1,2

-- Looking at Total Population vs Vaccination

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
	OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath AS dea
JOIN PortfolioProject..CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null
ORDER BY
	2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(bigint,vac.new_vaccinations)) 
	OVER (Partition by dea.location 
	ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath AS dea
JOIN PortfolioProject..CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	TRY_CAST(dea.population AS numeric(18, 2)) AS population,
    TRY_CAST(vac.new_vaccinations AS numeric(18, 2)) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS numeric(18, 2))) 
        OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath AS dea
JOIN PortfolioProject..CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
ORDER BY
	1,2


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated
AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	TRY_CAST(dea.population AS numeric(18, 2)) AS population,
    TRY_CAST(vac.new_vaccinations AS numeric(18, 2)) AS new_vaccinations,
    SUM(TRY_CAST(vac.new_vaccinations AS numeric(18, 2))) 
        OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath AS dea
JOIN PortfolioProject..CovidVaccination as vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE
	dea.continent is not null

Select *
FROM PercentPopulationVaccinated