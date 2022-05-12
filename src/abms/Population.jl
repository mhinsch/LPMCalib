"""
Implementation of a population as an ABM model 

This file is included with SocialABMs module.
"""

import SocialAgents: Person

export population_step!


"Step function for the population"
function population_step!(population::SocialABM{Person})
    for agent in population.agentsList
        agestep!(agent;dt=1)
    end
end 


#= 

In future we could have something like that: 

mutable struct Population 

    abm::ABM  

    Population() 

end 
=# 

