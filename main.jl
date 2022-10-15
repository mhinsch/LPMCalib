include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end

include("mainHelpers.jl")

const simPars, pars = getParameters()

const model = setupModel(pars)

@time run!(model, simPars, pars)
