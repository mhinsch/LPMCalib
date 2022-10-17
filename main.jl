include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end

include("mainHelpers.jl")

const simPars, pars = getParameters()

const model = setupModel(pars)

if simPars.verbose 
    @show "Town Samples: \n"     
    @show model.towns[1:10]
    println(); println(); 
                        
    @show "Houses samples: \n"      
    @show model.houses[1:10]
    println(); println(); 
                        
    @show "population samples : \n" 
    @show model.pop[1:10]
    println(); println(); 
end 

@time run!(model, simPars, pars)
