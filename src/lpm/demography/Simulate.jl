"""
Functions used for demography simulation 
"""

module Simulate

include("simulate/allocate.jl")
include("simulate/death.jl")
include("simulate/birth.jl")  
include("simulate/divorce.jl")       
include("simulate/ageTransition.jl")
include("simulate/socialTransition.jl")
include("simulate/marriages.jl")
include("simulate/dependencies.jl")

end # module Simulate 
