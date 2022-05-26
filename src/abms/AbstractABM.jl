"""
Specification of an abstract ABM type as a supertype for all 
    (elementary) Agent based models. It resembles the ABM concept
    from Agents.jl
"""

using SocialAgents

"Abstract ABM resembles the ABM concept from Agents.jl"
abstract type AbstractABM end 

export allagents, nagents
export add_agent!, move_agent!, kill_agent!
export step!, dummystep 


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

"return the id-th agent"
function getindex(model::AbstractABM,id) 
    nothing 
end

# equivalent to operator [], i.e. model[id] 

"random seed of the model"
function seed!(model::AbstractABM,seed) 
    nothing 
end 

"numbe of  agents"
function nagents(model::AbstractABM) 
    length(model.agentsList)
end 

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

"to a given position" 
function move_agent!(agent,pos,model::AbstractABM)
    nothing 
end 

"remove an agent"
function kill_agent!(agent,model::AbstractABM) 
    nothing 
end

#===========================
General stepping functions 
=###########################

"dummy stepping function for arbitrary agents"
function dummystep(agent::AbstractAgent,model::AbstractABM) 
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

# Other versions of the above function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 


#=
Other potential functions 

genocide(model::ABM): kill all agents 
=# 
