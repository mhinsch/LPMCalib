# library
using Random

# load main simulation code
include("mainHelpers.jl")

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

close(logfile)

if simPars.dumpAgents
    open("agents.txt", "w") do f
        saveAgents(f, model.pop)
    end
end

if simPars.dumpHouses
    open("houses.txt", "w") do f
        saveHouses(f, model.houses)
    end
end

