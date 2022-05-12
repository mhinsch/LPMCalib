"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    A new abstract ABM type called SocialABM is realized. 
    It specifies further functionalities needed (as a contract)
    for running a social simulation. 
""" 

# import SocialAgents: AbstractAgent



export SocialABM, AgentBasedModel

export startTime, finishTime, dt

"Social ABM to be enhanced with relevant functionlities"
abstract type SocialABM <: AbstractABM end 

"get the start time of the simulation"
startTime(model::SocialABM) = error("Not implemented") 

"get the finish time of the simulation"
finishTime(model::SocialABM) = error("Not implemented") 

"get the increment simulation step" 
dt(model::SocialABM) = error("Not implemented")  

mutable struct AgentBasedModel{AgentType <: AbstractAgent} <: SocialABM
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