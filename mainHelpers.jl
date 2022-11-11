addToLoadPath!(".", "src")

using ArgParse

using LPM.ParamTypes

using XAgents

using LPM.Demography.Create
using LPM.Demography.Initialize
using LPM.Demography.Simulate

using Utilities


# TODO put into module somewhere?
# Atiyah: Suggestion: as it is related to ParamTypes, it fits there
#                     or another module for Data (though currently 
#                     not that significant amount of code)
include("src/lpm/demography/demographydata.jl")

include("src/handleParams.jl")

include("analysis.jl")

mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}

    fertility :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale :: Matrix{Float64}
end

function createDemography!(pars)
    ukTowns = createTowns(pars.mappars)

    ukHouses = Vector{PersonHouse}()

    # maybe switch using parameter
    #ukPopulation = createPopulation(pars.poppars)
    ukPopulation = createPyramidPopulation(pars.poppars)
    
    # Atiyah: For more DRY code, you may want to consider calling 
    #         loadDemographyData(datapars) 
    datp = pars.datapars
    dir = datp.datadir

    ukDemoData   = loadDemographyData(dir * "/" * datp.fertFName, 
                                      dir * "/" * datp.deathFFName,
                                      dir * "/" * datp.deathMFName)

    Model(ukTowns, ukHouses, ukPopulation, 
            ukDemoData.fertility , ukDemoData.deathFemale, ukDemoData.deathMale)
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


# Atiyah: remove this for the primative API simulation function
# alivePeople(model) = Iterators.filter(a->alive(a), model.pop)
# data(model) = model 

function stepModel!(model, time, simPars, pars)
    # TODO remove dead people?
    
    # Atiyah: 
    doDeaths!(model,time,pars)   # a possible unified way 
    # or the primiative-API 
    # doDeaths!(alivePeople(model), time, data(model), pars.poppars)

    orphans = Iterators.filter(p->selectAssignGuardian(p), model.pop)
    applyTransition!(orphans, assignGuardian!, "adoption", time, model, pars)

    # Atiyah: 
    babies = doBirths!(model,time,pars)
    # babies = doBirths!(alivePeople(model), model.pop), time, model, pars.birthpars)

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


function loadParameters(argv, cmdl...)
	arg_settings = ArgParseSettings("run simulation", autofix_names=true)

	@add_arg_table! arg_settings begin
		"--par-file", "-p"
            help = "parameter file"
            default = ""
        "--par-out-file", "-P"
			help = "file name for parameter output"
			default = "parameters.run.yaml"
	end

    if ! isempty(cmdl)
        add_arg_table!(arg_settings, cmdl...)
    end

    # setup command line arguments with docs 
    
	add_arg_group!(arg_settings, "Simulation Parameters")
	fieldsAsArgs!(arg_settings, SimulationPars)

    for t in fieldtypes(DemographyPars)
        groupName =  String(nameOfParType(t)) * " Parameters"
        add_arg_group!(arg_settings, groupName)
        fieldsAsArgs!(arg_settings, t)
    end

    # parse command line
	args = parse_args(argv, arg_settings, as_symbols=true)

    # read parameters from file if provided or set to default
    simpars, pars = loadParametersFromFile(args[:par_file])

    # override values that were provided on command line

    overrideParsCmdl!(simpars, args)

    @assert typeof(pars) == DemographyPars
    for f in fieldnames(DemographyPars)
        overrideParsCmdl!(getfield(pars, f), args)
    end

    # Atiyah: for more DRY Code, you may consider using 
    # LPM.ParamTypes.{seed!,reseed0!} within mainHelpers.jl 
    # and remove the following call & the using statement 
    # set time dependent seed
    if simpars.seed == 0
        simpars.seed = floor(Int, time())
    end

    # keep a record of parameters used (including seed!)
    saveParametersToFile(simpars, pars, args[:par_out_file])

    simpars, pars, args
end


function setupModel(pars)
    model = createDemography!(pars)

    initializeDemography!(model, pars.poppars, pars.workpars, pars.mappars)

    #= 
    Atiyah: this portion is not need any more. But if useful, could be 
            attached with Logging level. 
    @show "Town Samples: \n"     
    @show model.towns[1:10]
    println(); println(); 
                            
    @show "Houses samples: \n"      
    @show model.houses[1:10]
    println(); println(); 
                            
    @show "population samples : \n" 
    @show model.pop[1:10]
    println(); println(); 
    =# 

    model
end


function setupLogging(simPars; FS = "\t")
    if simPars.logfile == ""
        return nothing
    end

    file = open(simPars.logfile, "w")

    print_header(file, Data; FS)

    file
end


function runModel!(model, simPars, pars, logfile = nothing; FS = "\t")
    time = simPars.startTime

    simPars.verbose ? setVerbose!() : unsetVerbose!()
    setDelay!(simPars.sleeptime)

    while time < simPars.finishTime
        stepModel!(model, time, simPars, pars)

        if logfile != nothing
            results = observe(Data, model)
            log_results(logfile, results; FS)
        end

        time += simPars.dt
    end
end



