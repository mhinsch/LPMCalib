module Create

using XAgents: Town, PersonHouse, Person 
using MultiAgents: ABM, attach2DData!

using LPM.Demography.Create: createUKTowns, createUKPopulation

import SomeUtil: AbstractExample

export DemographyExample, LPMUKDemography, LPMUKDemographyOpt
export createUKDemography

### Example Names 

"Super type for all demographic models"
abstract type DemographyExample <: AbstractExample end 

"This corresponds to direct translation of the python model"
struct LPMUKDemography <: DemographyExample end 

"This is an attemp for improved algorthimic translation"
struct LPMUKDemographyOpt <: DemographyExample end 

"create UK demography"
function createUKDemography(pars) 
     
    ukTowns  = ABM{Town}(pars.mappars,
                        declare=createUKTowns) # TODO delevir only the requird properties and substract them 
    
    ukHouses = ABM{PersonHouse}() # (declare = dict::Dict{Symbol} -> House[])              

    # Consider an argument for data 
    ukPopulation = ABM{Person}(pars, declare=createUKPopulation)

    attach2DData!(ukPopulation,:fert,"data/babyrate.txt.csv")
    attach2DData!(ukPopulation,:death_female,"data/deathrate.fem.csv")
    attach2DData!(ukPopulation,:death_male,"data/deathrate.male.csv")

    [ukTowns,ukHouses,ukPopulation]
end 


end # Create
