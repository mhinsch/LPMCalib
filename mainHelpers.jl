"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia Main.jl

from REPL execute it using 
> include("Main.jl")
"""

include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end


using LPM.ParamTypes
using LPM.ParamTypes.Loaders

using XAgents

using LPM.Demography.Create
using LPM.Demography.Initialize
using LPM.Demography.Simulate

using Utilities

mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}

    fertility :: Matrix{Float64}
    death_female :: Matrix{Float64}
    death_male :: Matrix{Float64}
end


function createUKDemography!(pars)
    ukTowns = createUKTowns(pars.mappars)

    ukHouses = Vector{PersonHouse}()

    ukPopulation = createUKPopulation(pars.poppars)

    ukDemoData   = loadUKDemographyData()

    Model(ukTowns, ukHouses, ukPopulation, 
            ukDemoData.fertility , ukDemoData.death_female, ukDemoData.death_male)
end


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemography!(model, poppars, workpars, mappars)
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)

    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end

    nothing
end


function populationStep!(pop, simPars, pars)
    for agent in pop
        if !alive(agent)
            continue
        end

        agestep!(agent, simPars.dt)
    end
end


function step!(model, time, simPars, pars)
    # TODO remove dead people?
    doDeaths!(people = Iterators.filter(a->alive(a), model.pop),
              parameters = pars.poppars, model = model, currstep = time)

    orphans = Iterators.filter(p->selectAssignGuardian(p), model.pop)
    applyTransition!(orphans, assignGuardian!, "adoption", time, model, pars)

    babies = doBirths!(people = Iterators.filter(a->alive(a), model.pop), 
                       parameters = pars.birthpars, model = model, currstep = time)

    selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, ageTransition!, "age", time, model, pars.workpars)

    selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, workTransition!, "work", time, model, pars.workpars)

    selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
    applyTransition!(selected, socialTransition!, "social", time, model, pars.workpars) 

    selected = Iterators.filter(p->selectDivorce(p, pars), model.pop)
    applyTransition!(selected, divorce!, "divorce", time, model, 
                     fuse(pars.divorcepars, pars.workpars))

    resetCacheMarriages()
    selected = Iterators.filter(p->selectMarriage(p, pars.workpars), model.pop)
    applyTransition!(selected, marriage!, "marriage", time, model, 
                     fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))

    append!(model.pop, babies)
end


function run!(model, simPars, pars)
    time = Rational(simPars.startTime)

    simPars.verbose ? setVerbose!() : unsetVerbose!()
    setDelay!(simPars.sleeptime)

    while time < simPars.finishTime
        step!(model, time, simPars, pars)     

        time += simPars.dt
    end
end


function create_params(argv, par_type)
	arg_settings = ArgParseSettings("run simulation", autofix_names=true)

	@add_arg_table! arg_settings begin
		"--stop-time", "-t"
			help = "at which time to stop the simulation" 
			arg_type = Float64
			default = 50.0
		"--par-out-file"
			help = "file name for parameter output"
			default = "params_used.jl"
		"--city-out-file"
			help = "file name for city data output"
			default = "cities.txt"
		"--link-out-file"
			help = "file name for link data output"
			default = "links.txt"
		"--log-file", "-l"
			help = "file name for log"
			default = "log.txt"
		"--map", "-m"
			help = "load map in JSON format"
			default = ""
		"--scenario", "-s"
			help = "load custom scenario code"
			nargs = 2
			action = :append_arg
		"--scenario-dir"
			help = "directory to search for scenarios"
			default = ""
	end

	add_arg_group!(arg_settings, "simulation parameters")
	fields_as_args!(arg_settings, par_type)

	args = parse_args(argv, arg_settings, as_symbols=true)
	p = @create_from_args(args, par_type)

	args, p
end


function getParameters()
    simPars = SimulationPars(false)

    pars = loadUKDemographyPars() 

    simPars, pars
end


function setupModel(pars)
    model = createUKDemography!(pars)

    initializeDemography!(model, pars.poppars, pars.workpars, pars.mappars)

    @show "Town Samples: \n"     
    @show model.towns[1:10]
    println(); println(); 
                            
    @show "Houses samples: \n"      
    @show model.houses[1:10]
    println(); println(); 
                            
    @show "population samples : \n" 
    @show model.pop[1:10]
    println(); println(); 

    model
end

