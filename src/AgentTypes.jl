@doc "Definitions of supertypes for all Agent types."
module AgentTypes

    export AbstractAgent, DataSpec, Agent #, idcounter

    "Number of instantiated agents"
    IDCOUNTER = 0::Int                           
    
    "Supertype of any Agent type"
    abstract type AbstractAgent end              
    
    #
    # id(A::AgentTypes) = A.id 
    # 
    
    """
        DataSpec: Data fields of an Agent type.

    Abstract types in Julia come without data fields (i.e. they rather define common 
    behavior). This is the supertype of and data fields specification in any agent. 
    """ 
    abstract type DataSpec end                  

    # init!(data::DataSpec,arg...) = error("always implement init! for DataSpec type")
    # init!(data::DataSpec,dict::Dict{String,any})

    """
       Agent{D::DataSpec}

    Immutable Agent type, i.e. id is initialized once an agent is created by a constructor 
    and shall not be changed. Data fields can be changed only if they are mutable 
    """ 
    struct Agent{Data <: DataSpec} <: AbstractAgent
        # id::Int     # unique agent id   
        # data::Data 
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

    # common attributes (fields & functionalities) for agents
    # ...  

    #=
    Base.show(io,Agent) = ... 
    =# 

    include("House.jl")
    include("Person.jl")
end