"""
Implementation of a population as an ABM model 

This file is included with SocialABMs module.
"""

import SocialAgents: Person

export initDummyPopulation, population_step!


"Step function for the population"
function population_step!(population::AgentBasedModel{Person})
    for agent in population.agentsList
        agestep!(agent;dt=1)
    end
end 

"Establish a dummy population"
function initDummyPopulation(houses::Array{House,1})
    
    population = SocialABM{Person}(Dict(:startTime=>1990,
                                              :finishTime=>2030,
                                              :dt=>1))

    for house in houses
        mother   = Person(house,rand(25:55))
        father   = Person(house,rand(30:55))
        son      = Person(house,rand(1:15))
        daughter = Person(house,rand(1:15))
        add_agent!(mother,population)
        add_agent!(father,population)
        add_agent!(son,population)
        add_agent!(daughter,population)
    end 

    population 
end 

#= 

In future we could have something like that: 

mutable struct Population 

    abm::ABM  

    Population() 

end 
=# 

