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
    curTime = simPars.startTime

    simPars.verbose ? setVerbose!() : unsetVerbose!()
    setDelay!(simPars.sleeptime)

    # no point in continuing with the simulation if we are not recording results
    finishTime = min(simPars.finishTime, simPars.endLogTime)

    while curTime <= finishTime
        stepModel!(model, curTime, pars)

        if logfile != nothing && curTime >= simPars.startLogTime
            results = observe(Data, model, curTime)
            log_results(logfile, results; FS)
        end

        curTime += simPars.dt
    end
end



