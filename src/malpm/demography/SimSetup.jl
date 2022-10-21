module SimSetup

# using XAgents: agestepAlivePerson!

using MALPM.Population: removeDead!, population_step!

using  MALPM.Demography: DemographyExample
using  MALPM.Demography.Simulate: doDeaths! #,doBirths!

using  MultiAgents: ABMSimulation
import MultiAgents: setup!, attach_pre_model_step!, attach_post_model_step!
export setup!  

"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic Simulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
#=
function loadSimulationParameters() 

    simpars = SimulationPars(false)

    # The following moight be modified as parameters struct rather than dictionary

    Dict(:numRepeats=>simpars.numRepeats,
        :startTime=>simpars.startTime,
        :finishTime=>simpars.finishTime,
        :dt=>simpars.dt,
        :seed=> simpars.seed,
        :stepnumber=> 0,
        :currstep=> Rational{Int}(simpars.startTime),
        :verbose=> simpars.verbose,
        :sleeptime=> simpars.sleeptime,
        :checkassumption=> simpars.checkassumption)
end 
=# 

function setup!(sim::ABMSimulation,example::DemographyExample)
    attach_pre_model_step!(sim,population_step!)
    attach_post_model_step!(sim,doDeaths!)

    # attach_pre_model_step!(sim.simulations[3],removeDead!)
    nothing 
end

#= 
function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    #attach_agent_step!(sim.simulations[3],agestepAlivePerson!)

    
    attach_pre_model_step!(sim.simulations[3],removeDead!)
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

    println("setting up optimized demography simulation")

    attach_pre_model_step!(sim.simulations[3],doDeaths!)
    # attach_pre_model_step!(sim.simulations[3],removeDead!)
    attach_pre_model_step!(sim.simulations[3],doBirths!)
    attach_post_model_step!(sim.simulations[3],population_step!)

    # to simplify the following ... 
    
    # attach_post_model_step!(sim.simulations[3],someStats!)
    # attach_post_model_step!(sim.simulations[3],writeSomeResults!)
    # attach_final_step!(sim,someFinaliztion!) 

    nothing 
end
=#

end # SimSetup 