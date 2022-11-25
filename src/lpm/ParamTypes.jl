"""
Parameter types and values 

This module is within the LPM module 
"""

module ParamTypes

using Random
using Parameters

import Random.seed! 

export SimulationPars, seed!, reseed0!

include("./demography/demographypars.jl")

"General simulation parameters"
@with_kw mutable struct SimulationPars 
    startTime :: Rational{Int}  = 1920
    finishTime :: Rational{Int} = 2040 
    dt :: Rational{Int} = 1//12      # step size 
    seed :: Int       = 42 ;   @assert seed >= 0 # 0 is random      
    verbose::Bool     = false       # whether significant intermediate info shallo be printed 
    sleeptime :: Float64  = 0; @assert sleeptime >= 0
                                   # how long simulation is suspended after printing info 
    checkassumption :: Bool = false # whether assumptions in unit functions should be checked
    logfile :: String = "log.tsv"
end 

reseed0!(simPars) = 
    simPars.seed = simPars.seed == 0 ?  floor(Int, time()) : 
                                        simPars.seed 

function seed!(simPars::SimulationPars,
                randomizeSeedZero=true)
    if randomizeSeedZero 
        reseed0!(simPars)
    end
    Random.seed!(simPars.seed)
end


end # ParamTypes
