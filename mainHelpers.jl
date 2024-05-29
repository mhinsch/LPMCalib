include("lib/loadLibsPath.jl")

addToLoadPath!(String(@__DIR__) * "/.", 
               String(@__DIR__) * "/lib",
               String(@__DIR__) * "/src",
               String(@__DIR__) * "/src/common",
               String(@__DIR__) * "/src/agents",
               String(@__DIR__) * "/src/agents/agent_modules",
               String(@__DIR__) * "/src/simulate")

using ArgParse

using Utilities

using DemographyPars
using DemographyModel
#using DemographyModelEO


include("src/demography/data.jl")

include("src/handleParams.jl")


function setupModel(pars)
    datp = pars.datapars
    dir = datp.datadir

    demoData   = loadDemographyData(dir * "/" * datp.iniAgeFName,
                                dir * "/" * datp.pre51FertFName,
                                dir * "/" * datp.fertFName, 
                                dir * "/" * datp.pre51DeathsFName,
                                dir * "/" * datp.deathFFName,
                                dir * "/" * datp.deathMFName)
                                
    workData = loadWorkData(dir * "/" * datp.unemplFName, 
        dir * "/" * datp.wealthFName)

    model = createDemographyModel!(demoData, workData, pars)

    initializeDemographyModel!(model, pars.poppars, pars.workpars, pars.carepars, pars.taskcarepars, pars.mappars, pars.lhapars)
    
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
    curTime = pars.poppars.startTime

    simPars.verbose ? setVerbose!() : unsetVerbose!()
    setDelay!(simPars.sleeptime)

    # no point in continuing with the simulation if we are not recording results
    finishTime = min(pars.poppars.finishTime, simPars.endLogTime)

    while curTime <= finishTime
        stepModel!(model, curTime, pars)

        if logfile != nothing && curTime >= simPars.startLogTime
            results = observe(Data, model, curTime, pars)
            log_results(logfile, results; FS)
        end
        
        #nWorkers = work_by_time(model.pop)
        
        #println(nWorkers)

        curTime += simPars.dt
    end
end



