"""
Specification of an abstract ABM type as a supertype for all 
    (elementary) Agent based models. It resembles the ABM concept
    from Agents.jl
"""

using XAgents

using Utilities: age2yearsmonths, removefirst!

"Abstract ABM resembles the ABM concept from Agents.jl"
abstract type AbstractABM end 

export allagents, nagents
export add_agent!, move_agent!, kill_agent!
export step!, dummystep, errorstep, defaultprestep!, defaultpoststep! 


#========================================
Fields of an ABM
=########################################

"An AbstractABM subtype to have a list of agents"
function allagents(model::AbstractABM)#::Array{AgentType,1} where AgentType <: AbstractAgent
    model.agentsList
end 

"add a symbol property to a model"
function getproperty(model::AbstractABM,property::Symbol)
    if property in keys(model.properties)
        return model.properties[property]
    end 
    error("$(property) is not available as a key")
end 


#========================================
Functionalities for agents within an ABM
=########################################

"return the id-th agent (Agents.jl)"
getindex(model::AbstractABM,id) = error("not implemented")
    

# equivalent to operator [], i.e. model[id] 

"random seed of the model (Agents.jl)"
seed!(model::AbstractABM,seed) = error("not implemented") 

"numbe of  agents"
nagents(model::AbstractABM) = length(model.agentsList)
 

#= 
Couple of other useful functions may include:

randomagent(model) : a random agent 

randomagent(model,condition) : allagents 

function allids(model)    : iterator over ids

=# 

#========================================
Functionalities for agents within an ABM
=########################################

"add agent with its position to the model"
function add_agent!(agent::AbstractAgent,model::AbstractABM) # where T <: AbstractAgent
    push!(model.agentsList,agent)
end 

#=
"add agent to the model"
function add_agent!(agent,pos,model::AgentBasedModel) 
    nothing 
end
=# 

"to a given position (Agents.jl)" 
move_agent!(agent,pos,model::AbstractABM) =  error("not implemented")


"remove an agent"
kill_agent!(agent,model::AbstractABM) = removefirst!(model.agentsList,agent) 

#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 

#===========================
General stepping functions / imitating Agents.jl 
=###########################

"dummy stepping function for arbitrary agents"
dummystep(::AbstractAgent,::AbstractABM) = nothing 
 
"default dummy model stepping function"
dummystep(::AbstractABM) = nothing 

"Default agent stepping function for reminding the client that it should be provided"
errorstep(::AbstractAgent,::AbstractABM) = error("agent stepping function has not been specified")

"Default model stepping function for reminding the client that it should be provided"
errorstep(::AbstractABM) = error("model stepping function has not been specified")

"Default instructions before stepping an abm"
function defaultprestep!(abm::AbstractABM) 
    abm.properties[:stepnumber] = abm.properties[:stepnumber] + 1 
    nothing 
end

"Default instructions after stepping an abm"
function defaultpoststep!(abm::AbstractABM) 
    abm.properties[:currstep] =  abm.properties[:currstep] + abm.properties[:dt] 
    nothing 
end


"""
Stepping function for a model of type AgentBasedModel with 
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
    agents_first : agent_step! executed first before model_step
"""
function step!(
    model::AbstractABM,
    agent_step!,
    n::Int=1
)
    
    for i in range(1,n)
        for agent in model.agentsList
            agent_step!(agent,model) 
        end
    end 

end


"""
Stepping function for a model of type AgentBasedModel with 
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
    agents_first : agent_step! executed first before model_step
"""
function step!(
    model::AbstractABM, 
    agent_step!,
    model_step!,  
    n::Int=1,
    agents_first::Bool=true 
)  
    
    for i in range(1,n)
        
        if agents_first 
            for agent in model.agentsList
                agent_step!(agent,model) 
            end
        end
    
        model_step!(model)
    
        if !agents_first
            for agent in model.agentsList
                agent_step!(agent,model)
            end
        end
    
    end

end # step! 


"""
Stepping function for a model of type AgentBasedModel with 
    pre_model_step!(modelObj::AgentBasedModel)
    agent_step!(agentObj,modelObj::AgentBasedModel) 
    model_step!(modelObj::AgentBasedModel)
    n::number of steps 
"""
function step!(
    model::AbstractABM,
    pre_model_step!, 
    agent_step!,
    post_model_step!,  
    n::Int=1,
)  
    
    for i in range(1,n)
        
        pre_model_step!(model)
    
        for agent in model.agentsList
            agent_step!(agent,model)
        end
        
        post_model_step!(model)
    
    end

end # step! 

"""
Step an ABM given a set of independent stepping functions
    pre_model_steps[:](modelObj::AgentBasedModel)
    agent_steps[:](agentObj,modelObj::AgentBasedModel) 
    model_step[:](modelObj::AgentBasedModel)
    n::number of steps 
"""
function step!(
    model::AbstractABM,
    pre_model_steps::Vector{Function}, 
    agent_steps::Vector{Function},
    post_model_steps::Vector{Function},  
    n::Int=1,
)  
    
    for i in range(1,n)
        
        for k in 1:length(pre_model_steps)
            pre_model_steps[k](model)
        end
    
        for agent in model.agentsList
            for k in 1:length(agent_steps)
                agent_steps[k](agent,model)
            end 
        end
        
        for k in 1:length(post_model_steps)
            post_model_steps[k](model)
        end
    
    end

end # step! 


#=

"set a symbol property to a model without overwriting"
function setproperty!(model::AbstractABM,property::Symbol,val)
    if property in keys(model.properties)
        error("$(property) is already available")
    end 
    model.properties[property] = val  
end 


"A dummy connection between arbitrary ABMs"
dummyconnect(abm1::AbstractABM,
             abm2::AbstractABM,
             properties::Dict{Symbol}) = nothing


It is thinkable to associate further attributes to ABMs s.a.

variable(sabm::AbstractABM,var::Symbol) = sabm.variable[var]
parameter(sabm::AbstractABM,par::Parameter) = sabm.parameter[par]
data(sabm::AbstractABM,symbol::Symbol)  = sabm.data[symbol]
... 
function addData!(sabm,symbol,csvfile) end
function addVariable!(sabm,symbol) end 
function deleteVariable!(sabm,symbol) end

=# 
