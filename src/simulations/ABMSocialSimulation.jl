"""
Definition of a social simulation type. It resembles Agents.jl 
""" 

export ABMSocialSimulation 
using SocialABMs: AbstractSocialABM
using SocialABMs: dummystep

mutable struct ABMSocialSimulation <: AbstractABMSimulation  
    model::AbstractSocialABM
    properties::Dict{Symbol,Any} 
    
    # pre_model_step::Function 
    agent_step::Function       # agent_step::Vector{Function}
    model_step::Function 

    # ABMSocialSimulation(createABM::Function,properties::Dict{Symbol}) = new(createABM(),copy(properties),dummystep,dummystep)
    function ABMSocialSimulation(createABM::Function,properties::Dict{Symbol};
                                 example=DummyExample()) 
        abmsimulation = new(createABM(),copy(properties),dummystep,dummystep)
        setup!(abmsimulation,example)
        abmsimulation 
    end 
end 

# default cors .

#
# function run! 
# run!(abm::ABMSocialSimulation,Simproperties) = run!(abm,...) 
# 


# Simulation setup phasze 
# attaching simulations  end 
# attach_agent_step      end 
# attach_model_step      end 
# attach_premodel_step   end