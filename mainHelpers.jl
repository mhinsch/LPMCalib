"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia Main.jl

from REPL execute it using 
> include("Main.jl")
"""



using LPM.Demography.Simulate

using Utilities




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
              parameters = pars.poppars, data = model, currstep = time, 
              verbose = simPars.verbose, 
              checkassumption = simPars.checkassumption)

    babies = doBirths!(people = Iterators.filter(a->alive(a), model.pop), 
              parameters = pars.birthpars, data = model, currstep = time, 
             verbose = simPars.verbose, checkassumption = simPars.checkassumption)

    selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, ageTransition!, time, model, pars.workpars, 
                     "age", simPars.verbose)

    selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, workTransition!, time, model, pars.workpars, 
                     "work", simPars.verbose)

    selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
    applyTransition!(selected, socialTransition!, time, model, pars.workpars, 
                     "social", simPars.verbose)

    append!(model.pop, babies)
end


function run!(model, simPars, pars)
    time = Rational(simPars.startTime)

    simPars.verbose = false

    while time < simPars.finishTime
        step!(model, time, simPars, pars)     

        time += simPars.dt
    end
end


