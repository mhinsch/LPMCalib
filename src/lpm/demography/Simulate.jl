"""
Functions used for demography simulation 
"""

module Simulate

include("simulate/death.jl")
include("simulate/birth.jl")         
include("simulate/ageTransition.jl")
include("simulate/socialTransition.jl")

end # module Simulate 
