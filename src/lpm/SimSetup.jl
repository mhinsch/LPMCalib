module SimSetup

using SocialABMs: agestep!
using SocialABMs: dummystep, defaultprestep!, defaultpoststep! 
using SocialSimulations: startTime, dt
using SocialSimulations: ABMSocialSimulation, MABMSimulation
using SocialSimulations: attach_agent_step!, attach_pre_model_step!, attach_post_model_step!  
using LoneParentsModel.Simulate: doDeaths!
import SocialSimulations: setup!, AbstractExample

export LPMUKDemography
export loadSimulationParameters, setup!  


# Example Name 

struct LPMUKDemography <: AbstractExample end 

"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic SocialSimulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
function loadSimulationParameters() 
    Dict(:numRepeats=>1,
        :startTime=>1860,
        :finishTime=>2040,
        :dt=>1//12,
        :seed=> floor(Int,time()))
end 


function setup!(sim::ABMSocialSimulation,example::LPMUKDemography) 
    
    sim.agent_steps      = [dummystep]  
    sim.pre_model_steps  = [defaultprestep!]
    sim.post_model_steps = [defaultpoststep!] 

    sim.model.properties[:currstep]   = Rational(startTime(sim)) 
    sim.model.properties[:dt]         = dt(sim)
    sim.model.properties[:stepnumber] = 0 
    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    attach_agent_step!(sim.simulations[3],agestep!)    
    attach_pre_model_step!(sim.simulations[3],doDeaths!)
    #= 
    n = length(sim.simulations) 
    for i in 1:n 
        attach_agent_step!(simulations[i],X) 
        attach_model_step!(simulations[i],Y)
    end
    =# 
    nothing 
end


end # SimSetup 