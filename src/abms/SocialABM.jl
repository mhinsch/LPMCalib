"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    A new abstract ABM type called SocialABM is realized. 
    It specifies further functionalities needed (as a contract)
    for running a social simulation. 
""" 

export SocialABM

export addProperty! 

"Social ABM to be enhanced with relevant functionlities"
abstract type AbstractSocialABM <: AbstractABM end 

#=
It is thinkable to associate further attributes to SocialABMs s.a.

variable(sabm::AbstractSocialABM,var::Symbol,initalVal) = sabm.variable[var]
parameter(sabm::AbstractSocialABM,par::Parameter,val) = sabm.parameter[par]
data(sabm::AbstractSocialABM,symbol::Symbol;csvfname)  = sabm.data[symbol]
addVariable(...
deleteVariable(...

=# 

"Agent based model specification for social simulations"
mutable struct SocialABM{AgentType <: AbstractAgent} <: AbstractSocialABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties
    # AgentBasedModel{AgentType}() where AgentType <: AbstractAgent = new(AgentType[])

    SocialABM{AgentType}(properties::Dict{Symbol}) where AgentType <: AbstractAgent = new(AgentType[],copy(properties))

    SocialABM{AgentType}() where AgentType <: AbstractAgent = new(AgentType[],Dict())
end # AgentBasedModel  

"add a symbol property to a model"
function addProperty!(model::AbstractSocialABM,property::Symbol,val)
    if property in keys(model.properties)
        error("$(property) is already available")
    end 
    model.properties[property] = val  
end 


#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 