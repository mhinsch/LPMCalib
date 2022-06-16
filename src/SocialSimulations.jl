"""
Generic interface specifying main functions for
    executing a social simulation. 
"""

module SocialSimulations

    include("simulations/AbstractExample.jl")
    include("simulations/AbstractSocialSimulation.jl")
    include("simulations/AbstractABMSimulation.jl")
    include("simulations/ABMSocialSimulation.jl")
    include("simulations/MABMSimulation.jl") 

end # Socialimulations 