module Agent
    
    abstract type AbstractAgent end 
    
    # Abstract types in Julia come without data fields (i.e. they rather define common behavior)
    # It could be possible to have struct of common data entry in any agent, e.g. 
    #=

    mutable struct AbstractAgentData{A <: AbstractAgent}
        Int64::id  
        A 
    end

    mutable struct HouseData <: AbstractAgent
        location 
        size
        ... 
    end

    mutable struct PersonData <: AbstractAgent 
        father 
        mother 
    end

    const House  = AbstractAgentData{HouseData} 
    const Person = AbstractAgentData{PersonData} 
    =# 

    include("House.jl")

    include("Person.jl")

    # common attributes (fields & functionalities) for agents
    # ...  
end