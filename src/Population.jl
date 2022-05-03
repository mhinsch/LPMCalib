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

using SocialAgents

export createPopulation, population_step!


"Step function for the population"
function population_step!(population::ABM)
    nothing 
end 

"Establish a population"
function createPopulation()
    population = ABM(Person) # Person Type, Town or grid, population_step! ... 
    
    # load people data and add them to population 

    joe = Person(position="Glasgow",age=30)
    katharina = Person(position="Edinbrugh",age=25)

    add_agent!(joe,population)
    add_agent!(katharina,population)

    population 
end 


# Older implementation to be removed 

#= 
import SocialAgents: Person

export Population

"Population: group of persons"
const Population = Group{Person}

=# 