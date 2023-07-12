using StatsBase

function weeklySchedule(shift, weeklyHours)
    dailyHours = floor(Int, weeklyHours/5)
    shiftHours = copy(shift.shiftHours)
    if dailyHours < length(shiftHours)
        if rand() < 0.5
            shiftHours = shift.shiftHours[1:4]
        else
            shiftHours = shift.shiftHours[4:end]
        end
    end
    
    weeklySchedule = zeros(Int, 7, 24)
    
    for day in shift.days
        for hour in shiftHours
            weeklySchedule[day, hour] = 1
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
    
    
function computeUR(ur, classShares, ageShares, classGroup, ageGroup, pars)
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
end


function updateWealth_Ind!(pop, wealthPercentiles, pars)
    # Only workers: retired are assigned a wealth at the end of their working life (which they consume thereafter)
    earningPop = [x for x in pop if cumulativeIncome(x) > 0]
    
    sort!(earningPop, by=cumulativeIncome)
    
    percLength = length(earningPop) // 100
    wealthPercentilesPop = Vector{Vector{eltype(pop)}}()
    # TODO: reverse order correct?
    for i in 100:-1:1
        groupLims = (floor(Int, (i-1)*percLength)+1) : (floor(Int, i*percLength))
        push!(wealthPercentilesPop, earningPop[groupLims])
    end
        
    for i in 1:100
        wealth_i = wealthPercentiles[i]
        for person in wealthPercentilesPop[i]
            dK = randn(0, pars.wageVar)
            wealth!(person) = wealth_i * exp(dK)
        end
    end
            
    for person in pop
        # Update financial wealth
        if wage(person) > 0
            financialWealth!(person, wealth(person) * pars.shareFinancialWealth)
        else
            # TODO add care expenses back in
            financialWealth!(person, max(0, financialWealth(person))) # - wealthSpentOnCare(person)))
        end
    end
    
    for person in Iterators.filter(x->cumulativeIncome(x)>0 && wage(x)==0, pop)
        financialWealth!(person, financialWealth(person) * (1 + pars.pensionReturnRate))
    end
    
    nothing
end

function updateWealth!(houses, wealthPercentiles, pars)
    households = [h for h in houses if !isEmpty(h)]
    for h in households
        cumulativeIncome!(h, sum(cumulativeIncome, h.occupants))
    end
    sort!(households, by=cumulativeIncome)
    
    percLength = length(households) // 100
    wealthPercentilesPop = Vector{Vector{eltype(houses)}}()
    # TODO: reverse order correct?
    for i in 100:-1:1
        groupLims = (floor(Int, (i-1)*percLength)+1) : (floor(Int, i*percLength))
        push!(wealthPercentilesPop, households[groupLims])
    end
    
    rdist = Normal(0.0, pars.wageVar)
    for i in 1:100
        wealth_h = wealthPercentiles[i]
        for h in wealthPercentilesPop[i]
            dK = rand(rdist)
            wealth!(h, wealth_h * exp(dK))
        end
    end
    
    # Assign household wealth to single members
    for h in households
        if cumulativeIncome(h) > 0
            for m in Iterators.filter(x->cumulativeIncome(x)>0, occupants(h))
                wealth!(m, cumulativeIncome(m)/cumulativeIncome(h) * wealth(h))
            end
        else
            indMembers = [m for m in h.occupants if !isDependent(m)]
            for m in indMembers
                wealth!(m, wealth(h)/length(indMembers))
            end
        end
    end
    
    nothing
end

function assignJobs!(hiredAgents, shiftsPool, month, pars)
    sort!(hiredAgents, by=unemploymentIndex)
    # TODO draw w/out replacement?
    shifts = rand(shiftsPool, length(hiredAgents))
    for person in hiredAgents
        if month == -1
            month = rand(1:12)
        end
        
        status(person) = WorkStatus.worker
        newEntrant!(person, false)
        unemploymentMonths!(person, 0)
        monthHired!(person, month)
        wage!(person, computeWage(person, pars))
        
        weights = cumsum(x.socialIndex for x in shifts) 
        shift_i = searchsortedfirst(weights, rand()*weights[end])
        shift = shifts[shift_i]
        
        jobShift!(person, shift)
        daysOff!(person, [x for x in 1:8 if !(x in shift.days)])
        workingHours!(person, pars.weeklyHours[careNeedLevel(person)+1])
        jobSchedule!(person, weeklySchedule(shift, workingHours(person)))
        remove_unsorted!(shifts, shift_i)
    end
    
    nothing
end

function createShifts(pars)
    allHours = zeros(Int, 24)
    # distribute 9000 according to shift weight
    f = 9000 / sum(pars.shiftsWeights)
    for (i, w) in enumerate(pars.shiftsWeights)
        allHours[i] = round(Int, w*f)
    end
    
    sumHours = sum(allHours)
    
    
    allShifts = Shift[]
    shifts = Vector{Int}[]
    for i in 1:1000
        # draw a random shift hour according to weight 
        hour = 1; i = rand(1:sumHours)
        while (i-=allHours[hour]) > 0; hour += 1; end 
        allHours[hour] -= 1
        sumHours -= 1
        
        shift = [hour]
        
        # extend shift hours in both directions according to weight until
        # 8 hours are reached or weights on both sides are 0
        while length(shift) < 8
            # hours before and after `hour` with wraparound
            nextHours = (23+shift[1]-1)%24 + 1, shift[end]%24 + 1
            
            weights = allHours[nextHours[1]], allHours[nextHours[2]]
            if sum(weights) == 0
                break
            end
            
            nextHour_i = Int(rand(1:sum(weights)) > weights[1]) + 1
            if nextHour_i == 1
                shift = [nextHours[nextHour_i]; shift]
            else
                push!(shift, nextHours[nextHour_i])
            end
            allHours[nextHours[nextHour_i]] -= 1
            sumHours -= 1
        end
        
        push!(shifts, shift)
    end

    for shift in shifts
        days = Int[]
        weSocIndex = 0
        if rand() < pars.probSaturdayShift
            push!(days, 6)
            weSocIndex -= 1
        end
        if rand() < pars.probSundayShift
            push!(days, 7)
            weSocIndex -= (1 + pars.sundaySocialIndex)
        end
        if length(days) == 0
            days = collect(1:6)
        elseif length(days) == 1
            append!(days, shuffle(1:6)[1:4])
        else
            append!(days, shuffle(1:6)[1:3])
        end
        
        startHour = (shift[1]+7)%24+1
        socIndex = exp(pars.shiftBeta * pars.shiftsWeights[shift[1]] + pars.dayBeta * weSocIndex)
        
        newShift = Shift(days, startHour, shift[1], shift, socIndex)
        push!(allShifts, newShift)
    end
    
    allShifts
end


function assignUnemploymentDuration!(newEntrants, pars)
    for i in (:male, :female)
        if i == :male
            durationShares = pars.maleUDS
            unemployed = filter(isMale, newEntrants)
        else
            durationShares = pars.femaleUDS
            unemployed = filter(isFemale, newEntrants)
        end
        totUnemployed = length(unemployed)
        
        durationIndex = 1
        for durationShare in durationShares
            numUnemployed = min(floor(Int, totUnemployed*durationShare), length(unemployed))
            if numUnemployed <= 0
                break
            end
            
            weights = cumsum(1.0/exp(pars.unemploymentBeta*x.unemploymentIndex) for x in unemployed)
            assignedUnemployed = [unemployed[searchsortedfirst(weights, rand()*weights[end])] 
                    for i in 1:numUnemployed]
                        
            for person in assignedUnemployed
                if durationIndex < 7
                    person.unemploymentDuration = durationIndex
                elseif durationIndex == 7
                    person.unemploymentDuration = rand(7:10)
                elseif durationIndex == 8
                    person.unemploymentDuration = rand(10:13)
                elseif durationIndex == 9
                    person.unemploymentDuration = rand(13:19)
                elseif durationIndex == 10
                    person.unemploymentDuration = rand(19:25)
                end
            end
            durationIndex += 1
            unemployed = [x for x in unemployed if !(x in assignedUnemployed)]
        end
        
        for person in unemployed
            person.unemploymentDuration = 25
        end
    end
    
    nothing
end


function dismissWorkers!(newUnemployed, pars)
    for person in newUnemployed
        status!(person, WorkStatus.unemployed)
        workingHours!(person, 0)
        income!(person, 0)
        jobTenure!(person, 0)
        monthHired!(person, 0)
        jobShift!(person, EmptyShift)
        jobSchedule!(person, zeros(Int, 7, 24))
        # commented in python version
        # person.weeklyTime = [[1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24]
    end
    
    assignUnemploymentDuration!(newUnemployed, pars)
end

# TODO generalise, put elsewhere
canWork(person) = careNeedLevel(person) < 4 && !isInMaternity(person) 

function jobMarket!(model, time, pars)
    
    year, month = date2yearsmonths(time)

    PType = eltype(model.pop)
    
    # everyone working or in the job market
    activePop = PType[]
    # everyone with a job
    workingPop = PType[]
    # everyone looking for a job
    unemployed = PType[]
    # unemployed but not looking for a job (maternity, care)
    unemployedNotInActive = PType[]
    
    # *** sort population by work status
    
    for p in model.pop 
        if (statusWorker(p) || statusUnemployed(p)) && canWork(p) == true
            
            push!(activePop, p)
            
            if statusWorker(p)
                push!(workingPop, p)
            else
                push!(unemployed, p)
            end
        elseif statusUnemployed(p)
            push!(unemployedNotInActive, p)
        end
    end
    
    # *** update tenure etc. for working population
    
    for person in workingPop
        jobTenure!(person, jobTenure(person) + 1)
        if workingHours(person) > 0
            workingPeriods!(person, workingPeriods(person) + 
                availableWorkingHours(person)/workingHours(person))
        end
        workExperience!(person, workExperience(person) + 
            availableWorkingHours(person)/pars.weeklyHours[1])
        wage!(person, computeWage(person, pars))
    end
    
    # *** count SES and age bands for active pop
    
    # TODO fuse with classShares in social transition?
    classShares = zeros(length(pars.cumProbClasses))
    for p in activePop
        classShares[classRank(p)+1] += 1
    end
    
    ageBandShares = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    for p in activePop
        ageBandShares[classRank(p)+1, ageBand(age(p))+1] += 1
    end
    
    # normalise ageBandShares by population per class
    for (i, cs) in enumerate(classShares)
        ageBandShares[i, :] ./= cs
    end
    # now we can make classShares relative to full population
    classShares /= sum(classShares)
    
    # *** unemployment rate and index
    
    unemploymentRate = model.unemploymentSeries[floor(Int, year - pars.startTime) + 1]
    for person in activePop
        unemploymentIndex!(person, 
            computeUR(unemploymentRate, classShares, ageBandShares, 
                classRank(person), ageBand(age(person)), pars))
    end
    
    # people entering the jobmarket need waiting time calculated 
    newEntrants = filter(newEntrant, unemployed)
    assignUnemploymentDuration!(newEntrants, pars)
    
    # update times
    for person in unemployed
        unemploymentMonths!(person, unemploymentMonths(person) + 1)
        unemploymentDuration!(person, unemploymentDuration(person) - 1)
    end
    
    longTermUnemployed = filter(p->unemploymentMonths(p) >= 12, unemployed)
    longTermUnemploymentRate = length(longTermUnemployed)/length(activePop)
                
    for c in 1:size(ageBandShares)[2]
        for a in 1:size(ageBandShares)[1]
            agePop = filter(p->classRank(p) == c && ageBand(age(p)) == a, activePop)
            
            if length(agePop) <= 0
                continue
            end
            
            ageSES_ur = computeUR(unemploymentRate, classShares, ageBandShares, c, a, pars)
            workPop = filter(p->classRank(p) == c && ageBand(age(p)) == a, workingPop)
            
            # *** some people lose their jobs
            
            if length(workPop) > 0
                # Age and SES-specific unemployment rate 
                layOffsRate = pars.meanLayOffsRate * ageSES_ur/unemploymentRate
                dismissableWorkers = filter(p->jobTenure(p) >= pars.probationPeriod, workPop)
                numLayOffs = min(floor(Int, length(workPop)*layOffsRate), 
                    length(dismissableWorkers))
                    
                if numLayOffs > 0
                    weights = [1.0/exp(pars.layOffsBeta*jobTenure(p)) for p in dismissableWorkers]
                    firedWorkers = sample(dismissableWorkers, Weights(weights), numLayOffs, replace=false)
                    dismissWorkers!(firedWorkers, pars)
                end
            end
            
            nEmpiricalUnemployed = floor(Int, length(agePop) * ageSES_ur)
            actualUnemployed = PType[]
            employedWorkers = PType[]
            for p in agePop
                if statusWorker(p)
                    push!(employedWorkers, p)
                else
                    push!(actualUnemployed, p)
                end
            end
            if length(actualUnemployed) > nEmpiricalUnemployed
                peopleToHire = length(actualUnemployed) - nEmpiricalUnemployed
                # The probability to be hired is iversely proportional to unemployment duration.
                # Order workers from lower to higher duration, and hire from the top.
                sort!(actualUnemployed, by=unemploymentDuration)
                peopleHired = actualUnemployed[1:peopleToHire]
                assignJobs!(peopleHired, model.shiftsPool, month, pars)
                for person in peopleHired
                    unemploymentIndex!(person, ageSES_ur)
                end
            elseif nEmpiricalUnemployed > length(actualUnemployed)
                peopleToFire = min(nEmpiricalUnemployed-length(actualUnemployed), 
                    length(employedWorkers))
                weights = [1.0/exp(pars.layOffsBeta*jobTenure(p)) for p in employedWorkers]
                firedWorkers = sample(employedWorkers, Weights(weights), peopleToFire, replace=false)
                dismissWorkers!(firedWorkers, pars)
                for person in firedWorkers
                    unemploymentIndex!(person, ageSES_ur)
                end
            end
        end
    end
end    

