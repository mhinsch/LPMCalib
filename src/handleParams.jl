using ParamUtils
using YAML


"extract name of parameter category from struct type name"
nameOfParType(t) = replace(String(nameof(t)), "Pars" => "") |> Symbol


function saveParametersToFile(simPars::SimulationPars, pars::DemographyPars, fname)
    dict = Dict{Symbol, Any}()

    dict[:Simulation] = parToYaml(simPars)

    for f in fieldnames(DemographyPars)
        name = nameOfParType(fieldtype(DemographyPars, f))
        dict[name] = parToYaml(getfield(pars, f))
    end
    
    YAML.write_file(fname, dict)
end


function loadParametersFromFile(fname)
    DT = Dict{Symbol, Any}
    yaml = fname == "" ? DT() : YAML.load_file(fname, dicttype=DT)

    simpars = parFromYaml(yaml, SimulationPars, :Simulation)

    pars = [ parFromYaml(yaml, ft, nameOfParType(ft)) 
            for ft in fieldtypes(DemographyPars) ]
    simpars, DemographyPars(pars...)
end


