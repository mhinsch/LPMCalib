#= Parameter handling. Since parameters are split into categories some special proecessing needs to be done so this is not generic enough to be moved into a library. =#


using ParamUtils
using YAML


"Extract name of parameter category from struct type name."
nameOfParType(t) = replace(String(nameof(t)), "Pars" => "") |> Symbol


"Convert parameter objects into YAML and store in file."
function saveParametersToFile(simPars::SimulationPars, pars::ModelPars, fname)
    dict = Dict{Symbol, Any}()

    dict[:Simulation] = parToYaml(simPars)

    for f in fieldnames(ModelPars)
        name = nameOfParType(fieldtype(ModelPars, f))
        dict[name] = parToYaml(getfield(pars, f))
    end
    
    YAML.write_file(fname, dict)
end


"Load parameters from YAML file."
function loadParametersFromFile(fname)
    DT = Dict{Symbol, Any}
    yaml = fname == "" ? DT() : YAML.load_file(fname, dicttype=DT)

    simpars = parFromYaml(yaml, SimulationPars, :Simulation)

    pars = [ parFromYaml(yaml, ft, nameOfParType(ft)) 
            for ft in fieldtypes(ModelPars) ]
    simpars, ModelPars(pars...)
end


"""Handles the entire parameter processing pipeline. 

First, parameters are read from a file provided on the command line or alternatively initialised with default values. Then command line arguments are parsed and parameter values as provided assigned correspondingly (overriding defaults/values from file). Finally the current set of parameter values is written to an output file if a name was provided.
"""
function loadParameters(argv, cmdl...)
    # *** set up command line parsing
    
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

    # *** add parameters as command line arguments (including inline doc strings) 
    
	add_arg_group!(arg_settings, "Simulation Parameters")
	fieldsAsArgs!(arg_settings, SimulationPars)

    for t in fieldtypes(ModelPars)
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

    @assert typeof(pars) == ModelPars
    for f in fieldnames(ModelPars)
        overrideParsCmdl!(getfield(pars, f), args)
    end

    # pick time-dependent seed if seed == 0
    reseed0!(simpars)

    if args[:par_out_file] != ""
        # keep a record of parameters used (including seed!)
        saveParametersToFile(simpars, pars, args[:par_out_file])
    end

    simpars, pars, args
end
