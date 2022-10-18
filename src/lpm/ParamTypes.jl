
module ParamTypes

using Parameters

export SimulationPars

include("./demography/demographypars.jl")

"General simulation parameters"
@with_kw mutable struct SimulationPars 
    startTime :: Int  = 1920
    finishTime :: Int = 2040 
    dt :: Rational{Int} = 1//12      # step size 
    seed :: Int       = 42 ;   @assert seed >= 0 # 0 is random      
    verbose::Bool     = false       # whether significant intermediate info shallo be printed 
    sleeptime :: Float64  = 0; @assert sleeptime >= 0
                                   # how long simulation is suspended after printing info 
    checkassumption :: Bool = false # whether assumptions in unit functions should be checked
end 


end # ParamTypes
