"""
Generic interface specifying main functions for
    executing an ABM / MABM simulation. 
"""

module Simulations

    using MultiAgents: AbstractABM # , ABM 
    
    include("simulations/AbstractSimulation.jl")
    include("simulations/AbstractABMSimulation.jl")
    include("simulations/ABMSimulation.jl")

    using MultiAgents: AbstractMABM   # , MultiABM 
    
    include("simulations/AbstractMABMSimulation.jl")
    include("simulations/MABMSimulation.jl") 

end # Simulations 