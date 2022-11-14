# library
using Random

# load main simulation code
include("LPM/lpm.jl")

include("analysis.jl")

include("dist_func.jl")


function runDist(obsDates, args)
    simPars, pars = loadParameters(args)

    Random.seed!(simPars.seed)

    model = setupModel(pars)
    time = Rational(simPars.startTime)

    unsetVerbose!()
    setDelay!(0)

    res = Dict{Rational{Int}, Data}()

    dates = reverse(obsDates)
    while time < simPars.finishTime
        stepModel!(model, time, simPars, pars)

        if !isempty(dates) && time == dates[end]
            res[time] = observe(Data, model)
            pop!(dates)
        end

        time += simPars.dt
    end

    res
end


function distance(args)
    obsDates = Rational{Int}[i for i in 1996:2021]

    res = runDist(obsDates, args)

    d_pp = dist_pop_pyramid("data/pop_pyramid_2020.tsv", res, 2020//1)
    d_ss = dist_soc_status("data/soc_status_by_age_2011.tsv", res, 2011//1)
    d_hhs = dist_hh_size("data/hh_size.tsv", res, obsDates)

    (d_pp + d_ss + d_hhs) / 3
end


if !isinteractive()
    println(distance(ARGS))
end
