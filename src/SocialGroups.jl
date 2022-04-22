"Data types for a group of agents"
module SocialGroups 

    export AbstractGroup, Group

    import SocialAgents: AbstractAgent      
    # or 
    # import Agents: AbstractAgent  

    "Supertype for any group of agents type"
    abstract type AbstractGroup end

    # common variables and functionalities
    # for instance push!, pop!, ...  
    # ... 

 
    "Group type parameterized by agents & space"
    mutable struct Group{A <: AbstractAgent} <: AbstractGroup 
        # agents::Array{A,1}
        # space ? 
    end  

    include("Population.jl") 
    include("Household.jl") 
end # module GroupTypes 

