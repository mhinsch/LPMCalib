"""
    Main simulation functions for the demographic aspect of LPM. 
""" 

module Simulate

# using MultiAgents.Util: getproperty

using XAgents: Person, isFemale, alive, age

using MultiAgents: ABM, AbstractMABM, ABMSimulation
using MultiAgents: allagents, add_agent!, currstep, verbose 
using MALPM.Demography.Population: removeDead!
using MALPM.Demography: DemographyExample, LPMUKDemography, LPMUKDemographyOpt, 
                    houses, towns 
using LPM
import LPM.Demography.Simulate: doDeaths!, doBirths!, doDivorces!
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

function doDeaths!(model::AbstractMABM, sim::ABMSimulation, example::DemographyExample) # argument simulation or simulation properties ? 

    population = model.pop 

    (deadpeople) = LPM.Demography.Simulate.doDeaths!(
            alivePeople(population,example),
            currstep(sim),
            population.data,
            population.parameters.poppars)
    
    removeDeads!(deadpeople,population,example)
    nothing 
end # function doDeaths!


function doBirths!(model::AbstractMABM, sim::ABMSimulation, example::DemographyExample) 

    population = model.pop 

    newbabies = LPM.Demography.Simulate.doBirths!(
                        alivePeople(population,example),
                        currstep(sim),
                        population.data,
                        population.parameters.birthpars) 

    # false ? population.variables[:numBirths] += length(newbabies) : nothing # Temporarily this way till realized 
    
    for baby in newbabies
        add_agent!(population,baby)
    end

    nothing 
end


function doDivorces!(model::AbstractMABM, sim::ABMSimulation, example::DemographyExample) 

    population = model.pop 

    divorced = LPM.Demography.Simulate.doDivorces!(
                        allagents(population),
                        currstep(sim),
                        houses(model),
                        towns(model),
                        population.parameters.divorcepars) 

    nothing 
end




end # Simulate 