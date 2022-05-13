"""
Generic interface specifying main functions for
    executing a social simulation. 
"""

module SocialSimulations

    include("simulations/AbstractSocialSimulation.jl")
    include("simulations/SocialSimulation.jl")
    
    include("simulations/Dummy.jl")
    include("simulations/LoneParentsModel.jl")

end # Socialimulations 