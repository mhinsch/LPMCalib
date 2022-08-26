"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using SomeUtil: getproperty

using XAgents: Person  
using XAgents: alive, age

using MultiAgents: ABM, allagents

using MALPM.Demography.Create: LPMUKDemographyOpt

using LPM
import LPM.Demography.Simulate: doDeaths!
export doDeaths!



function doDeaths!(population::ABM{Person}) # argument simulation or simulation properties ? 

    pars = population.parameters
    data = population.data
    properties = population.properties

    people = allagents(population)

    livingPeople = typeof(properties.example) == LPMUKDemographyOpt ? 
        people : [person for person in people if alive(person)]

    @assert length(livingPeople) > 0 ? 
        typeof(age(livingPeople[1])) == Rational{Int64} :
        true  # Assumption

    (numberDeaths) = LPM.Demography.Simulate.doDeaths!(people=livingPeople,parameters=pars,data=data,currstep=properties.currstep,
                                                       verbose=properties.verbose,sleeptime=properties.sleeptime) 

    false ? population.variables[:numberDeaths] += numberDeaths : nothing # Temporarily this way till realized 

end # function doDeaths!

end # Simulate 