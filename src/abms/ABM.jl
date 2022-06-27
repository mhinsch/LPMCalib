"""
    An Agent Based Model concept based on AbstractAgent type 
    similar to Agents.jl. 
    It specifies further functionalities needed (as a contract)
    for running an ABM simulation. (An imitation of Agents.jl) 
""" 

using Utilities: read2DArray
export ABM, initial_connect!, attach2DData!


# dummydeclare(dict::Dict{Symbol}=Dict{Symbol}()) = nothing 

"Agent based model specification for social simulations"
mutable struct ABM{AgentType <: AbstractAgent} <: AbstractABM
    agentsList::Array{AgentType,1}
    """
    Dictionary mapping symbols (e.g. :x) to values 
    it can be made possible to access a symbol like that model.x
    in the same way as Agents.jl 
    """ 
    properties
    data::Dict{Symbol}       # data structure to be improved 

    ABM{AgentType}(properties::Dict{Symbol} = Dict{Symbol,Any}(); 
        declare::Function = dict::Dict{Symbol} -> AgentType[]) where AgentType <: AbstractAgent = 
             new(declare(properties),copy(properties),Dict{Symbol,Any}())
             
    # ^^^ to add an argument for data with default value empty 

end # AgentBasedModel  

""
function attach2DData!(abm::ABM{AgentType}, symbol::Symbol, fname ) where AgentType 
    abm.data[symbol] = read2DArray(fname) 
end

 
"ensure symmetry"
initial_connect!(abm2::ABM{T2},
                 abm1::ABM{T1},
                 properties::Dict{Symbol}) where {T1 <: AbstractABM,T2 <: AbstractABM} = initial_connect!(abm1,abm2,properties)
