"""
Module for specifying a type for agent-based models with some examples
"""
module SocialABMs 
    import SocialAgents: AbstractAgent      

    include("./abms/AbstractABM.jl")
    include("./abms/SocialABM.jl")        # could be replaced by Agents.ABM    

    include("./abms/Population.jl") 
    include("./abms/TownCommunity.jl")
end # Social ABMs

#= 

First implementation before learning about Agents.jl was 

 # "Supertype for any group of agents type"
    # abstract type AbstractGroup end

    # common variables and functionalities
    # for instance push!, pop!, ...  
    # ... 

 
    "Group type parameterized by agents & space"
    mutable struct Group{A <: AbstractAgent} <: AbstractGroup 
        # agents::Array{A,1}
        # space ? 
    end  

=# 