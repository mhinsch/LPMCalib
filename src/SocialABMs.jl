"Data types for a group of agents"
module SocialABMs 
    # export AbstractGroup, Group
    import SocialAgents: AbstractAgent      

    include("ABM.jl")        # could be replaced by Agents.ABM    

    include("Population.jl") 
    include("TownCommunity.jl")
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