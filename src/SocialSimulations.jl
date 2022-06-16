"""
Generic interface specifying main functions for
    executing a social simulation. 
"""

module SocialSimulations

    include("simulations/AbstractSocialSimulation.jl")
    include("simulations/ABMSocialSimulation.jl")

end # Socialimulations 