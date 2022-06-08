"""
Specification of an abstract agent supertype 

The idea is to add an additional layer of absraction that distinguishes 
declared agents from the library Agents.jl to the sophisticated agents 
we want to employ for sophisticated socio-econmic ABMs. This is to allow 
extension of Agents.jl (without modifying it) 

AbstractAgent could be replaced by using Agents.jl in case Agents.jl will turn 
to be directly usable
"""

export AbstractAgent, AbstractSocialAgent 
export verify  

"The ID assigned to an agent for every new agent"
global IDCOUNTER = 0::Int64              # This is differnt than agents.jl 
                                                 
"Supertype of any Agent type"
abstract type AbstractAgent end          # to be replaceable by > using Agents.jl 
  
"Specific abstract type for the type of agent exampels to be modelled using this package" 
abstract type AbstractSocialAgent <: AbstractAgent end

function verify(a::AbstractSocialAgent) 
    :id in fieldnames(typeof(a)) && :pos in fieldnames(typeof(a))  # Agents.jl requirement 
end 

#=

Possible extensions could realize the following 

# A contract for any agent subtype: 
function addVariable!(agent::AbstractSocialAgent,var::Symbol,initValue)  end 
function addParameter!(agent::AbstractSocialAgent,par::Symbol,val)  end 
function addConstant!(agent::AbstractSocialAgent,cst::Symbol,val)  end 
function deleteVariable!(agent::AbstractSocialAgent,var::Symbol)  end 

=#


