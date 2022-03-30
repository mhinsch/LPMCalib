"Data types for a group of agents"
module GroupTypes 

    export AbstractGroop, Group

    import AgentTypes: AbstractAgent 

    "Supertype for any group of agents type"
    abstract type AbstractGroup end

    "Group type parameterized by agents, @todo GroupSpec"
    struct Group{A <: AbstractAgent} <: AbstractGroup 
        # agents::Array{A,1}
    end 

    # common variables and functionalities
    # for instance push!, pop!, ...  
    # ... 

    include("Population.jl") 

    #include("Household.jl") 
end # module GroupTypes 