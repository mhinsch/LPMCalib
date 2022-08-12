module Create


using Utilities: Gender, unknown, female, male
using XAgents: Town, PersonHouse, Person, undefinedHouse, setAsPartners! 
using MultiAgents: ABM, attach2DData!

import SomeUtil: AbstractExample

export Demography, LPMUKDemography, LPMUKDemographyOpt
export createUKDemography

### Example Names 

"Super type for all demographic models"
abstract type Demography <: AbstractExample end 

"This corresponds to direct translation of the python model"
struct LPMUKDemography <: Demography end 

"This is an attemp for improved algorthimic translation"
struct LPMUKDemographyOpt <: Demography end 

### 

function createUKTowns(pars) 

    uktowns = Town[] 
    
    for y in 1:pars.mapGridYDimension
        for x in 1:pars.mapGridXDimension 
            town = Town((x,y),density=pars.ukMap[y,x])
            push!(uktowns,town)
        end
    end

    uktowns
end

function createUKPopulation(pars) 

    population = Person[] 

    for i in 1 : pars.initialPop
        ageMale = rand((pars.minStartAge:pars.maxStartAge))
        ageFemale = ageMale - rand((-2:5))
        ageFemale = ageFemale < 24 ? 24 : ageFemale
        
        rageMale = ageMale + rand(0:11) // 12     
        rageFemale = ageFemale + rand(0:11) // 12 

        # From the old code: 
        #    the following is direct translation but it does not ok 
        #    birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        #    why not 
        #    birthYear = properties[:startYear]  - ageMale/Female 
        #    birthMonth = rand((1:12))

        newMan = Person(undefinedHouse,rageMale,gender=male)
        newWoman = Person(undefinedHouse,rageFemale,gender=female)   
        setAsPartners!(newMan,newWoman) 
        
        push!(population,newMan);  push!(population,newWoman) 

    end # for 

    population

end # createUKPopulation 


"create UK demography"
function createUKDemography(properties) 
    #TODO distribute properties among ambs and MABM  
    # mapProperties = [:townGridDimension,:mapGridXDimension,:mapGridYDimension,:ukMap] - properties
    mapProperties = properties.mappars 
    ukTowns  = ABM{Town}(mapProperties,
                        declare=createUKTowns) # TODO delevir only the requird properties and substract them 
    
    ukHouses = ABM{PersonHouse}() # (declare = dict::Dict{Symbol} -> House[])              
    
    #= 
    populationProperties = [:initialPop,:minStartAge,:maxStartAge,
                            :baseDieProb,:babyDieProb,
                            :maleAgeScaling,:maleAgeDieProb,
                            :femaleAgeScaling,:femaleAgeDieProb,
                            # :num5YearAgeClasses,
                            :maleMortalityBias, :femaleMortalityBias] - properties 
    =# 
    populationProperties = properties.poppars

    # Consider an argument for data 
    ukPopulation = ABM{Person}(populationProperties, declare=createUKPopulation)

    attach2DData!(ukPopulation,:fert,"data/babyrate.txt.csv")
    attach2DData!(ukPopulation,:death_female,"data/deathrate.fem.csv")
    attach2DData!(ukPopulation,:death_male,"data/deathrate.male.csv")

    [ukTowns,ukHouses,ukPopulation]
end 




end # Create
