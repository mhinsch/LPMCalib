"""
    This is a struct that resembles the AgentBasedModel concept from the package Agents.jl 

    Initial ideas: 

    1. To integrate this code with SocialGroups.jl. Thus, a Group is an ABM. 
    
    2. a MultiAgentBasedModel concept is to be invented

    3. This can be integrated to Agents.jl 
""" 

# import SocialAgents: AbstractAgent



export AgentBasedModel

mutable struct AgentBasedModel{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Array{AgentType,1} 
end # AgentBasedModel  

AgentBasedModel{AgentType}() where AgentType <: AbstractAgent = AgentBasedModel(AgentType[])

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