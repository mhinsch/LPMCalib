# library
using Random

# load main simulation code
include("LPM/mainHelpers.jl")

include("analysis.jl")

include("dist_func.jl")


function runDist(obsDates, args)
    simPars, pars = loadParameters(args)

    Random.seed!(simPars.seed)

    model = setupModel(pars)
    time = Rational(pars.poppars.startTime)

    unsetVerbose!()
    setDelay!(0)

    res = Dict{Rational{Int}, Data}()

    dates = reverse(obsDates)
    while ! isempty(dates)
        stepModel!(model, time, pars)

        if time == dates[end]
            res[time] = observe(Data, model, time, pars)
            pop!(dates)
        end

        time += simPars.dt
    end

    res, model
end


function distance(args)
    obsDates = Rational{Int}[i for i in 1996:2021]

    res, _ = runDist(obsDates, args)
    
    
    dists = Float64[]

    push!(dists, dist_pop_pyramid("data/pop_pyramid_2020.tsv", res, 2020//1))
    push!(dists, dist_soc_status("data/soc_status_by_age_2011.tsv", res, 2011//1))
    push!(dists, dist_hh_size("data/hh_size.tsv", res, obsDates))
    push!(dists, dist_maternity_age("data/maternity_by_age.tsv", res, 2020//1))
    push!(dists, dist_maternity_age_SES("data/shares_births_by_age_SES.tsv", res, 2020//1))
    #push!(dists, dist_couples_age_diff("data/couple_age_diff.tsv", res, 2001//1))
    push!(dists, dist_couples_age_diff_fr("data/couple_age_diff_fr.tsv", res, 2017//1))
    push!(dists, dist_num_prev_children("data/num_prev_children.tsv", res, 2020//1))
    # TODO this produces NaN at the moment
    push!(dists, dist_income_deciles("data/income_deciles.tsv", res, 2020//1))
    push!(dists, dist_prop_lphh(res, 2021//1))
    push!(dists, dist_empl_status_by_age("data/employment_by_age.tsv", res, 2016//1))
    push!(dists, dist_empl_by_family_status("data/employment_by_family.tsv", res, 2019//1))
    push!(dists, dist_households_by_empl("data/households_by_employment.tsv", res, 2019//1))
    push!(dists, dist_unemployment_by_class("data/unemployment_by_SES.tsv", res, 2018//1))
    
    println("dists: ", dists)
    
    sum(dists) / length(dists)
end


if !isinteractive() && abspath(PROGRAM_FILE) == @__FILE__
    println(distance(ARGS))
end
