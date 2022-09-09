module SimSetup

# using XAgents: agestepAlivePerson!
using MALPM.Population: removeDead!, population_step!
using LPM.ParamTypes: SimulationPars

using MultiAgents: dummystep, defaultprestep!, defaultpoststep!
using MultiAgents: startTime, dt

using MultiAgents: ABMSimulation, MABMSimulation
using MultiAgents: attach_agent_step!, attach_pre_model_step!, attach_post_model_step!  

using MALPM.Demography.Simulate: doDeaths!,doBirths!
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

    simpars = SimulationPars()

    # The following moight be modified as parameters struct rather than dictionary

    Dict(:numRepeats=>simpars.numRepeats,
        :startTime=>simpars.startTime,
        :finishTime=>simpars.finishTime,
        :dt=>simpars.dt,
        :seed=> simpars.seed,
        :stepnumber=> 0,
        :currstep=> simpars.startTime,
        :verbose=> simpars.verbose,
        :sleeptime=> simpars.sleeptime,
        :checkassumption=> simpars.checkassumption)
end 


function setup!(sim::ABMSimulation,example::DemographyExample) 

    # initDefaultProb!(sim.model,sim.properties)
    sim.model.properties = deepcopy(sim.properties)
    sim.model.example    = example 
    # sim.agent_steps      = [] # insted of [dummystep!]  

    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    #attach_agent_step!(sim.simulations[3],agestepAlivePerson!)

    attach_pre_model_step!(sim.simulations[3],doDeaths!)
    attach_pre_model_step!(sim.simulations[3],doBirths!)
    attach_post_model_step!(sim.simulations[3],population_step!)

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

    @assert false  # To be updated
    # attach_init_step!(sim,someInitialization!)

    #attach_agent_step!(sim.simulations[3],removeDead!) 
    #attach_agent_step!(sim.simulations[3],agestepAlivePerson!)    
    attach_pre_model_step!(sim.simulations[3],doDeaths!)
    attach_pre_model_step!(sim.simulations[3],removeDead!)
    attach_post_model_step!(sim.simulations[3],population_step!)

    # to simplify the following ... 
    
    # attach_post_model_step!(sim.simulations[3],someStats!)
    # attach_post_model_step!(sim.simulations[3],writeSomeResults!)
    # attach_final_step!(sim,someFinaliztion!) 

    nothing 
end

end # SimSetup 