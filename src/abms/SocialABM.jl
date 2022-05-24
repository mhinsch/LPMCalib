"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    A new abstract ABM type called SocialABM is realized. 
    It specifies further functionalities needed (as a contract)
    for running a social simulation. 
""" 

export SocialABM

"Agent based model specification for social simulations"
mutable struct SocialABM{AgentType <: AbstractAgent} <: AbstractSocialABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties

    SocialABM{AgentType}(properties::Dict{Symbol}) where AgentType <: AbstractAgent = new(AgentType[],copy(properties))

    SocialABM{AgentType}() where AgentType <: AbstractAgent = new(AgentType[],Dict())

    SocialABM{AgentType}(create::Function) where AgentType <: AbstractAgent = new(create(),Dict()) 

    SocialABM{AgentType}(create::Function,properties::Dict{Symbol}) where AgentType <: AbstractAgent = new(create(),copy(properties)) 
end # AgentBasedModel  


