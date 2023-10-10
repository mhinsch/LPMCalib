"Set initial and final wage depending on social class."
function setWageProgression!(person, pars)
    dKi = rand(Normal(0, pars.wageVar))
    person.initialWage = pars.incomeInitialLevels[person.classRank+1] * exp(dKi)
    dKf = rand(Normal(dKi, pars.wageVar))
    person.finalWage = pars.incomeFinalLevels[person.classRank+1] * exp(dKf)
    nothing
end

"Set agent.wealth dependent on cumulative income."
function assignWealthByIncPercentile!(pop, wealthPercentiles, pars)
    sort!(pop, by=x->x.cumulativeIncome) 
    percLength = length(pop) 
    dist = Normal(0.0, pars.wageVar)
    for (i, agent) in enumerate(pop)
        percentile = floor(Int, (i-1)/percLength * 100) + 1
        dK = rand(dist)
        agent.wealth = wealthPercentiles[percentile] * exp(dK)
    end
    nothing
end

"Calculate current wage dependent on initial and final wage and work experience."
function computeWage(person, pars)
    # original formula
    # c = log(I/F)
    # wage = F * exp(c * exp(-1 * r * e))

    fI = person.finalWage
    iI = person.initialWage

    wage = fI * (iI/fI)^exp(-pars.incomeGrowthRate[person.classRank+1] * person.workExperience)

    dK = rand(Normal(0, pars.wageVar))

    wage * exp(dK)
end



