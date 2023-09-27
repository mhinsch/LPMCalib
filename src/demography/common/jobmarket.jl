
function assignWealthByIncPercentile!(pop, wealthPercentiles, pars)
    sort!(pop, by=x->x.cumulativeIncome) 
    percLength = length(pop) 
    dist = Normal(0.0, pars.wageVar)
    for (i, agent) in enumerate(pop)
        percentile = floor(Int, (i-1)/percLength * 100) + 1
        dK = rand(dist)
        agent.wealth = wealthPercentiles[percentile] * exp(dK)
    end
end


"Assign a person's weekly schedule based on their shift and working hours."
function weeklySchedule(shift, weeklyHours)
    dailyHours = floor(Int, weeklyHours/5)
    reducedHours = length(shift.shiftHours) - dailyHours
    if reducedHours <= 0
        shiftHours = copy(shift.shiftHours)
    # if a person doesn't work full-time let them work a random portion of their shift
    else
        start = 1 + rand(0:reducedHours)
        shiftHours = shift.shiftHours[start:start+dailyHours-1]
    end
    
    weeklySchedule = zeros(Bool, 7, 24)
    for day in shift.days
        for hour in shiftHours
            weeklySchedule[day, hour] = true
        end
    end
    
    weeklySchedule
end


ageBand(age) =
    if age <= 19
        0
    elseif 20 <= age <= 24
        1
    elseif 25 <= age <= 34
        2
    elseif 35 <= age <= 44
        3
    elseif 45 <= age <= 54
        4
    else 
        5
    end
    
    
#=function computeUR(ur, classShares, ageShares, classGroup, ageGroup, pars)
    a = 0
    for i in 0:(length(pars.cumProbClasses)-1)
        a += classShares[i+1] * pars.unemploymentClassBias^i
    end
    lowClassRate = ur/a
    classRate = lowClassRate * pars.unemploymentClassBias^classGroup
    
    a = 0
    for i in 1:pars.numberAgeBands 
        a += ageShares[i] * pars.unemploymentAgeBias[i]
    end
    
    lowerAgeBandRate = a>0 ? classRate/a : 0
        
    lowerAgeBandRate * pars.unemploymentAgeBias[ageGroup+1]
end=#


function computeURByClassAge(ur, classShares, ageShares, pars)
    rates = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    
    a = 0
    for i in 1:length(pars.cumProbClasses)
        a += classShares[i] * pars.unemploymentClassBias^(i-1)
    end
    lowClassRate = a > 0.0 ? ur/a : 0.0
    
    for classGroup in 1:length(pars.cumProbClasses)
        a_age = 0
        for i in 1:pars.numberAgeBands 
            a_age += ageShares[classGroup, i] * pars.unemploymentAgeBias[i]
        end
        
        for ageGroup in 1:pars.numberAgeBands
            classRate = lowClassRate * pars.unemploymentClassBias^(classGroup-1)
            lowerAgeBandRate = a_age>0.0 ? classRate/a_age : 0.0
            rates[classGroup, ageGroup] = lowerAgeBandRate*pars.unemploymentAgeBias[ageGroup]        
        end
    end
    
    rates
end

"Assign job shifts to unemployed workers. Shifts are selected at random with 
higher weight for better shifts => workers with lower unemploymentIndex (older,
higher class) get better shifts."
function assignJobs!(hiredAgents, shiftsPool, month, pars)
    sort!(hiredAgents, by=x->x.unemploymentIndex)
    # TODO draw w/out replacement?
    shifts = rand(shiftsPool, length(hiredAgents))
    for person in hiredAgents
        if month == -1
            month = rand(1:12)
        end
        
        person.status = WorkStatus.worker
        person.newEntrant = false
        person.unemploymentMonths = 0
        person.monthHired = month
        person.wage = computeWage(person, pars)
        
        weights = cumsum(x.socialIndex for x in shifts) 
        shift_i = searchsortedfirst(weights, rand()*weights[end])
        shift = shifts[shift_i]
        
        person.jobShift = shift
        person.daysOff = [x for x in 1:8 if !(x in shift.days)]
        person.workingHours = pars.weeklyHours[person.careNeedLevel+1]
        person.jobSchedule = weeklySchedule(shift, person.workingHours)
        remove_unsorted!(shifts, shift_i)
    end
    
    nothing
end
