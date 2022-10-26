"""
    Main simulation functions for the demographic aspect of LPM. 
""" 

module Simulate

# using MultiAgents.Util: getproperty

using XAgents: Person, isFemale, alive, age

using MultiAgents: ABM, AbstractMABM, ABMSimulation
using MultiAgents: allagents, add_agent!, currstep, verbose 
using MALPM.Population: removeDead!
using MALPM.Demography: DemographyExample, LPMUKDemography, LPMUKDemographyOpt

using LPM
import LPM.Demography.Simulate: doDeaths!, doBirths!
# export doDeaths!,doBirths!

alivePeople(population::ABM{Person},::LPMUKDemography) = allagents(population)

alivePeople(population::ABM{Person},::LPMUKDemographyOpt) = 
               # Iterators.filter(person->alive(person),allagents(population))
                [ person for person in allagents(population)  if alive(person) ]

function removeDeads!(deadpeople,population,::LPMUKDemography)    
    for deadperson in deadpeople
        removeDead!(deadperson,population)
    end
    
    nothing 
end

removeDeads!(deadpeople,population,::LPMUKDemographyOpt) = nothing 

function doDeaths!(model::AbstractMABM,sim::ABMSimulation,example::DemographyExample) # argument simulation or simulation properties ? 

    population = model.pop 

    (deadpeople) = LPM.Demography.Simulate.doDeaths!(
            alivePeople(population,example),
            currstep(sim),
            population.data,
            population.parameters.poppars)
    
    removeDeads!(deadpeople,population,example)
    nothing 
end # function doDeaths!


function doBirths!(population::ABM{Person},sim::ABMSimulation,example::DemographyExample) 

    newbabies = LPM.Demography.Simulate.doBirths!(
                        people = alivePeople(population,population.properties.example),
                        parameters =  population.parameters.birthpars,
                        data = population.data,
                        currstep = population.properties.currstep) 

    # false ? population.variables[:numBirths] += length(newbabies) : nothing # Temporarily this way till realized 
    
    for baby in newbabies
        add_agent!(population,baby)
    end

    nothing 
end


end # Simulate 