using Distributions: Normal, LogNormal

export socialTransition!, selectSocialTransition 


function selectSocialTransition(p, pars)
    p.alive && hasBirthday(p) && 
    p.age == workingAge(p, pars) &&
    p.status == WorkStatus.student
end


workingAge(person, pars) = pars.workingAge[person.classRank+1]


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


function studentStartWorking!(person, pars)
    setWageProgression!(person, pars)
    # updates provider as well
    setAsSelfproviding!(person)
    
    enterJobMarket!(person)
end


# move newly adult agents into study or work
function socialTransition!(person, time, model, pars)
    probStudy = doneStudying(person, pars)  ?  
        0.0 : startStudyProb(person, model, pars)

    if rand() < probStudy
        startStudying!(person, pars)
    else
        studentStartWorking!(person, pars)
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

    forgoneSalary = pars.incomeInitialLevels[person.classRank+1] * 
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

