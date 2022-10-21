# library
using Random

# load main simulation code
include("lpm.jl")

# create parameters
const simPars, pars = loadParameters(ARGS)

Random.seed!(simPars.seed)

# create model object
const model = setupModel(pars)

const logfile = setupLogging(simPars)

@time runModel!(model, simPars, pars, logfile)

close(logfile)
