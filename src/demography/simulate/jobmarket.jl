struct Shift
    days :: Int
    start :: Int
    startIndex :: Int
    shiftHours :: Int
    finish :: Int
    socialIndex :: Int
end

Shift(days, hour, hourIndex, shiftHours, socInd) = 
    Shift(days, hour, hourIndex, shiftHours, hour+8, socInd)

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
    
    weeklySchedule = [zeros(24), zeros(24), zeros(24), zeros(24), zeros(24), zeros(24), zeros(24)]
    for day in shift.days
        for hour in shiftHours
            weeklySchedule[day][hour+1] = 1
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
    
    
function computeUR(ur, classShares, ageShares, classBias, ageBias, classGroup, ageGroup, pars)
    a = 0
    for i in 0:(length(pars.cumProbClasses)-1)
        a += classShares[i+1] * classBias^i
    end
    lowClassRate = ur/a
    classRate = lowClassRate * classBias^classGroup
    
    a = 0
    for i in 1:pars.numberAgeBands 
        a += ageShares[i] * ageBias[i]
    end
    
    lowerAgeBandRate = a>0 ? classRate/a : 0
        
    lowerAgeBandRate * ageBias[ageGroup]
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
    households = [h for h in houses if isOccupied(h)]
    for h in households
        householdCumulativeIncome!(h) = sum(x->cumulativeIncome(x), occupants(h))
    end
    sort!(households, by=householdCumulativeIncome)
    
    percLength = length(households) // 100
    wealthPercentilesPop = Vector{Vector{eltype(pop)}}()
    # TODO: reverse order correct?
    for i in 100:-1:1
        groupLims = (floor(Int, (i-1)*percLength)+1) : (floor(Int, i*percLength))
        push!(wealthPercentilesPop, households[groupLims])
    end
    
    for i in 1:100
        wealth_h = wealthPercentiles[i]
        for h in wealthPercentilesPop[i]:
            dK = randn(0, pars.wageVar)
            wealth!(household, wealth_h * exp(dK))
        end
    end
    
    # Assign household wealth to single members
    for h in households
        if householdCumulativeIncome(h) > 0
            for m in Iterators.filter(x->cumulativeIncome(x)>0, occupants(h))
                wealth!(m) = (cumulativeIncome(m)/householdCumulativeIncome(h)) * wealth(h)
            end
        else
            indMembers = [m for m in occupants(h) if x->independentStatus(x)==true]
            for m in indMembers
                wealth!(m, wealth(h)/length(indMembers))
            end
        end
    end
    
    nothing
end

function assignJobs!(hiredAgents, shiftsPool, month, pars)
    # Create a list of weekly shifts
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
        wage!(person, computeWage(person))
        
        weights = cumsum(x.socialIndex for x in shifts) 
        shift_i = searchsortedfirst(weights, rand()*weights[end])
        shift = shifts[shift_i]
        
        jobShift!(person, shift)
        daysOff!(person, [x for x in 1:8 if x not in shift.days])
        workingHours!(person, pars.weeklyHours][careNeedLevel(person)]
        jobSchedule!(person, weeklySchedule(shift, workingHours(person)))
        remove_unsorted!(shift, shift_i)
    end
    
    nothing
end

function createShifts(pars)
    allHours = zeros(Int, 24)
    f = 9000 / sum(pars.shiftsWeights)
    for (i, w) in enumerate(pars.shiftsWeights)
        allHours[i] = round(Int, w*f)
    end
    
    sumHours = sum(allHours)
    
    draw(ah, i) = (n=1; while (i-=ah[n])>0; n+= 1; end; n) 
    
    #=numShifts = [round(Int, x) for x in pars.shiftsWeights]
    hours = Int[]
    for num in numShifts, i in 1:num
        push!(hours, num)
    end
    allHours = rand(hours, 9000)=#
    
    allShifts = Vector{Shift}[]
    shifts = Vector{Int}[]
    for i in 1:1000
        hour = draw(allHours, rand(1:sumHours))
        allHours[hour] -= 1
        sumHours -= 1
        
        shift = [hour]
        
        while length(shift) < 8
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
        # pdb.set_trace()

    for shift in shifts:
        days = []
        weSocIndex = 0
        if np.random.random() < self.p['probSaturdayShift']:
            days.append(6)
            weSocIndex -= 1
        if np.random.random() < self.p['probSundayShift']:
            days.append(7)
            weSocIndex -= (1 + self.p['sundaySocialIndex'])
        if len(days) == 0:
            days = range(1, 6)
        elif len(days) == 1:
            days.extend(np.random.choice(range(1, 6), 4, replace=False))
        else:
            days.extend(np.random.choice(range(1, 6), 3, replace=False))
            
        startHour = (shift[0]+7)%24+1
        socIndex = np.exp(self.p['shiftBeta']*self.p['shiftsWeights'][shift[0]]+self.p['dayBeta']*weSocIndex)
        
        newShift = Shift(days, startHour, shift[0], shift, socIndex)
        allShifts.append(newShift)
    
    return allShifts

