using Random

include("lpm.jl")

const simPars, pars = loadParameters(ARGS)

Random.seed!(simPars.seed)

const model = setupModel(pars)

logfile = setupLogging(simPars)

@time runModel!(model, simPars, pars, logfile)

close(logfile)
