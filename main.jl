include("mainHelpers.jl")

const simPars, pars = loadParameters(ARGS)

seed!(simPars.seed)

const model = setupModel(pars)

@time run!(model, simPars, pars)
