"""
Specification of an abstract agent supertype 
"""

export AbstractAgent
export agent_step!, getindex, getposition 
export getProperty, setProperty!

"Number of instantiated agents"
global IDCOUNTER = 0::Int64                           
    
"Supertype of any Agent type"
abstract type AbstractAgent end     
    
"Any agent should have an ID number"
getindex(A::AbstractAgent) = A.id 

"Any agent should be assigned to a location"
getposition(A::AbstractAgent)  = A.pos
    
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

#=

Possible extensions could realize the following 

abstract type AbstractSocialAgent <: AbstractAgent

# A contract for any agent subtype: 
function addVariable(agent::AbstractSocialAgent,var::Symbol)  end 
function addParameter(agent::AbstractSocialAgent,var::Symbol)  end 
function addConstant(agent::AbstractSocialAgent,var::Symbol)  end 
function deleteVariable(agent::AbstractSocialAgent,var::Symbol)  end 

=#


