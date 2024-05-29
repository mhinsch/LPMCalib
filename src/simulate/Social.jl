module Social

using Distributions: Normal, LogNormal

using Utilities

using ChangeEvents
using BasicInfoAM, WorkAM, DemoPerson
using SocialCM, IncomeCM
using Age

export socialTransition!, selectSocialTransition, socialPreCalc!, studentStartWorking!
export SocialCache
export SocialT


function startRetirement!(person, pars)
    loseJob!(person)
    shareWorkingTime = person.workingPeriods / pars.minContributionPeriods

    dK = rand(Normal(0, pars.wageVar))
    person.pension = person.lastIncome * shareWorkingTime * exp(dK)
end

struct SocialT end

function ChangeEvents.process!(::ChangeAge1Yr, ::SocialT, person, model, pars)
    if person.age == pars.ageTeenagers
        changeStatus!(person, WorkStatus.teenager, pars)
    # all agents first become students, start working in social transition
    elseif person.age == pars.ageOfAdulthood
        becomeStudent!(person, pars)
        changeStatus!(person, WorkStatus.student, pars)
    elseif person.age == pars.ageOfRetirement
        startRetirement!(person, pars)
        changeStatus!(person, WorkStatus.retired, pars)
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


function startStudying!(person, pars)
    person.classRank += 1 
end

doneStudying(person, pars) = person.classRank >= 4

function becomeStudent!(person, pars)
    person.classRank = 0
end

function studentStartWorking!(person, pars)
    setWageProgression!(person, pars)
    # updates provider as well
    setAsSelfproviding!(person)
    
    changeStatus!(person, WorkStatus.unemployed, pars)
end


"Age at which a person can next stop studying and start working."
startWorkingAge(person, pars) = pars.startWorkingAge[person.classRank+1]

function selectSocialTransition(p, pars)
    # check once a year
    hasBirthday(p) &&
    # people start working at set ages, dependent on how much they have studied
    p.age == startWorkingAge(p, pars) &&
    p.status == WorkStatus.student
end

"Decide whether agent goes on to study or starts working. Only gets triggered for specific ages."
function socialTransition!(person, time, model, pars)
    probStudy = doneStudying(person, pars)  ?  
        0.0 : startStudyProb(person, model, pars)

    if rand() < probStudy
        startStudying!(person, pars)
    else
        studentStartWorking!(person, pars)
    end
end


"Probability to start studying instead of working."
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



end
