"""
Parameter types for the full model.
"""

module FullModelPars

using Random
using Parameters

import Random.seed! 

export SimulationPars, reseed0!, seed!

# semantic model parameters
include("../parameters/parameters.jl")


"General simulation parameters"
@with_kw mutable struct SimulationPars 
    dt :: Rational{Int} = 1//12      # step size 
    seed :: Int       = 42 ;   @assert seed >= 0 # 0 is random      
    verbose::Bool     = false       # whether significant intermediate info shallo be printed 
    sleeptime :: Float64  = 0; @assert sleeptime >= 0
                                   # how long simulation is suspended after printing info 
    checkassumption :: Bool = false # whether assumptions in unit functions should be checked
    logfile :: String = "log.tsv"
    analysisFile :: String = "analysis.jl"
    startLogTime :: Rational{Int} = 0
    endLogTime :: Rational{Int} = 10000

    dumpAgents :: Bool = false
    dumpHouses :: Bool = false
end 

reseed0!(simPars) = 
    simPars.seed = simPars.seed == 0 ?  floor(Int, time()) : 
                                        simPars.seed 

end # FullModelPars
