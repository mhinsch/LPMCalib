module SimSetup

# using XAgents: agestepAlivePerson!
using MultiABMs: agestepAlivePerson!, removeDead!

using MultiAgents: dummystep, defaultprestep!, defaultpoststep!
using MultiAgents: startTime, dt

using MultiAgents: ABMSimulation, MABMSimulation
using MultiAgents: attach_agent_step!, attach_pre_model_step!, attach_post_model_step!  
using MALPM.Simulate: doDeaths!
using MALPM.Create: Demography, LPMUKDemography, LPMUKDemographyOpt

import MultiAgents: setup!

export loadSimulationParameters, setup!  


"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic Simulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
function loadSimulationParameters() 
    Dict(:numRepeats=>1,
        :startTime=>1920,
        #:startTime=>1860,
        :finishTime=>2040,
        :dt=>1//12,
        :seed=> floor(Int,time()))
end 


function setup!(sim::ABMSimulation,example::Demography) 
    sim.agent_steps      = [dummystep]  
    sim.pre_model_steps  = [defaultprestep!]
    sim.post_model_steps = [defaultpoststep!] 

    sim.model.properties[:currstep]   = Rational(startTime(sim)) 
    sim.model.properties[:dt]         = dt(sim)
    sim.model.properties[:stepnumber] = 0 
    sim.model.properties[:example]    = example 

    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    attach_agent_step!(sim.simulations[3],agestepAlivePerson!)    
    attach_pre_model_step!(sim.simulations[3],doDeaths!)

    sim.model.properties[:example] = example 

    #= 
    n = length(sim.simulations) 
    for i in 1:n 
        attach_agent_step!(simulations[i],X) 
        attach_model_step!(simulations[i],Y)
    end
    =# 

    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemographyOpt) 

    # attach_init_step!(sim,someInitialization!)

    attach_agent_step!(sim.simulations[3],agestepAlivePerson!)  
    attach_agent_step!(sim.simulations[3],removeDead!)   
    attach_pre_model_step!(sim.simulations[3],doDeaths!)

    sim.model.properties[:example] = example 

    # attach_post_model_step!(sim.simulations[3],someStats!)
    # attach_post_model_step!(sim.simulations[3],writeSomeResults!)
    # attach_final_step!(sim,someFinaliztion!) 

    nothing 
end

end # SimSetup 