include("mainHelpers.jl")

const simPars, pars = getParameters()

const model = setupModel(pars)

@time run!(model, simPars, pars)
