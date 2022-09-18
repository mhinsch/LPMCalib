using Distributions: Normal, LogNormal

# class sensitive versions
# TODO 
# * move to separate, optional module
# * replace with non-class version here
initialIncomeLevel(person, pars) = pars.incomeInitialLevels[classRank(person)]

workingAge(person, pars) = pars.workingAge[classRank(p)]

function incomeDist(person, pars)
    # TODO make parameters
    if classRank(person) == 0
        LogNormal(2.5, 0.25)
    elseif classRank(person) == 1
        LogNormal(2.8, 0.3)
    elseif classRank(person) == 2
        LogNormal(3.2, 0.35)
    elseif classRank(person) == 3
        LogNormal(3.7, 0.4)
    elseif classRank(person) == 4
        LogNormal(4.5, 0.5)
    else
        error("unknown class rank!")
    end
end

function studyClassFactor(person, model, pars)
    if classRank(person) == 0 
        return socialClassShares(model, 0) > 0.2 ?  1/0.9 : 0.85
    end

    if classRank(person) == 1 && socialClassShares(model, 1) > 0.35
        return 1/0.8
    end

    if classRank(person) == 2 && socialClassShares(model, 2) > 0.25
        return 1/0.85
    end

    1.0
end

doneStudying(person, pars) = classRank(person) >= 4

# TODO
function addToWorkForce!(person, model)
end


# move newly adult agents into study or work
function doSocialTransitions!(people, time, model, pars, verbose=true)
    (year,month) = date2yearsmonths(time)
    month += 1 # adjusting 0:11 => 1:12 

    # newly adult people
    newAdults = I.filter(people) do p
        hasBirthday(p, month) && 
        age(p) == workingAge(p, pars) &&
        status(p) == student
    end

    if verbose
        println(count(x->true, newAdults), " new adults")
    end

    for person in newAdults
        probStudy = doneStudying(person, pars)  ?  
            0.0 : startStudyProb(person, model, pars)

        if rand() < probStudy
            startStudying!(person, pars)
        else
            startWorking!(person)
            addToWorkforce!(person, model)
        end
    end
end

# probability to start studying instead of working
function startStudyProb(person, model, pars)
    if !alive(father(person)) && !alive(mother(person))
        return 0.0
    end

    # TODO
    perCapitaDisposableIncome = disposableIncomePerCapita(person)

    if perCapitaDisposableIncome <= 0
        return 0.0
    end

    forgoneSalary = initialIncomeLevels(person, pars) * 
        pars.weeklyHours[careNeedLevel(person)]
    relCost = forgoneSalary / perCapitaDisposableIncome
    incomeEffect = (pars.constantIncomeParam+1) / 
        (exp(pars.eduWageSensitivity * relCost) + pars.constantIncomeParam)

    # TODO factor out class
    targetEL = max(classRank(father(person)), classRank(mother(person)))
    dE = targetEL - classRank(person)
    expEdu = exp(pars.eduRankSensitivity * dE)
    educationEffect = expEdu / (expEdu + pars.constantEduParam)

    careEffect = 1/exp(pars.careEducationParam * (socialWork(person) + childWork(person)))

    pStudy = incomeEffect * educationEffect * careEffect

    pStudy *= studyClassFactor(person, model, pars)

    return max(0.0, pStudy)
end

function startStudying!(person, pars)
    addClassRank!(person, 1) 
end

# TODO here for now, maybe not the best place
function resetWork!(person, pars)
    status!(person, WorkStatus.unemployed)
    newEntrant!(person, true)
    workingHours!(person, 0)
    income!(person, 0)
    jobTenure!(person, 0)
    # monthHired
    # jobShift
    schedule!(person, zeros(Int, 7, 24))
    outOfTownStudent!(person, true)
end

function startWorking!(person, pars)

    resetWork!(person)

    dKi = rand(Normal(0, pars.wageVar))
    initialIncome!(person, initialIncomeLevel(person, pars) * exp(dKi))

    dist = incomeDist(person, pars)

    finalIncome!(person, rand(dist))
end

