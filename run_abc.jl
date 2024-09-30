using Distributions
using CSV
using DataFrames
using Random
using Dates

include("main_dist.jl")
include("abc_hpc/abc/ownabc.jl")


function run_sim_locally(args)
    # sadly our simulation is not thread-safe so we have to run it via its own julia process
    res = readchomp(`julia main_dist.jl $(split(args))`) |> split
    
    parse(Float64, res[end])
end

# this works when using ThreadSafeDict for memoization but is sadly much, much slower than running externally
function run_sim_threaded(args)
    distance(split(args))
end

function simulate(param_values, names, n_repl=1)
    @assert length(names) == length(param_values)
    
    d = 0.0
    
    for i in 1:n_repl
	    args = "--seed $(rand(1:100000)) --datadir LPM/data -P \"\""
	    
	    for (name, value) in zip(names, param_values)
	        args *= " --$name $value" 
	    end

	    d += run_sim_locally(args)
    end
    
    d / n_repl
    #run_sim_threaded(args)
end

function readParamConfig(fname)
    pconf = CSV.read(fname, DataFrame)
    
    v_min = pconf[!, :Min]
    v_max = pconf[!, :Max]
    
    priors = [Uniform(mi, ma) for (mi, ma) in zip(v_min, v_max)]
    
    String.(pconf[!, :Parameter]), priors
end


function run_ABCdeZ(n_iters, names, list_priors)
	abcdesmc!(Product(list_priors), simulate, 0.01, names, nsims_max = 20000, parallel=true)
end


function run_abc(n_iters, names, priors)
    noise = [0.05 for p in priors];

    particles = Particle[]
    remv = PropRemover(0.5)
    creat = OwnCreator(true, 1.0, priors, noise)

    result = nothing
    #abc(priors, dist, 400, 0.5, noise, 10, verbose=true, scale_noise=true, parallel=true)
    #abc(priors, dist, 4, 0.5, noise, 2, verbose=true, scale_noise=true, parallel=true)
    for i in 1:n_iters
        println("$(now()) starting iteration $i")
        result = abc_iter!(particles, pars->simulate(pars, names, 3), 
                           800, remv, creat, verbose=true, parallel = true)
        #sort!(particles, by=p->p.dist)
        #push!(meds, particles[end ÷ 2].dist)
        #for i in 1:4
        #    push!(devs[i], std(map(p->p.params[i], particles)))
        #end
	flush(stdout)
    end

    result
end


if !isinteractive()
    Random.seed!(42)
    const names, priors = readParamConfig("params/parameters.tsv");

    const res = run_abc(50, names, priors)

    const res_s = sort(res, by=p->p.dist)

    open("calib_latest.tsv", "w") do f
            println(f, "dist\t", join(names, "\t"))
            for p in res_s
                print(f, p.dist, "\t")
                println(f, join(p.params, "\t"))
            end
        end
end
