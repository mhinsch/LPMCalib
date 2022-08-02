""" 
Main components of LoneParentsModel simulation based on MultiAgents.jl package 
""" 
module MALPM

    include("./malpm/demography/Population.jl") 

    # include("./malpm/Loaders.jl")
    include("./malpm/Create.jl")
    include("./malpm/Initialize.jl")
    include("./malpm/Simulate.jl")
    include("./malpm/SimSetup.jl")

end # MALPM