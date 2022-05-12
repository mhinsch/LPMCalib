"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    A new abstract ABM type called SocialABM is realized. 
    It specifies further functionalities needed (as a contract)
    for running a social simulation. 
""" 

# import SocialAgents: AbstractAgent



export SocialABM

export startTime, finishTime, dt

"Social ABM to be enhanced with relevant functionlities"
abstract type AbstractSocialABM <: AbstractABM end 

"get the start time of the simulation"
startTime(model::AbstractSocialABM) = model.properties[:startTime] 

"get the finish time of the simulation"
finishTime(model::AbstractSocialABM) = model.properties[:finishTime] 

"get the increment simulation step" 
dt(model::AbstractSocialABM) = model.properties[:dt] 

"Agent based model specification for social simulations"
mutable struct SocialABM{AgentType <: AbstractAgent} <: AbstractSocialABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties::Dict{Symbol}
    # AgentBasedModel{AgentType}() where AgentType <: AbstractAgent = new(AgentType[])

    SocialABM{AgentType}(properties::Dict{Symbol}) where AgentType <: AbstractAgent = new(AgentType[],copy(properties))
end # AgentBasedModel  

# AgentBasedModel{AgentType}() where AgentType <: AbstractAgent = AgentBasedModel(AgentType[]))

# function AgentBasedModel{AgentType}(properties::Dict{Symbol}) where AgentType <: AbstractAgent 
#    AgentBasedModel(AgentType[],copy(properties))
# end 




#const ABM = AgentBasedModel{AgentType} 
      # where AgentType <: AbstractAgent 

#=
This is how Agents.jl ABM looks like 

mutable struct ABM
    AgentType::DataType  # where agentType <: AbstractAgent
    
    # spaceType  (default is nothing): The space on which the agents are operating 
    # properties dictionary of symbols to values or struct 
    
    agentsList::Array{AbstractAgent,1} #     a list of agents of type A

    # cors:
    # ABM(agentType,spaceType,properties;kwargs...)
    # ABM(agentType,properties;kwargs...)

    function ABM(atype::DataType) 
        atype <: AbstractAgent ? new(atype,[]) : error("$atype is not an agent type")
    end 
end # ABM 

=#





#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 