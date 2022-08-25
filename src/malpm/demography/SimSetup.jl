module SimSetup

# using XAgents: agestepAlivePerson!
using MALPM.Population: agestepAlivePerson!, removeDead!
using LPM.Parameters: loadDefaultSimPars

using MultiAgents: dummystep, defaultprestep!, defaultpoststep!
using MultiAgents: startTime, dt

using MultiAgents: ABMSimulation, MABMSimulation
using MultiAgents: attach_agent_step!, attach_pre_model_step!, attach_post_model_step!  

using MALPM.Demography.Simulate: doDeaths!
using MALPM.Demography.Create: DemographyExample, LPMUKDemography, LPMUKDemographyOpt

import MultiAgents: setup!

export loadSimulationParameters, setup!  


"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic Simulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
function loadSimulationParameters() 

    simpars = loadDefaultSimPars()

    # The following moight be modified as parameters struct rather than dictionary

    Dict(:numRepeats=>simpars.numRepeats,
        :startTime=>simpars.startTime,
        :finishTime=>simpars.finishTime,
        :dt=>simpars.dt,
        :seed=> simpars.seed,
        :stepnumber=> 0,
        :currstep=> simpars.startTime,
        :verbose=> simpars.verbose,
        :sleeptime=> simpars.sleeptime)
end 


function setup!(sim::ABMSimulation,example::DemographyExample) 

    # initDefaultProb!(sim.model,sim.properties)
    sim.model.properties = deepcopy(sim.properties)

    sim.agent_steps      = [dummystep]  
    sim.pre_model_steps  = [defaultprestep!]
    sim.post_model_steps = [defaultpoststep!] 

    # Why is simulation propertoes, properties of the model?
    #=
    sim.model.properties[:currstep]   = Rational(startTime(sim)) 
    sim.model.properties[:dt]         = dt(sim)
    sim.model.properties[:stepnumber] = 0 
    sim.model.properties[:example]    = example

    sim.model.properties[:verbose]    = sim.properties[:verbose]
    sim.model.properties[:sleeptime]  = sim.properties[:sleeptime]
    =# 

    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    attach_agent_step!(sim.simulations[3],agestepAlivePerson!)    
    attach_pre_model_step!(sim.simulations[3],doDeaths!)

    # sim.model.properties[:example] = example 

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

    # to simplify the following ... 

    sim.model.abms[1].properties[:example] = example  
    sim.model.abms[2].properties[:example] = example  
    sim.model.abms[3].properties[:example] = example  
    
    # attach_post_model_step!(sim.simulations[3],someStats!)
    # attach_post_model_step!(sim.simulations[3],writeSomeResults!)
    # attach_final_step!(sim,someFinaliztion!) 

    nothing 
end

end # SimSetup 