"""
    create UK towns and houses. 

    This source file is included in the model LPMABMs.jl 
"""

# adjustedDensity = density * densityModifier

# future candidate 
# createUKTowns(variables,parameters,properties)

using Random: shuffle 

import Global: Gender, unknown, female, male
import SocialAgents: Town, House, Person, undefinedHouse, isFemale 
import SocialABMs: SocialABM, add_agent!, allagents, nagents

export createUKDemography # createUKTowns, createUKHouses 

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

        ageFemale = ageFemale < 24 ? 24 : ageFemale 

        # From the old code: 
        #    the following is direct translation but it does not ok 
        #    birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        #    why not 
        #    birthYear = properties[:startYear]  - ageMale/Female 
        #    birthMonth = rand((1:12))

        newMan = Person(undefinedHouse,ageMale,gender=male)
        newWoman = Person(undefinedHouse,ageFemale,gender=female)   

        newMan.partner = newWoman; newWoman.partner = newMan.partner
        
        push!(population,newMan);  push!(population,newWoman) 

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



# TODO if needed, Connection could be made as a struct 

"initialize an abm of houses through an abm of towns"
function initial_connect!(abmhouses::SocialABM{House},abmtowns::SocialABM{Town},properties) 

    # create houses within towns 
    towns = allagents(abmtowns)  
    for town in towns
        if town.density > 0 
            adjustedDensity = town.density * properties[:mapDensityModifier]
    
            for hx in 1:abmtowns.properties[:townGridDimension]  
                for hy in 1:abmtowns.properties[:townGridDimension] 
    
                    if(rand() < adjustedDensity)
                        house = House(town,(hx,hy))
                        add_agent!(house,abmhouses)
                    end
    
                end # for hy 
            end # for hx 
        end # if town.density 
    end # for town 

    nothing 
end

# Connection is symmetric 
initial_connect!(abmtowns::SocialABM{Town},abmhouses::SocialABM{House},properties) = initial_connect!(abmhouses,abmtowns,properties)


""" 
    initialize an abm of houses through an abm of towns
    a set of houses are chosen randomly and assigned to couples 
"""
function initial_connect!(abmpopulation::SocialABM{Person},abmhouses::SocialABM{House},properties) 
    
    numberOfMens        = trunc(Int,nagents(abmpopulation) / 2)       # it is assumed that half of the population is men
    randomHousesIndices = shuffle(1:nagents(abmhouses))    
    randomhouses        = allagents(abmhouses)[randomHousesIndices[1:numberOfMens]] 
    population          = allagents(abmpopulation) 

    for man in population
        isFemale(man) ? continue : nothing 

        house  = pop!(randomhouses) 
        man.pos = man.partner.pos = house 

        # append!(house.occupants, [man, man.partner])

    end # for person     
    
    length(randomhouses) > 0 ? error("random houses for occupation has length $(length(randomhouses)) > 0") : nothing 
end 

# TODO may be some generic function somewhere 
# connection is symmetric 
initial_connect!(abmhouses::SocialABM{House},abmpopulation::SocialABM{Person},properties) = initial_connect!(abmpopulation,abmhouses,properties) 



function createUKDemography(properties) 

    #TODO distribute properties among ambs and MABM  

    ukTowns  = SocialABM{Town}(createUKTowns,properties) # TODO delevir only the requird properties and substract them 
    ukHouses = SocialABM{House}()              
    ukPopulation = SocialABM{Person}(createUKPopulation,properties)

    initial_connect!(ukHouses,ukTowns,properties)
    initial_connect!(ukPopulation,ukHouses,properties)

    (ukTowns,ukHouses,ukPopulation)
end 



