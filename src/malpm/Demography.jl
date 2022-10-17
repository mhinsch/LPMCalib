module Demography

using XAgents: Town, PersonHouse, Person 
using MultiAgents: AbstractMABM, ABM

export MAModel 

#= 
import MultiAgents.Util: AbstractExample
export DemographyExample, LPMUKDemography, LPMUKDemographyOpt

### Example Names 
"Super type for all demographic models"
abstract type DemographyExample <: AbstractExample end 

"This corresponds to direct translation of the python model"
struct LPMUKDemography <: DemographyExample end 

"This is an attemp for improved algorthimic translation"
struct LPMUKDemographyOpt <: DemographyExample end 
=# 

mutable struct MAModel <: AbstractMABM 
    t      :: Rational{Int}
    towns  :: ABM{Town} 
    houses :: ABM{PersonHouse}
    pop    :: ABM{Person}
    
    function MAModel(t,model,pars)
        ukTowns  = ABM{Town}(model.towns,parameters = pars.mappars) 
        ukHouses = ABM{PersonHouse}(model.houses)
        parameters = (poppars = pars.poppars, birthpars = pars.birthpars, 
                        divorcepars = pars.divorcepars, workpars = pars.workpars)
        data = (fertility = model.fertility, 
                    death_female = model.death_female, 
                    death_male = model.death_male)    
        ukPopulation = ABM{Person}(model.pop,parameters=parameters,data=data)
        new(t,ukTowns,ukHouses,ukPopulation)
    end 
end


    #=
    include("./demography/Simulate.jl")
    include("./demography/SimSetup.jl")   
    =# 


end # Demography