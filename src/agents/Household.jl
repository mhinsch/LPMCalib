export Household 

"""
Household concept. 
It is still not determined if a household is an agent or an ABM 
within a multi-ABM. 
"""
mutable struct Household <: AbstractAgent
    id                 # list of person ids 
    pos                # House   
    income 
    # ... 
end 

# Constructor Household(personList) 
