module Agent
    
    abstract type AbstractAgent end 
    
    # Abstract types in Julia come without data fields (i.e. they rather define common behavior)
    # It could be possible to have struct of common data entry in any agent, e.g. 

    abstract type DataSpec end 

    # init!(data::DataSpec,arg...)
    # init!(data::DataSpec,dict::Dict{String,any})

    global idcounter::Int = 0   

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