module SimSetup


using MALPM.Demography.Population: removeDead!, 
                agestepAlivePerson!, agestep!, population_step!

using  MALPM.Demography: DemographyExample, 
                            LPMUKDemography, LPMUKDemographyOpt
using  MALPM.Demography.Simulate: doDeaths!, doBirths!, doDivorces!

using  MultiAgents: ABMSimulation
using  MultiAgents: attach_pre_model_step!, attach_post_model_step!, 
                    attach_agent_step!
using  Utilities: setVerbose!, unsetVerbose!, setDelay!,
                    checkAssumptions!, ignoreAssumptions!
import MultiAgents: setup!, verbose
export setup!  

"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic Simulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""


function setupCommon!(sim::ABMSimulation) 

    verbose(sim) ? setVerbose!() : unsetVerbose!()
    setDelay!(sim.parameters.sleeptime)
    sim.parameters.checkassumption ? checkAssumptions!() :
                                        ignoreAssumptions!()

    attach_post_model_step!(sim,doDeaths!)
    attach_post_model_step!(sim,doBirths!)
    attach_post_model_step!(sim,doDivorces!)
    nothing 
end 

"set up simulation functions where dead people are removed" 
function setup!(sim::ABMSimulation, example::LPMUKDemography)
    # attach_pre_model_step!(sim,population_step!)
    attach_agent_step!(sim,agestep!)
    setupCommon!(sim)

    nothing 
end


function setup!(sim::ABMSimulation,example::LPMUKDemographyOpt) 

    attach_agent_step!(sim,agestepAlivePerson!)
    setupCommon!(sim)

    nothing 
end


end # SimSetup 