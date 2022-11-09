"""
Population module providing help utilities for realizing a population as an ABM
"""

module Population 

using  MultiAgents: ABM
using  MultiAgents: kill_agent!, allagents

import XAgents: agestep!, agestepAlive!, alive

export population_step!, agestepAlive!, removeDead!


"Step function for the population"
function population_step!(population::ABM{PersonType}) where {PersonType} 
    for agent in population.agentsList
        alive(agent) ? agestep!(agent,population.dt) : nothing 
    end
end 

"remove dead persons" 
function removeDead!(person::PersonType, population::ABM{PersonType}) where {PersonType} 
    alive(person) ? nothing : kill_agent!(person, population) 
    nothing 
end

function removeDead!(population::ABM{PersonType}) where {PersonType} 
    people = reverse(allagents(population))
    for person in people 
        alive(person) ? nothing : kill_agent!(person,population)
    end 
    nothing
end

"increment age with the simulation step size"
agestep!(person::PersonType,population::ABM{PersonType}) where {PersonType} = agestep!(person,population.properties[:dt])

"increment age with the simulation step size"
agestepAlivePerson!(person::PersonType,population::ABM{PersonType}) where {PersonType} = agestepAlive!(person, population.properties[:dt])

end # Population 

#= 

In future we could have something like that: 

mutable struct Population 

    abm::ABM  
    Population(createPopulation::Function) 
    parameters::Dict
    variables::Dict
    data::Dict
    properties::Dict
    ...

end 
=# 

