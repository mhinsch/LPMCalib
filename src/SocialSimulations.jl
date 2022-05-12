"""
Generic interface specifying main functions for
    executing a social simulation. 
"""

module SocialSimulations

    
    export SocialSimulation 
    export run!

    import SocialABMs: step!

    # At the moment no need for Abstract Social Simulation! 
    abstract type AbstractSocialSimulation end 

    model(sim::AbstractSocialSimulation)      = sim.model 
    startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
    finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
    dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
    

    mutable struct SocialSimulation <: AbstractSocialSimulation  
        model
        properties::Dict{Symbol}
        # SocialSimulation(model::AbstractSocialABM,
        #                 properties::Dict{Symbol}) = new(model,copy(properties))
        SocialSimulation(createABM::Function,properties::Dict{Symbol}) = new(createABM(),copy(properties))
    end 

    # "load data needed by the simulation"
    # loadData!(simulation::AbstractSocialSimulation) = error("Not implemented") 

    # "define and initialize an elemantry ABM"
    # initABMs!(simulation::AbstractSocialSimulation) = error("Not implemented") 

    # "Establish a Multi ABM from the elemantry ABMs"
    # function initMultiABMs end 


    function run!(simulation::AbstractSocialSimulation,
                    agent_step_function,
                    model_step_function) 
    
        # loadData!(simulation) 
        for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
            step!(model(simulation),agent_step_function,model_step_function)
            # Outputing result to be improved later by using agents.jl 
            print("\n\nsample after step: $(simulation_step) :\n")
            print("======================================== \n\n") 
            @show model(simulation).agentsList[1:10]
        end 
    
    end 

end # Socialimulations 