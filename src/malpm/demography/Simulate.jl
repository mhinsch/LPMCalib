"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using SomeUtil: getproperty

using XAgents: Person  
using XAgents: alive, age

using MultiAgents: ABM, allagents, add_agent!
using MALPM.Population: removeDead!

using MALPM.Demography.Create: LPMUKDemographyOpt

using LPM
import LPM.Demography.Simulate: doDeaths!
import LPM.Demography.Simulate: doBirths!
export doDeaths!,doBirths!



function doDeaths!(population::ABM{Person}) # argument simulation or simulation properties ? 

    pars = population.parameters.poppars
    data = population.data
    properties = population.properties

    people = allagents(population)

    @assert length(people) > 0 ? 
        typeof(age(people[1])) == Rational{Int64} :
        true  # Assumption

    (deadpeople) = LPM.Demography.Simulate.doDeaths!(
            people=people,parameters=pars,data=data,
            currstep=properties.currstep,
            verbose=properties.verbose,
            sleeptime=properties.sleeptime,
            checkassumption=properties.checkassumption) 

    for deadperson in deadpeople
        removeDead!(deadperson,population)
    end

    false ? population.variables[:numberDeaths] += numberDeaths : nothing # Temporarily this way till realized 

end # function doDeaths!


function doBirths!(population::ABM{Person}) 
    pars = population.parameters.birthpars
    data = population.data
    properties = population.properties

    people = allagents(population)

    # @todo check assumptions 
    newbabies = LPM.Demography.Simulate.doBirths!(
                        people=people,parameters=pars,data=data,
                        currstep=properties.currstep,
                        verbose=properties.verbose,
                        sleeptime=properties.sleeptime,
                        checkassumption=properties.checkassumption) 

    false ? population.variables[:numBirths] += length(newbabies) : nothing # Temporarily this way till realized 
    
    for baby in newbabies
        add_agent!(population,baby)
    end

    nothing 
end

end # Simulate 