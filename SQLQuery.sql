	
	
	
	select * from Deaths
	where continent is not null  
	order by 1,2;


	SELECT * FROM Vaccinations
	where continent is not null 
	ORDER BY 2,3;


	Select DATE,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From Deaths
	--Where Loc like '%states%'
	where continent is not null 
	Group By date
	order by 1,2;


	---> sclecting the data 
	select Loc,date,total_cases,new_cases,total_deaths,population
	from Deaths
	where continent is not null 
	order by 1,2;


	------>death percentage for the peaple got covied
	select Loc,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpersantage, population
	from Deaths
	where continent is not null 
	--and Loc = 'india'
	order by 1,2;
	

	-------->Death percentage due to COVID19 over total popultion <----------------		 -
	select Loc,date,total_deaths, population,(total_deaths/population)*100 as deathpersantage 
	from Deaths
	where continent is not null 
	--and Loc = 'india'
	--where Loc LIKE 'Pakistan'
	--where Loc  like '%state%'
	order by 2;


	-------> grouped by Countries with Highest Death percentage due to COVID19
	select Loc,MAX(total_deaths) Max_Deaths, population,MAX(deathpersantage) AS Max_Deathpersantage
	from(select Loc,date,total_deaths, population,(total_deaths/population)*100 as deathpersantage 
	from Deaths) AS X
	GROUP BY Loc,population
	ORDER BY 2 DESC;


	select Loc,MAX(total_deaths) Max_Deaths, population,MAX((total_deaths/population))*100 as Max_Deathpersantage 
	from Deaths
	GROUP BY Loc,population
	order by 2 DESC;


	
	-----------> COVID19 Infected persantage over total populatuion 

	select Loc,date,total_cases,total_deaths,population,(total_cases/population)*100 as COVID_InfectedPercent_overPoplatuion 
	from Deaths
	--where Loc = 'india'
	--where Loc  like '%state%'

	-------->Countries with Highest COVID19 Infection Rate over Population
	
	select Loc,max(total_cases) max_num_Cases,population,max((total_cases/population))*100 as COVID_InfectedPercent_overPoplatuion
	from Deaths
	group by Loc,population
	order by COVID_InfectedPercent_overPoplatuion desc;

	
	-- BREAKING THINGS DOWN BY CONTINENT
	Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From Deaths
	--Where Loc like '%states%'
	Where continent is not null 
	Group by continent
	order by TotalDeathCount;

-----------------------------------------------------------------------------------------------------

	--->Total Population vs Vaccinations
	--->Shows Percentage of Population that has recieved at least one Covid Vaccine

	Select dea.continent, dea.Loc, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Loc Order by dea.Loc, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From Deaths dea
	Join Vaccinations vac
		On dea.Loc = vac.Loc
		and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3
	

	----> using CTE 

	With PopvsVac (Continent, Loc, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.Loc, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Loc Order by dea.Loc, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From Deaths	dea
	Join Vaccinations vac
		On dea.Loc = vac.Loc
		and dea.date = vac.date
	where dea.continent is not null 
	)
	Select *, (RollingPeopleVaccinated/Population)*100 as  PeopleVaccinatedPercentage
	From PopvsVac


	-----> Using Temp Table to perform Calculation on Partition By in previous 

	DROP Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Loc nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPopulationVaccinated
	Select dea.continent, dea.Loc, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Loc Order by dea.Loc, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From Deaths dea
	Join Vaccinations vac
		On dea.Loc = vac.Loc
		and dea.date = vac.date
	--where dea.continent is not null 
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	-- Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.Loc, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Loc Order by dea.Loc, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From Deaths dea
	Join Vaccinations vac
		On dea.Loc = vac.Loc
		and dea.date = vac.date
	where dea.continent is not null 

	select * from PercentPopulationVaccinated

