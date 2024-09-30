module JobMarketCM
    

using Utilities


using WorkAM, MaternityAM
using IncomeCM, SocialCM


export ageBand, calcAgeClassShares, assignJobs!, computeURByClassAge
export isActive, isWorking, isUnemployed

canWork(person) = person.careNeedLevel < 4 && !isInMaternity(person) 

isActive(person) = (statusWorker(person) || statusUnemployed(person)) && canWork(person)
isWorking(person) = statusWorker(person) && canWork(person)
isUnemployed(person) = statusUnemployed(person) && canWork(person)


"Assign a person's weekly schedule based on their shift and working hours."
function weeklySchedule(shift, weeklyHours)
    # TODO! are shifts always 5 days?
    dailyHours = floor(Int, weeklyHours/5)
    reducedHours = length(shift.shiftHours) - dailyHours
    if reducedHours <= 0
        shiftHours = copy(shift.shiftHours)
    # if a person doesn't work full-time let them work a random portion of their shift
    else
        start = 1 + rand(0:reducedHours)
        shiftHours = shift.shiftHours[start:start+dailyHours-1]
    end
    
    weeklySchedule = zeros(Bool, 24, 7)
    for day in shift.days
        for hour in shiftHours
            weeklySchedule[hour, day] = true
        end
    end
    
    weeklySchedule
end


# TODO fuse with classShares in social transition?
"count SES and age bands for pop"
function calcAgeClassShares(pop, pars)
    
    # proportion of population in that class
    classShares = zeros(length(pars.cumProbClasses))
    # proportion of population in an age band, calculated for each class
    ageBandShares = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    for p in pop
        classShares[p.classRank+1] += 1
        ageBandShares[p.classRank+1, ageBand(p.age)+1] += 1
    end
    
    # normalise ageBandShares by population per class
    for (i, cs) in enumerate(classShares)
        ageBandShares[i, :] ./= cs
    end
    # now we can make classShares relative to full population
    classShares /= sum(classShares)
    
    classShares, ageBandShares
end
    

ageBand(age) =
    if age <= 19
        0
    elseif age <= 54
        (floor(Int, age) - 5) ÷ 10
    else 
        5
    end
    

function computeURByClassAge(ur, classShares, ageShares, pars)
    rates = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    classBias = zeros(length(pars.cumProbClasses))
    preCalcRateBias!(c->classShares[c+1], 0:length(pars.cumProbClasses)-1, 
        pars.unemploymentClassBias, classBias, 1)
    
    for classGroup in 1:length(pars.cumProbClasses)
        # calc normalisation factor for age bias
        a_age = 0
        for i in 1:pars.numberAgeBands 
            a_age += ageShares[classGroup, i] * pars.unemploymentAgeBias[i]
        end
        
        for ageGroup in 1:pars.numberAgeBands
            # class bias
            classRate = ur * classBias[classGroup]
            lowerAgeBandRate = a_age>0.0 ? classRate/a_age : 0.0
            # class-specific age bias
            rates[classGroup, ageGroup] = lowerAgeBandRate*pars.unemploymentAgeBias[ageGroup]        
        end
    end
    
    rates
end


function assignJob!(person, month, shift, pars)
    changeStatus!(person, WorkStatus.worker, pars)
    person.unemploymentMonths = 0
    person.monthHired = month
    person.wage = computeWage(person, pars)

    person.jobShift = shift
    person.daysOff = [x for x in 1:8 if !(x in shift.days)]
    person.workingHours = pars.weeklyHours[person.careNeedLevel+1]
    person.availableWorkingHours = person.workingHours
    person.jobSchedule = weeklySchedule(shift, person.workingHours)
end

"Assign job shifts to unemployed workers."
function assignJobs!(hiredAgents, shiftsPool, month, pars)
    # removed that for now, was only effectively used in setup
    #sort!(hiredAgents, by=x->x.unemploymentIndex)
    # TODO draw w/out replacement?
    shifts = rand(shiftsPool, length(hiredAgents))
    for person in hiredAgents
        if month == -1
            month = rand(1:12)
        end
        
        weights = cumsum(x.socialIndex for x in shifts) 
        shift_i = searchsortedfirst(weights, rand()*weights[end])
        shift = shifts[shift_i]
        
        assignJob!(person, month, shift, pars)
        
        remove_unsorted!(shifts, shift_i)
    end
    
    nothing
end


end
