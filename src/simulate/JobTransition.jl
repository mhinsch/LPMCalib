module JobTransition
    

using Utilities

using WorkAM
using JobMarketCM, IncomeCM, SocialCM
using JobMarket


export selectUnemployed, selectEmployed, unemployedTransition!, employedTransition!, jobPreCalc!
export JobCache


mutable struct JobCache
    urates :: Matrix{Float64}
end

JobCache() = JobCache(zeros(1, 1))


function jobPreCalc!(model, time, pars)
    year, month = date2yearsmonths(time)
    
    classShares, ageShares = calcAgeClassShares(Iterators.filter(isActive, model.pop), pars)
    unemploymentRate = model.unemploymentSeries[floor(Int, year - 1860) + 1]
    uRates = computeURByClassAge(unemploymentRate, classShares, ageShares, pars)         
    model.jobCache = JobCache(uRates)
    
    nothing
end


function calcFireProbability(person, model, pars)
    # from old version
    # TODO keep?
    if person.jobTenure < 1
        return 0.0
    end
    
    ur = model.jobCache.urates[person.classRank+1, ageBand(person.age)+1]
    1.0 - 1.0/exp(pars.hireRate / (1.0/ur - 1.0))
end



selectEmployed(person) = statusWorker(person)

function employedTransition!(person, time, model, pars)
    probFired = calcFireProbability(person, model, pars)

    if rand() < probFired
        loseJob!(person)
        changeStatus!(person, WorkStatus.unemployed, pars)
    else        
        person.jobTenure += 1
        if person.workingHours > 0
            person.workingPeriods += person.availableWorkingHours/person.workingHours
        end
        person.workExperience += person.availableWorkingHours/pars.weeklyHours[1]
        person.wage = computeWage(person, pars)
    end
end


function calcHireProbability(person, model, pars)
    1.0 - 1.0/exp(pars.hireRate)
end


selectUnemployed(person) = statusUnemployed(person)

function unemployedTransition!(person, curTime, model, pars)
    probHired = calcHireProbability(person, model, pars)

    if rand() < probHired
        # use old function for now
        # TODO adapt
        assignJobs!([person], model.shiftsPool, date2yearsmonths(curTime)[2], pars)
    end
end


end
