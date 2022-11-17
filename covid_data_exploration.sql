/*
Exploração dos dados da COVID-19
Habilidades usadas: JOINs, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM `principal-rope-361318.covid.covid_deaths`
WHERE continent IS NOT NULL 
ORDER BY 3,4;


-- Seleciona os dados a serem usados

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `principal-rope-361318.covid.covid_deaths`
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- Total de casos vs Total de mortes
-- Mostra a probabilidade de morrer caso contraia covid no Brasil

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `principal-rope-361318.covid.covid_deaths`
WHERE location = 'Brazil'
AND continent IS NOT NULL 
ORDER BY 1,2;


-- Total de casos vs População
-- Mostra o percentual da população infectada com o vírus

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM `principal-rope-361318.covid.covid_deaths`
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- Países com o maior índice de infeccção comparada a população

SELECT location, population, MAX(total_cases) AS highest_infection_count,  MAX((total_cases/population))*100 AS percent_population_infected
FROM `principal-rope-361318.covid.covid_deaths`
WHERE continent IS NOT NULL 
Group by location, population
ORDER BY percent_population_infected DESC;


-- Países com o maior número de mortes por população

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM `principal-rope-361318.covid.covid_deaths`
--WHERE location = 'Brazil'
WHERE continent IS NOT NULL 
Group by location
ORDER BY total_death_count DESC;



-- Dividindo por continentes

-- Continentes com o maior número de mortes por população

SELECT location, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM `principal-rope-361318.covid.covid_deaths`
--WHERE location = 'Brazil'
WHERE continent IS NULL 
Group by location
ORDER BY total_death_count DESC;



-- NÙMEROS GLOBAIS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM `principal-rope-361318.covid.covid_deaths`
--WHERE location = 'Brazil'
WHERE continent IS NOT NULL 
--Group By date
ORDER BY 1,2;



-- População total vs vacinações
-- Mostra o percentual da população com pelo menos uma dose da vacina de covid

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `principal-rope-361318.covid.covid_deaths` dea
JOIN `principal-rope-361318.covid.covid_vaccinations` vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3;


-- Usando uma CTE para fazer um cálculo com PARTITION BY na query anterior

WITH PopvsVac AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `principal-rope-361318.covid.covid_deaths` dea
JOIN `principal-rope-361318.covid.covid_vaccinations` vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac;



-- Usando uma Temp Table para fazer um cálculo com PARTITION BY na query anterior

DROP TABLE IF EXISTS `principal-rope-361318.covid.PercentpopulationVaccinated`;
CREATE TABLE `principal-rope-361318.covid.PercentpopulationVaccinated`
(
continent string(255),
location string(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);

INSERT INTO PercentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `principal-rope-361318.covid.covid_deaths` dea
JOIN `principal-rope-361318.covid.covid_vaccinatiONs` vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
;
SELECT *, (rolling_people_vaccinated/population)*100
FROM PercentpopulationVaccinated
;




-- Criando uma view para armazenar os dados para visualizações

CREATE VIEW `principal-rope-361318.covid.PercentpopulationVaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
FROM `principal-rope-361318.covid.covid_deaths` dea
JOIN `principal-rope-361318.covid.covid_vaccinations` vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT *
FROM `principal-rope-361318.covid.PercentpopulationVaccinated`