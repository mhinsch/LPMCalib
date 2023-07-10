
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
    
    weeklySchedule = zeros(Int, 7, 24)#[zeros(24), zeros(24), zeros(24), zeros(24), zeros(24), zeros(24), zeros(24)]
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
        push!(wealthPercentilesPop, earningsPop[groupLims])
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
            financialWealth!(person, max(0, financialWealth(person) - wealthSpentOnCare(person)))
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


function jobMarket(model, year, month, pars)
    self.hiredPeople = []
    self.newUnemployed = []
    
    PType = eltype(model.pop)
    
    activePop = PType[]
    unemployedNotInActive = PType[]
    workingPop = PType[]
    
    for p in model.pop 
        if (status(p) in (WorkStatus.worker, WorkStatus.unemployed)) && 
            careNeedLevel(p) < pars.numCareLevels && maternityStatus(p) == False
            push!(activePop, p)
            if status(p) == WorkStatus.worker
                push!(workingPop, p)
            end
        elseif status(p) == WorkStatus.unemployed
            push!(unemployedNotInActive, p)
        end
    end
    
# commented in python version:
#        workingPop = [x for x in activePop if x.status == 'worker']
#        notChanged = [x for x in workingPop if x.jobTenure > self.p['minTenure']]
#        jobChangersNum = int(float(len(notChanged))*self.p['monthlyTurnOver'])
#        
#        weights = [np.exp(self.p['changeJobBeta']*(float(len(x.house.town.houses))*x.house.ownershipIndex*x.wage)) for x in notChanged]
#        probs = [x/sum(weights) for x in weights]
#        jobChangers = np.random.choice(workingPop, jobChangersNum, p = probs)
    
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
    
    unemploymentRate = model.unemployment_series[floor(Int, year - pars.startYear) + 1]
    
    # TODO fuse with classShares in social transition
    classShares = zeros(length(pars.cumProbClasses))
    for p in hiredPeople
        classShares[classRank(p)+1] += 1
    end
    
    ageBandShares = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    
    for p in hiredPeople
        ageBandShares[classRank(p)+1, ageBand(age(p))+1] += 1
    end
    
    # normalise ageBandShares by population per class
    for (i, cs) in enumerate(classShares)
        ageBandShares[i, :] ./= cs
    end
    # now we can make classShares relative to full population
    classShares /= sum(classShares)
    
    for person in activePop
        unemploymentIndex!(person, 
            computeUR(unemploymentRate, classShares, ageBandShares, 
                classRank(person), ageBand(age(person)), pars)
    end
    
    unemployed = filter(p->status(p) == WorkStatus.unemployed, activePop)
    newEntrants = filter(p->newEntrant(p), unemployed)
    
    assignUnemploymentDuration!(newEntrants)
    
    for person in unemployed
        unemploymentMonths!(person, unemploymentMonths(person) + 1)
        unemploymentDuration!(person, unemploymentDuration(person) - 1)
    end
    
    longTermUnemployed = filter(p->unemploymentMonths(p) >= 12, unemployed)
    longTermUnemploymentRate = length(longTermUnemployed)/length(activePop)
                
    for class in 1:size(ageBandShares)[2]
        for age in 1:size(ageBandShares)[1]
            agePop = filter(p->classRank(p) == class && ageBand(age(p)) == age, activePop)
            
            if length(agePop) <= 0
                continue
            end
            
            ageSES_ur = computeUR(unemploymentRate, classShares, ageBandShares, class, age, pars)
            workPop = filter(p->classRank(p) == class && ageBand(age(p)) == age, workingPop)
            
            if length(workPop) > 0
                # Age and SES-specific unemployment rate 
                layOffsRate = pars.meanLayOffsRate * ageSES_ur/unemploymentRate
                dismissableWorkers = filter(p->jobTenure(p) >= pars.probationPeriod, workPop)
                numLayOffs = min(floor(Int, length(workPop)*layOffsRate), 
                    length(dismissableWorkers))
                    
                if numLayOffs > 0
                    weights = [1.0/exp(pars.layOffsBeta*jobTenure(x)) for x in dismissableWorkers]
                    probs = [x/sum(weights) for x in weights]
                    firedWorkers = np.random.choice(dismissableWorkers, numLayOffs, replace = False, p = probs)
                    dismissWorkers!(firedWorkers, pars)
                end
            end
            
                    
            
            # agePop = [x for x in activePop if x.classRank == c and self.ageBand(x.age) == b]
            empiricalUnemployed = int(float(len(agePop))*ageSES_ur)
            actualUnemployed = [x for x in agePop if x.status == 'unemployed']
            employedWorkers = [x for x in agePop if x.status == 'worker']
            if len(actualUnemployed) > empiricalUnemployed:
                peopleToHire = len(actualUnemployed)-empiricalUnemployed
                # The probability to be hired is iversely proportional to unemployment duration.
                # Order workers from lower to higher duration, and hire from the top.
                actualUnemployed.sort(key=operator.attrgetter("unemploymentDuration"))
                peopleHired = actualUnemployed[:peopleToHire]
                self.assignJobs(peopleHired, month)
                
#                    weights = [1.0/np.exp(self.p['hiringBeta']*x.unemploymentDuration) for x in actualUnemployed]
#                    probs = [x/sum(weights) for x in weights]
#                    peopleHired = np.random.choice(actualUnemployed, peopleToHire, replace = False, p = probs)
                
                for person in peopleHired:
                    person.unemploymentIndex = ageSES_ur
                end
            
            elseif empiricalUnemployed > len(actualUnemployed):
                employedWorkers = [x for x in agePop if x.status == 'worker']
                peopleToFire = min(empiricalUnemployed-len(actualUnemployed), len(employedWorkers))
                weights = [1.0/np.exp(self.p['layOffsBeta']*x.jobTenure) for x in employedWorkers]
                probs = [x/sum(weights) for x in weights]
                firedWorkers = np.random.choice(employedWorkers, peopleToFire, replace = False, p = probs)
                self.dismissWorkers(firedWorkers)
                for person in firedWorkers:
                    person.unemploymentIndex = ageSES_ur
                end
            end
        end
    end
    
    # print 'Number hired people: ' + str(len(self.hiredPeople))
    unemployedPop = [x for x in self.pop.livingPeople if x.status == 'unemployed']
    # self.assignJobs(self.hiredPeople)
    
    tempJS = [0]*24
    for agent in self.hiredPeople:
        for i in range(7):
            if i+1 not in agent.daysOff:
                for j in range(24):
                    tempJS[j] += agent.jobSchedule[i][j]
                
    # hoursFrequencies = [x for x in self.aggregateSchedule]
    
    # self.dismissWorkers(self.newUnemployed)



