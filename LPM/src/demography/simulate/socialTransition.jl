using Distributions: Normal, LogNormal

export socialTransition!, selectSocialTransition 


function selectSocialTransition(p, pars)
    p.alive && hasBirthday(p) && 
    p.age == workingAge(p, pars) &&
    p.status == WorkStatus.student
end


# class sensitive versions
# TODO? 
# * move to separate, optional module
# * replace with non-class version here
initialIncomeLevel(person, pars) = pars.incomeInitialLevels[person.classRank+1]

workingAge(person, pars) = pars.workingAge[person.classRank+1]

function incomeDist(person, pars)
    # TODO make parameters
    if person.classRank == 0
        LogNormal(2.5, 0.25)
    elseif person.classRank == 1
        LogNormal(2.8, 0.3)
    elseif person.classRank == 2
        LogNormal(3.2, 0.35)
    elseif person.classRank == 3
        LogNormal(3.7, 0.4)
    elseif person.classRank == 4
        LogNormal(4.5, 0.5)
    else
        error("unknown class rank!")
    end
end


mutable struct SocialCache
    socialClassShares :: Vector{Float64}
end

SocialCache() = SocialCache([])

function socialPreCalc!(model, pars)
    pc = model.socialCache
    pc.socialClassShares = zeros(5)
    
    for p in model.pop
        pc.socialClassShares[p.classRank+1] += 1
    end
    
    pc.socialClassShares ./= length(model.pop)
end


doneStudying(person, pars) = person.classRank >= 4

# TODO
function addToWorkforce!(person, model)
end

# move newly adult agents into study or work
function socialTransition!(person, time, model, pars)
    probStudy = doneStudying(person, pars)  ?  
        0.0 : startStudyProb(person, model, pars)

    if rand() < probStudy
        startStudying!(person, pars)
    else
        startWorking!(person, pars)
        addToWorkforce!(person, model)
    end
end


# probability to start studying instead of working
function startStudyProb(person, model, pars)
    if person.father == person.mother == undefinedPerson
        return 0.0
    end
    
    if isUndefined(person.provider)
        return 0.0
    end

                                # renamed from python but same calculation
    perCapitaDisposableIncome = householdIncomePerCapita(person)

    if perCapitaDisposableIncome <= 0
        return 0.0
    end

    forgoneSalary = initialIncomeLevel(person, pars) * 
        pars.weeklyHours[person.careNeedLevel+1]
    relCost = forgoneSalary / perCapitaDisposableIncome
    incomeEffect = (pars.constantIncomeParam+1) / 
        (exp(pars.eduWageSensitivity * relCost) + pars.constantIncomeParam)

    # TODO factor out class
    targetEL = person.parentClassRank
    dE = targetEL - person.classRank
    expEdu = exp(pars.eduRankSensitivity * dE)
    educationEffect = expEdu / (expEdu + pars.constantEduParam)

    careEffect = 1/exp(pars.careEducationParam * (person.socialWork + person.childWork))

    pStudy = incomeEffect * educationEffect * careEffect

    #pStudy *= studyClassFactor(person, model, pars)

    return max(0.0, pStudy)
end

function startStudying!(person, pars)
    addClassRank!(person, 1) 
end

# TODO here for now, maybe not the best place?
function resetWork!(person, pars)
    person.status = WorkStatus.unemployed
    person.newEntrant = true
    person.workingHours = 0
    person.income = 0
    person.jobTenure = 0
    # TODO
    # monthHired
    # jobShift
    setEmptyJobSchedule!(person)
    person.outOfTownStudent = true
end

function startWorking!(person, pars)
    resetWork!(person, pars)

    person.status = WorkStatus.worker

    dKi = rand(Normal(0, pars.wageVar))
    person.initialWage = initialIncomeLevel(person, pars) * exp(dKi)

    dist = incomeDist(person, pars)

    person.finalWage = rand(dist)

    # updates provider as well
    setAsSelfproviding!(person)
end

