"""
Implementation of a population as an ABM model 

This file is included with SocialABMs module. This file is subject to removal or modification
"""

import SocialAgents: Person

export population_step!


"Step function for the population"
function population_step!(population::SocialABM{Person};dt=1//12)
    for agent in population.agentsList
        agestep!(agent,dt=dt)
    end
end 


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

