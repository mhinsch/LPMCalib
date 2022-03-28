module Agent

    export AbstractAgent, Agent, DataSpec, idcounter
    
    abstract type AbstractAgent end              # Supertype of any agent type 
    
    # Abstract types in Julia come without data fields (i.e. they rather define common behavior)
    # It could be possible to have struct of common data entry in any agent, e.g. 

    abstract type DataSpec end                   # Fields of a specific agent type

    # init!(data::DataSpec,arg...) = error("always implement init! for DataSpec type")
    # init!(data::DataSpec,dict::Dict{String,any})

    #idcounter::Int = 0                           # Number of created agents 

    # Agent struct is not mutable, i.e. id is initialized 
    # once an agent is created by a constructor and shall 
    # not be changed 
    struct Agent{Data <: DataSpec} <: AbstractAgent
        id::Int     # unique agent id   
        data::Data 
        #= Cor
            Agent(arg...)
                id = idcounter += 1
                init!(data,arg...)
            end 
        =#
    end

    #= 
    Common functions can be defined here, e.g.
    function foo() = "foo"                           # meaningless dummy implementation  
    function goo() end                               # empty function 
    function hoo = error("hoo shall not be called")  # should not be called for subtype's instances 
    function zoo()                                   # common function for subtype's instances 
        # do something
    end 
    =# 

    #=
    Base.show(io,Agent) = ... 
    =# 


    include("House.jl")

    include("Person.jl")

    # common attributes (fields & functionalities) for agents
    # ...  
end