"""
    An Agents.jl-like concept for simulating a MABM 

    This source file is part of the SocialSimulations module 
""" 

export AbstractMABMSimulation 
export setup!, step!, run! 

abstract type AbstractMABMSimulation <: AbstractSocialSimulation end 

"setting up the simualtion properties and stepping functions"
setup!(::AbstractMABMSimulation,::AbstractExample) = error("Not implemented")

"condcut n simulation step(s) for a given MABM"
function step!(sim::AbstractMABMSimulation,n::Int=1,agents_first=true) 

    for simulation_step in 1:n 
        step!(sim.simulations[i],1,agents_first)
    end

end

"Run a simulation for a given MABM"
function run!(sim::AbstractMABMSimulation)  

    Random.seed!(seed(simulation))
    n = length(sim.simulations)
    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        step!(sim)
    end

end


