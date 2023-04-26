# library
using Random

# load main simulation code
include("lpm.jl")

# create parameters
const simPars, pars = loadParameters(ARGS)

include(simPars.analysisFile)

Random.seed!(simPars.seed)

# create model object
const model = setupModel(pars)

# like this for CSV output:
# const logfile = setupLogging(simPars, FS=",")
const logfile = setupLogging(simPars)

# like this for CSV output:
# @time runModel!(model, simPars, pars, logfile, FS=",")
@time runModel!(model, simPars, pars, logfile)

open("agents.txt", "w") do f
    save_agents(f, model.pop)
end

close(logfile)
