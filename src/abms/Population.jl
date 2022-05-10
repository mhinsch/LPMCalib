#=

This source code implements the population concept and is included within 
SocialABMs module 

=# 

# export population or Population 

# ABM(Person,KinshipGraph,Properties)
# const Population = ABM()
# This could be beneficial for implementing the MultiABM concept not existing in Agents.jl 
# Could be imagined as a global variable descriping the population 

# or 

#= 
mutable struct Population 

    abm::ABM  

    Population() 

end 
=# 

# using SocialAgents
import SocialAgents: Person

export initDummyPopulation, population_step!


"Step function for the population"
function population_step!(population::AgentBasedModel{Person})
    for agent in population.agentsList
        agent_step!(agent)
    end
end 

"Establish a dummy population"
function initDummyPopulation(houses::Array{House,1})
    
    population = AgentBasedModel{Person}()

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


# Older implementation to be removed 

#= 
import SocialAgents: Person

export Population

"Population: group of persons"
const Population = Group{Person}

=# 