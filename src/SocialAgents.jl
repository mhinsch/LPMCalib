"""
Module for defining a supertype, AbstractAgent for all Agent types 
    with additional ready-to-use agents to be used in Social (Multi-)ABMs models 
"""
module SocialAgents

    include("./agents/AbstractAgent.jl")    
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