using Random

include("mainHelpers.jl")

const simPars, pars = loadParameters(ARGS)

Random.seed!(simPars.seed)

const model = setupModel(pars)

@time run!(model, simPars, pars)
