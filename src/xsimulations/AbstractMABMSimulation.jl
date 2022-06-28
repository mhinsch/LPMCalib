"""
    An Agents.jl-like concept for simulating a MABM 

    This source file is part of the Simulations module 
""" 

using  MultiAgents.Util:    AbstractExample, DummyExample 

export AbstractMABMSimulation 
export setup!, step!, run! 

abstract type AbstractMABMSimulation <: AbstractSimulation end 

"setting up the simualtion properties and stepping functions"
setup!(::AbstractMABMSimulation,::AbstractExample) = nothing 

"condcut n simulation step(s) for a given MABM"
function step!(sim::AbstractMABMSimulation,n::Int=1)

    nabm = length(sim.simulations)
    for simulation_step in 1:n 
        for j in 1:nabm
            step!(sim.simulations[j],1)
        end 
    end

end

"Run a simulation for a given MABM"
function run!(sim::AbstractMABMSimulation;verbose::Bool=false,yearly=true)  

    Random.seed!(seed(sim))
    
    n = length(sim.simulations)
    for simulation_step in range(startTime(sim),finishTime(sim),step=dt(sim))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(sim) 
    end

end


