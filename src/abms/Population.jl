"""
Implementation of a population as an ABM model 

This file is included with SocialABMs module. This file is subject to removal or modification
"""

using  SocialAgents: Person
import SocialAgents: agestep!, agestepAlivePerson! 

export population_step!, agemonthstep!, agestepAlivePerson


"Step function for the population"
function population_step!(population::SocialABM{Person};dt=1//12)
    for agent in population.agentsList
        agestep!(agent,dt=dt)
    end
end 

"increment age with the simulation step size"
agestep!(person::Person,population::SocialABM{Person}) = agestep!(person,dt=population.properties[:dt])

"increment age with the simulation step size"
agestepAlivePerson!(person::Person,population::SocialABM{Person}) = agestepAlivePerson!(person,dt=population.properties[:dt])

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

