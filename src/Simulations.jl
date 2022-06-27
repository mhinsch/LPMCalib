"""
Generic interface specifying main functions for
    executing an ABM / MABM simulation. 
"""

module Simulations

    include("simulations/AbstractSimulation.jl")
    include("simulations/AbstractABMSimulation.jl")
    include("simulations/AbstractMABMSimulation.jl")
    include("simulations/ABMSimulation.jl")
    include("simulations/MABMSimulation.jl") 

end # Simulations 