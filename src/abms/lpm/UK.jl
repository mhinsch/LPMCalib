"""
    create UK towns and houses. 

    This source file is included in the model LPMABMs.jl 
"""

# adjustedDensity = density * densityModifier

# future candidate 
# createUKTowns(variables,parameters,properties)

export createUKDemography # createUKTowns, createUKHouses 

import SocialAgents: Town, House, Person, undefinedHouse 

import SocialABMs: SocialABM, add_agent!, allagents

function createUKTowns(properties) 

    uktowns = Town[] 
    
    for y in 1:properties[:mapGridYDimension]
        for x in 1:properties[:mapGridXDimension] 
            town = Town((x,y),density=properties[:ukMap][y,x])
            push!(uktowns,town)
        end
    end

    uktowns
end 


function createUKPopulation(properties) 

    population = Person[] 

    for i in 1 : properties[:initialPop]
        ageMale = rand((properties[:minStartAge]:properties[:maxStartAge]))
        ageFemale = ageMale - rand((-2:5))

        if(ageFemale < 24)
            ageFemale = 24
        end 

        # the following is direct translation but it does not ok 
        birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        # why not 
        # birthYear = properties[:startYear]  - ageMale/Female 
        birthMonth = rand((1:12))

        newMan = Person(undefinedHouse,ageMale,
                        birthYear=birthYear,birthMonth=birthMonth,gender="Male")
        

        # This a direct translation 
        # The birthYear & birthMonth does not seem correct  
        newWoman = Person(undefinedHouse,ageFemale,
                          birthYear=birthYear,birthMonth=birthMonth,gender="Female")   

        newMan.partner = newWoman 
        newWoman.partner = newMan.partner
        
        push!(population,newMan)
        push!(population,newWoman) 

    end # for 

    population

end # createUKPopulation 

#= 

self.allPeople = []
        self.livingPeople = []
        for i in range(int(initial)/2):
            ageMale = random.randint(minStartAge, maxStartAge)
            ageFemale = ageMale - random.randint(-2,5)
            if ( ageFemale < 24 ):
                ageFemale = 24
            birthYear = startYear - random.randint(minStartAge,maxStartAge)
            classes = [0, 1, 2, 3, 4]
            probClasses = [0.2, 0.35, 0.25, 0.15, 0.05]
            classRank = np.random.choice(classes, p = probClasses)
            
            workingTime = 0
            for i in range(int(ageMale)-int(workingAge[classRank])):
                workingTime *= workDiscountingTime
                workingTime += 1
            
            dKi = np.random.normal(0, wageVar)
            initialWage = incomeInitialLevels[classRank]*math.exp(dKi)
            dKf = np.random.normal(dKi, wageVar)
            finalWage = incomeFinalLevels[classRank]*math.exp(dKf)
            
            c = np.math.log(initialWage/finalWage)
            wage = finalWage*np.math.exp(c*np.math.exp(-1*incomeGrowthRate[classRank]*workingTime))
            income = wage*weeklyHours
            workExperience = workingTime
            tenure = np.random.randint(50)
            birthMonth = np.random.choice([x+1 for x in range(12)])
            newMan = Person(None, None,
                            birthYear, ageMale, 'male', None, None, classRank, classRank, wage, income, 0, initialWage, finalWage, workExperience, 'worker', True, tenure, birthMonth)
            
            workingTime = 0
            for i in range(int(ageFemale)-int(workingAge[classRank])):
                workingTime *= workDiscountingTime
                workingTime += 1
                
            dKi = np.random.normal(0, wageVar)
            initialWage = incomeInitialLevels[classRank]*math.exp(dKi)
            dKf = np.random.normal(dKi, wageVar)
            finalWage = incomeFinalLevels[classRank]*math.exp(dKf)
            
            c = np.math.log(initialWage/finalWage)
            wage = finalWage*np.math.exp(c*np.math.exp(-1*incomeGrowthRate[classRank]*workingTime))
            income = wage*weeklyHours
            workExperience = workingTime
            tenure = np.random.randint(50)
            birthMonth = np.random.choice([x+1 for x in range(12)])
            newWoman = Person(None, None,
                              birthYear, ageFemale, 'female', None, None, classRank, classRank, wage, income, 0, initialWage, finalWage, workExperience, 'worker', True, tenure, birthMonth)

            # newMan.status = 'independent adult'
            # newWoman.status = 'independent adult'
            
            newMan.partner = newWoman
            newWoman.partner = newMan
            
            self.allPeople.append(newMan)
            self.livingPeople.append(newMan)
            self.allPeople.append(newWoman)
            self.livingPeople.append(newWoman)

=# 


function createUKDemography(properties) 

    #TODO distribute properties among ambs and MABM  

    ukTowns  = SocialABM{Town}(createUKTowns,properties) # TODO delevir only the requird properties and substract them 
    ukHouses = SocialABM{House}()              
    ukPopulation = SocialABM{Person}(createUKPopulation,properties)

    # create houses within towns 
    towns = allagents(ukTowns) 
    for town in towns
        if town.density > 0 
            adjustedDensity = town.density * properties[:mapDensityModifier]

            for hx in 1:ukTowns.properties[:townGridDimension]  # TODO employ getproperty
                for hy in 1:ukTowns.properties[:townGridDimension] 

                    if(rand() < adjustedDensity)
                        house = House(town,(hx,hy))
                        add_agent!(house,ukHouses)
                    end

                end # for hy 
            end # for hx 
        end # if town.density 
    end # for town 

    (ukTowns,ukHouses)
end 

    #=

    self.x = tx
    self.y = ty
    self.houses = []
    self.name = str(tx) + "-" + str(ty)
    self.LHA = [lha1, lha2, lha3, lha4]
    self.id = Town.counter
    Town.counter += 1
    if density > 0.0:
        adjustedDensity = density * densityModifier
        for hy in range(int(townGridDimension)):
            for hx in range(int(townGridDimension)):
                if random.random() < adjustedDensity:
                    newHouse = House(self,cdfHouseClasses,
                                     classBias,hx,hy)
                    self.houses.append(newHouse)

    =# 
