
module Parameters 

export SimulationPars
export loadDefaultSimPars

include("./demography/Loaders.jl")

mutable struct SimulationPars 
    numRepeats::Int  # how many time
    startTime
    finishTime
    dt               # step size 
    seed               
    verbose::Bool    # whether significant intermediate info shallo be printed 
    sleeptime        # how long simulation is suspended after printing info 

    SimulationPars() = new() 
end 

function loadDefaultSimPars() 

    simpars = SimulationPars() 

    simpars.numRepeats = -1      # not significant at at moment for now

    simpars.startTime  = 1920 
    simpars.finishTime = 2040
    simpars.dt         = 1 // 12 
    simpars.seed       = floor(Int,time()) 
    simpars.verbose    = true 
    simpars.sleeptime  = 0
    
    simpars 
end

end # parameters 
