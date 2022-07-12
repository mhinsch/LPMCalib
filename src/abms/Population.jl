"""
Implementation of a population as an ABM model 

This file is included with MultiABMs module. This file is subject to removal or modification
"""

using  MultiAgents: ABM
using  MultiAgents: kill_agent!

import XAgents: agestep!, agestepAlive!, alive

export population_step!, agestepAlive!, removeDead!


"Step function for the population"
function population_step!(population::ABM{PersonType};dt=1//12) where {PersonType} 
    for agent in population.agentsList
        agestep!(agent,dt=dt)
    end
end 

"remove dead persons" 
function removeDead!(person::PersonType, population::ABM{PersonType}) where {PersonType} 
    alive(person) ? nothing : kill_agent!(person, population) 
    nothing 
end

"increment age with the simulation step size"
agestep!(person::PersonType,population::ABM{PersonType}) where {PersonType} = agestep!(person,dt=population.properties[:dt])

"increment age with the simulation step size"
agestepAlivePerson!(person::PersonType,population::ABM{PersonType}) where {PersonType} = agestepAlive!(person, population.properties[:dt])

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

