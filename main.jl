include("mainHelpers.jl")

const simPars, pars = loadParameters(ARGS)

seed!(simPars.seed == 0 ? floor(Int, time()) : simPars.seed)

const model = setupModel(pars)

@time run!(model, simPars, pars)
