"""
Main specification of a Social Simulation type

This file is included in SocialSimuilations module
"""

using Random
using SocialAgents: AbstractAgent 
using SocialABMs:   AbstractABM 

export step!, dummystep, run!  
export attach_model_step!, attach_agent_step!


# At the moment no need for Abstract Social Simulation! 
abstract type AbstractSocialSimulation end 

model(sim::AbstractSocialSimulation)      = sim.model 
startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
seed(sim::AbstractSocialSimulation)       = sim.properties[:seed]

#===========================
General stepping functions / imitating Agents.jl 
=###########################

"dummy stepping function for arbitrary agents"
dummystep(agent::AbstractAgent,model::AbstractABM) = nothing 
 
"default dummy model stepping function"
dummystep(::AbstractABM) = nothing 

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

 
"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSocialSimulation,
              agent_step_function,
              model_step_function) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        step!(model(simulation),agent_step_function,model_step_function)
    end 

end 
 
