#=
Intuition: A Town community is composed of a variable 
           population and a variable set of houses. 
           Thus, it can be viewed as an ABM. 
 
=# 


import SocialAgents: House

export initDummyTown

function initDummyTown(name::String,
                       personList::Array{Person,1})

    # towns = AgentBasedModel{Person}
    
    # Agents.jl API:
    # town = ABM(House) # House, map or grid, ... 

    

    # town 
end 
#= 

Older implementation to be removed 

#
# Type Town extends the type Group 
# a collection of houses 
# 

export Town 

const Town = Group{House}

=# 