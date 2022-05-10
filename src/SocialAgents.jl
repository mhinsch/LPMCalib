"Definitions of supertypes for all Agent types."
module SocialAgents

    export AbstractAgent
    export agent_step!, getindex, getposition 
    export getProperty, setProperty!

    "Number of instantiated agents"
    global IDCOUNTER = 0::Int64                           
    
    "Supertype of any Agent type"
    abstract type AbstractAgent end     
    
    # "A list of all agents"
    # allAgentsList::Array{AbstractAgent,1} = AbstractAgent[] 
    # does not work ..
    # TODO struct for mapping agents ids to agents 
    # ...
    
    "Any agent should have an ID number"
    getindex(A::AbstractAgent) = A.id 

    "Any agent should be assigned to a location"
    getposition(A::AbstractAgent)  = A.pos
    
    "Stepping function for agents"
    function agent_step!(agent::AbstractAgent) 
        agenttype = typeof(agent)
        @warn "agent_step! is not defined for type $agenttype"
        nothing 
    end 

    "Set an agent field using this function"
    function setProperty!(agent::AbstractAgent,
                         property::Symbol,
                         val) 
        setfield!(agent,property,val)
    end

    function getProperty(agent::AbstractAgent, 
                         property::Symbol)
        getfield(agent,property)
    end

    #=
    Base.show(io,agent::AbstractAgent) = ... 
    =# 

    include("./agents/Town.jl")
    include("./agents/House.jl")
    include("./agents/Person.jl")
    include("./agents/Household.jl")
    
end  # SocialAgents 


    #=
    An alternative approach  
    """
        DataSpec: Data fields of an Agent type.

    Abstract types in Julia come without data fields (i.e. they rather define common 
    behavior). This is the supertype of and data fields specification in any agent. 
    """
    # abstract type DataSpec end   
    
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

    assign an agent with its specification"
    init!(A::Agent{DataSpec},spec::DataSpec)

    =#  