
module ParamTypes

using Parameters
using Random: seed!

export SimulationPars

include("./demography/Loaders.jl")

@with_kw mutable struct SimulationPars 
    numRepeats::Int   = -1         # how many time
    startTime :: Int  = 1920
    finishTime :: Int = 2040 
    dt :: Rational{Int} = 1//12      # step size 
    seed :: Int       = 42 ;   @assert seed >= 0 # 0 is random      
    verbose::Bool     = false       # whether significant intermediate info shallo be printed 
    sleeptime :: Float64  = 0; @assert sleeptime >= 0
                                   # how long simulation is suspended after printing info 
    checkassumption :: Bool = false # whether assumptions in unit functions should be checked
end 

function SimulationPars(randomSeed::Bool)
    pars = SimulationPars()
    if randomSeed || pars.seed == 0
        pars.seed = floor(Int, time())
    end 
    seed!(pars.seed)
    pars
end 

end # ParamTypes
