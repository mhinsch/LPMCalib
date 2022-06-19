module SimSetup

using SocialABMs: dummystep, defaultprestep 
using SocialSimulations: startTime, dt
using SocialSimulations: ABMSocialSimulation, MABMSimulation
using SocialSimulations: attach_agent_step!, attach_pre_model_step!, attach_post_model_step!  

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
    attach_agent_step!(sim,dummystep) 
    attach_pre_model_step!(sim,defaultprestep)
    attach_post_model_step!(sim,dummystep)
    sim.model.properties[:currstep] = startTime(sim) 
    sim.model.properties[:dt]       = dt(sim)
    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
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