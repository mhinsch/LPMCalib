"""
Population module providing help utilities for realizing a population as an ABM
"""

module Population 

using  MultiAgents: ABM, ABMSimulation, AbstractMABM  
using  MultiAgents: allagents, dt, kill_agent!

import XAgents: agestep!, agestepAlive!, alive 

export population_step!, agestepAlive!, removeDead!


function population_step!(model::AbstractMABM,
                            sim::ABMSimulation, 
                            example) where {PersonType} 
    population_step!(model.pop,sim,example)
end 

"Step function for the population"
function population_step!(population::ABM{PersonType},
                            sim::ABMSimulation, 
                            example) where {PersonType} 
    for person in allagents(population)
        if alive(person) 
            agestep!(person,dt(sim)) 
        end  
    end
end 

"remove dead persons" 
function removeDead!(person::PersonType, population::ABM{PersonType}) where {PersonType} 
    if !alive(person) 
        kill_agent!(person, population) 
    end 
    nothing 
end

function removeDead!(population::ABM{PersonType},
                        simulation::ABMSimulation,example) where {PersonType} 
    people = reverse(allagents(population))
    for person in people 
        alive(person) ? nothing : kill_agent!(person,population)
    end 
    nothing
end

"increment age with the simulation step size"
agestep!(person::PersonType,population::ABM{PersonType},
            sim::ABMSimulation,example) where {PersonType} = agestep!(person,dt(sim))

"increment age with the simulation step size"
agestepAlivePerson!(person::PersonType,population::ABM{PersonType},
                        sim::ABMSimulation,example) where {PersonType} = 
                            agestepAlive!(person, dt(sim))

end # Population 



