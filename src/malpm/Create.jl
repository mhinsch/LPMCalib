module Create

using XAgents: Town, PersonHouse, Person 
using MultiAgents: ABM, attach2DData!

using LPM.Demography.Create: createUKTowns, createUKPopulation

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
