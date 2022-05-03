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

# Older implementation to be removed 

#= 
import SocialAgents: Person

export Population

"Population: group of persons"
const Population = Group{Person}

=# 