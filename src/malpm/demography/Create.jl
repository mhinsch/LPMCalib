module Create

using XAgents: Town, PersonHouse, Person 
using MultiAgents: ABM

using LPM.ParamTypes.Loaders: loadUKDemographyData
using LPM.Demography.Create: createUKTowns, createUKPopulation

import SomeUtil: AbstractExample

export DemographyExample, LPMUKDemography, LPMUKDemographyOpt
export createUKDemographDash, createUKTownsDash
export createUKDemography

### Example Names 

"Super type for all demographic models"
abstract type DemographyExample <: AbstractExample end 

"This corresponds to direct translation of the python model"
struct LPMUKDemography <: DemographyExample end 

"This is an attemp for improved algorthimic translation"
struct LPMUKDemographyOpt <: DemographyExample end 

createUKPopulationDash(pars) = createUKPopulation(pars.poppars)

"create UK demography"
function createUKDemography(pars) 
     
    ukTowns  = ABM{Town}(pars.mappars,
                        declare=createUKTowns) # TODO delevir only the requird properties and substract them 
    
    ukHouses = ABM{PersonHouse}()              

    ukDemographyData = loadUKDemographyData()
    # Consider an argument for data 
    ukPopulation = ABM{Person}(pars, ukDemographyData, declare=createUKPopulationDash)

    [ukTowns,ukHouses,ukPopulation]
end 


end # Create
