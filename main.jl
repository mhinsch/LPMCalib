using Random
#=
include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end

include("mainHelpersModel.jl")
>>>>>>> MASimplification
=# 

include("lpm.jl")

const simPars, pars = loadParameters(ARGS)

Random.seed!(simPars.seed)

const model = setupModel(pars)

const logfile = setupLogging(simPars)

@time runModel!(model, simPars, pars, logfile)

close(logfile)

#=
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

include("mainHelpers.jl")

@time run!(model, simPars, pars)
=#
