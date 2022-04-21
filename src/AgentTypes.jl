"Definitions of supertypes for all Agent types."
module AgentTypes

    export AbstractAgent, DataSpec, Agent, getID, getLocation

    "Number of instantiated agents"
    IDCOUNTER = 0::Int64                           
    
    "Supertype of any Agent type"
    abstract type AbstractAgent end              
    
    "Any agent should have an ID number"
    getindex(A::AbstractAgent)::Int64 = A.id 

    "Any agent should be assigned to a location"
    getposition(A::AbstractAgent)  = A.pos
     
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
    mutable struct Agent{Data <: DataSpec} <: AbstractAgent
        id::Int64     # unique agent id  
        pos           # position 
        spec::Data 
        #= Constructor
            Agent(arg...)
                id = idcounter += 1
                init!(data,arg...)
            end 
        =#

        function Agent{Data}(position) where Data <: DataSpec
            global IDCOUNTER += 1
            agent = new(IDCOUNTER,position) 
        end 

        # function Agent{Data}(position,data::Data,check_consistancy=false)
    end

    "Stepping function for agents"
    function step_agent!(agent::AbstractAgent) 
        agenttype = typeof(agent)
        error("step_agent! needs to be implemented for $agenttype")
    end 

    # "assign an agent with its specification"
    # init!(A::Agent{DataSpec},spec::DataSpec)


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