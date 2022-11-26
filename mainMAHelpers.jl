using Random

include("./loadLibsPath.jl")

addToLoadPath!("src")
addToLoadPath!("src/multiagents") 
addToLoadPath!("../MultiAgents.jl")

include("mainHelpers.jl")

using MultiAgents: initMultiAgents, MAVERSION
initMultiAgents()             # reset agents counter
@assert MAVERSION == v"0.3.1"   # ensure MultiAgents.jl latest update 


using LPM.ParamTypes: seed!
using MultiAgents: AbstractMABM, ABMSimulationP 
using MultiAgents: run!
using MALPM.Demography: MAModel, LPMUKDemography, LPMUKDemographyOpt 
using MALPM.Demography.SimSetup: setup! 

"""
How simulations is to be executed: 
- with or without input files, arguments and logging 
""" 

abstract type MainSim end 
struct WithInputFiles <: MainSim end   # Input parameter files 
struct Light <: MainSim end            # no input files 

function loadParameters(::WithInputFiles) 
    simPars, pars = loadParameters(ARGS)
    seed!(simPars)
    simPars, pars 
end  

function loadParameters(::Light)
    simPars = SimulationPars()
    seed!(simPars)
    pars = DemographyPars()
    simPars, pars 
end

setupLogging(simPars,::WithInputFiles) = setupLogging(simPars)
setupLogging(simPars,::Light) = nothing 

closeLogfile(loffile,::WithInputFiles) = close(logfile)
closeLogfile(logfile,::Light) = nothing 