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
Further functionalities for realistic sophisticated agents:

addVariable(agent,symbol::Symbol,initVal)

addParameter(agent,symbol::Symbol,val) 

addConstant(agent,symbol::Symbol,val) 
=#


