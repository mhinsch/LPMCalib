module Agent
    
    abstract type AbstractAgent end 
    
    # Abstract types in Julia come without data fields (i.e. they rather define common behavior)
    # It could be possible to have struct of common data entry in any agent, e.g. 
    #=

    abstract type DataSpec end 

    mutable struct Agent{A <: DataSpec} <: AbstractAgent
        Int64::id  
        A 
    end

    mutable struct HouseData <: DataSpec
        location 
        size
        ... 
    end

    mutable struct PersonData <: DataSpec
        father 
        mother 
    end

    const House  = Agent{HouseData} 
    const Person = Agent{PersonData} 
    =# 

    #= 
    Common functions can be defined here, e.g.
    function foo() = "foo"                           # meaningless dummy implementation  
    function goo() end                               # empty function 
    function hoo = error("hoo shall not be called")  # should not be called for subtype's instances 
    function zoo()                                   # common function for subtype's instances 
        # do something
    end 
    =# 

    include("House.jl")

    include("Person.jl")

    # common attributes (fields & functionalities) for agents
    # ...  
end