addToLoadPath!(String(@__DIR__) * "/.", 
               String(@__DIR__) * "/lib",
               String(@__DIR__) * "/src")

using ArgParse

using XAgents

using Utilities

using DemographyPars
using DemographyModel


include("src/demography/data.jl")

include("src/handleParams.jl")


function setupModel(pars)
    datp = pars.datapars
    dir = datp.datadir

    demoData   = loadDemographyData(dir * "/" * datp.fertFName, 
                                      dir * "/" * datp.deathFFName,
                                      dir * "/" * datp.deathMFName)

    model = createDemographyModel!(demoData, pars)

    initializeDemographyModel!(model, pars.poppars, pars.workpars, pars.mappars)

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
        stepModel!(model, time, pars)

        if logfile != nothing
            results = observe(Data, model)
            log_results(logfile, results; FS)
            println(results.n_orphans.n, "\t", results.lphh.n / results.chhh.n)
        end

        time += simPars.dt
    end
end



