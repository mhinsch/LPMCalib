export Household 

"""
Household concept. 
It is still not determined if a household is an agent or an ABM 
within a multi-ABM. 
"""
mutable struct Household <: AbstractAgent
    id::Array{Int,1}   # list of person ids 
    pos                # list of their positions 
    # income 
    # ... 
end 

# Constructor Household(personList) 
