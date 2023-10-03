using StatsBase
using Distributions

function sampleNoReplace!(weights, wSum)
    r = rand() * wSum
    i = 1
    while  (r -= weights[i]) > 0  
        i += 1
    end
    
    wSum -= weights[i]
    weights[i] = 0.0
    
    i, wSum
end

function assignUnemploymentDuration!(unemployed, uRates, durationShares, pars)
    @assert sum(durationShares) <= 1
    totUnemployed = length(unemployed)
    if totUnemployed == 0
        return nothing
    end
    
    weights = map(unemployed) do x
            ur = uRates[x.classRank+1, ageBand(x.age)+1]
            1.0/exp(pars.unemploymentBeta * ur)
        end
    weightSum = sum(weights)
    
    for (durationIndex, durationShare) in enumerate(durationShares)
        numUnemployed = floor(Int, totUnemployed * durationShare)
        
        for i in 1:numUnemployed
            toAssignIdx, weightSum = sampleNoReplace!(weights, weightSum) 
            person = unemployed[toAssignIdx]
                    
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
    end
    
    for (i,w) in enumerate(weights)
        if w == 0
            unemployed[i].unemploymentDuration = 25
        end
    end

    nothing
end


function assignUnemploymentDurationByGender!(newEntrants, uRates, pars)
    assignUnemploymentDuration!(filter(isMale, newEntrants), uRates, pars.maleUDS, pars)
    assignUnemploymentDuration!(filter(isFemale, newEntrants), uRates, pars.femaleUDS, pars)
end


function dismissWorkers!(newUnemployed, uRates, pars)
    for person in newUnemployed
        person.status = WorkStatus.unemployed
        person.workingHours = 0
        person.income = 0
        person.jobTenure = 0
        person.monthHired = 0
        person.jobShift = EmptyShift
        person.jobSchedule = zeros(Bool, 7, 24)
        # commented in python version
        # person.weeklyTime = [[1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24]
    end
    
    assignUnemploymentDurationByGender!(newUnemployed, uRates, pars)
end

# TODO generalise, put elsewhere
canWork(person) = person.careNeedLevel < 4 && !isInMaternity(person) 

# Base.zero(::Type{Vector{T}}) where T = T[]
function Matrix{Vector{T}}(sz) where {T}
    m = Matrix{Vector{T}}(undef, sz)
    for c in 1:sz[1], a in 1:sz[2]
        m[c, a] = T[]
    end
    m
end

isActive(person) = (statusWorker(person) || statusUnemployed(person)) && canWork(person)
isWorking(person) = statusWorker(person) && canWork(person)
isUnemployed(person) = statusUnemployed(person) && canWork(person)

function jobMarket!(model, time, pars)
    year, month = date2yearsmonths(time)

    # everyone working or in the job market
    activePop = Iterators.filter(isActive, model.pop)
    # everyone with a job
    workingPop = Iterators.filter(isWorking, model.pop)
    # everyone looking for a job
    unemployed = Iterators.filter(isUnemployed, model.pop)
    
    # *** update tenure etc. for working population
    
    for person in workingPop
        person.jobTenure += 1
        if person.workingHours > 0
            person.workingPeriods += person.availableWorkingHours/person.workingHours
        end
        person.workExperience += person.availableWorkingHours/pars.weeklyHours[1]
        person.wage = computeWage(person, pars)
    end
    
    # *** count SES and age bands for active pop
    
    classShares, ageBandShares = calcAgeClassShares(activePop, pars)
    
    # *** unemployment rate and index
    
    unemploymentRate = model.unemploymentSeries[floor(Int, year - pars.startTime) + 1]
    uRates = computeURByClassAge(unemploymentRate, classShares, ageBandShares, pars)         
    
    # people entering the jobmarket need waiting time calculated 
    newEntrants = [x for x in unemployed if x.newEntrant]
    assignUnemploymentDurationByGender!(newEntrants, uRates, pars)
    
    # update times
    for person in unemployed
        person.unemploymentMonths += 1
        person.unemploymentDuration -= 1
    end
    
    PType = eltype(model.pop)
    # for some reason this is vastly slower
    #acActivePopM = zeros(Vector{PType}, size(ageBandShares))
    acActivePop = Matrix{Vector{PType}}(size(ageBandShares))
    
    for p in activePop
        push!(acActivePop[p.classRank+1, ageBand(p.age)+1], p)
    end
    
    adjustJobsByAgeAndClass!(acActivePop, uRates, unemploymentRate, month, model, pars)
end


function adjustJobsByAgeAndClass!(acActivePopM, uRates, unemploymentRate, month, 
    model, pars)
    PType = eltype(model.pop)
    actualUnemployed = PType[]
    employedWorkers = PType[]
    dismissedWorkers = PType[]
    weights = Float64[]
    for c in 0:size(acActivePopM)[1]-1, a in 0:size(acActivePopM)[2]-1
        acActivePop = acActivePopM[c+1, a+1]
        if isempty(acActivePop) continue end
            
        empty!(actualUnemployed)
        empty!(employedWorkers)
        for p in acActivePop
            if statusWorker(p)
                push!(employedWorkers, p)
            else
                push!(actualUnemployed, p)
            end
        end
        
        ageSES_ur = uRates[c+1, a+1]
        
        # *** regular job losses due to turnover
        
        if length(employedWorkers) > 0
            resize!(weights, length(employedWorkers))
            sumWeights = 0.0; nDismissable = 0
            for (i, p) in enumerate(employedWorkers)
                if p.jobTenure >= pars.probationPeriod
                    weights[i] = 1.0 / exp(pars.layOffsBeta * p.jobTenure) 
                    sumWeights += weights[i]
                    nDismissable += 1
                else
                    weights[i] = 0.0
                end
            end
            
            # layoffs happen at a constant rate that is modified by class/age-specific UR
            layOffsRate = pars.meanLayOffsRate * ageSES_ur/unemploymentRate
            numLayOffs = min(floor(Int, length(employedWorkers)*layOffsRate), nDismissable)
            empty!(dismissedWorkers)
                
            for i in 1:numLayOffs
                firedWorkerIdx, sumWeights = sampleNoReplace!(weights, sumWeights)
                push!(dismissedWorkers, employedWorkers[firedWorkerIdx])
                remove_unsorted!(employedWorkers, firedWorkerIdx)
                remove_unsorted!(weights, firedWorkerIdx)
            end
            dismissWorkers!(dismissedWorkers, uRates, pars)
            append!(actualUnemployed, dismissedWorkers)
        end
        
        # *** adjust unemployment rate to conform to empirical numbers
        
        nEmpiricalUnemployed = floor(Int, length(acActivePop) * ageSES_ur)
        if length(actualUnemployed) > nEmpiricalUnemployed
            peopleToHire = length(actualUnemployed) - nEmpiricalUnemployed
            # The probability to be hired is inversely proportional to unemployment duration.
            # Order workers from lower to higher duration, and hire from the top.
            sort!(actualUnemployed, by=x->x.unemploymentDuration)
            peopleHired = actualUnemployed[1:peopleToHire]
            assignJobs!(peopleHired, model.shiftsPool, month, pars)
        elseif nEmpiricalUnemployed > length(actualUnemployed)
            peopleToFire = min(nEmpiricalUnemployed-length(actualUnemployed),  length(employedWorkers))
            resize!(weights, length(employedWorkers))
            map!(weights, employedWorkers) do p 
                    1.0/exp(pars.layOffsBeta*p.jobTenure)
                end
            firedWorkers = sample(employedWorkers, Weights(weights), peopleToFire, replace=false)
            dismissWorkers!(firedWorkers, uRates, pars)
        end
    end
end    


function computePersonIncome!(person, pars)
    if statusWorker(person)
        if isInMaternity(person)
            maternityIncome = person.income
            if monthsSinceBirth(person) == 0
                person.wage = 0
                maternityIncome = pars.maternityLeaveIncomeReduction * person.income
            elseif monthsSinceBirth(person) > 2
                maternityIncome = min(pars.minStatutoryMaternityPay, maternityIncome)
            end
            person.income = maternityIncome
        else
            person.income = person.wage * person.availableWorkingHours
            person.lastIncome = person.wage * pars.weeklyHours[person.careNeedLevel]
        end
        # Detract taxes and 
    elseif statusRetired(person)
        person.income = person.pension
    else
        person.income = 0
    end
    
    push!(person.yearlyIncomes, person.income * 4.35)
    if length(person.yearlyIncomes) > 12
        deleteat!(person.yearlyIncomes, 1)
    end
    person.yearlyIncome = sum(person.yearlyIncomes)
    
    @assert person.yearlyIncome >= 0
        
    person.disposableIncome = person.income
end


function computeIncome!(model, month, pars)
    # Compute income from work based on last period job market and informal care
    for person in model.pop
        computePersonIncome!(person, pars)
    end

    for house in model.houses
        if isEmpty(house)
            continue
        end
        
        if month == 1
            house.yearlyIncome = 0
            house.yearlyDisposableIncome = 0
            house.yearlyBenefits = 0
        end
        house.householdIncome = sum(x->income(x), house.occupants)
        house.incomePerCapita = householdIncome(house)/length(house.occupants)
        house.yearlyIncome += (house.householdIncome*52.0)/12
    end
        

    # Now, compute disposable income (i..e after taxes and benefits)
    # First, reduce by tax
    earningPeople = Iterators.filter(x->income(x)>0, model.pop)
    totalTaxRevenue = 0
    totalPensionRevenue = 0
    for person in earningPeople
        employeePensionContribution = 0
        # Pension Contributions
        if disposableIncome(person) > 162.0
            if disposableIncome(person) < 893.0
                employeePensionContribution = (disposableIncome(person) - 162.0) * 0.12
            else
                employeePensionContribution = (893.0 - 162.0) * 0.12
                employeePensionContribution += (disposableIncome(person) - 893.0) * 0.02
            end
        end
        person.disposableIncome -= employeePensionContribution
        totalPensionRevenue += employeePensionContribution
        
        # Tax Revenues
        tax = 0
        residualIncome = disposableIncome(person)
        for (i, taxb) in enumerate(pars.taxBrackets)
            if residualIncome > taxb
                taxable = residualIncome - taxb
                tax += taxable * pars.taxationRate[i]
                residualIncome -= taxable
            end
        end
        person.disposableIncome -= tax
        totalTaxRevenue += tax
    end
        
    push!(statePensionRevenue, totalPensionRevenue)
    push!(stateTaxRevenue, totalTaxRevenue)
    
    # ...then add benefits
    for person in model.pop
        person.disposableIncome = disposableIncome(person) + benefits(person)
        person.yearlyBenefits = benefits(person) * 52.0
        push!(yearlyDisposableIncomes(person), disposableIncome(person) * 4.35)
        if length(yearlyDisposableIncomes(person)) > 12
            deleteat!(person.yearlyDisposableIncomes, 1)
        end
        person.yearlyDisposableIncome = sum(yearlyDisposableIncomes(person))
        person.cumulativeIncome = cumulativeIncome(person) + disposableIncome(person)
    end
    
    for house in Iterators.filter(x->!isEmpty(x), model.houses)
        house.householdDisposableIncome = sum(x->disposableIncome(x), house.occupants)
        house.benefits = sum(x->benefits(x), house.occupants)
        house.yearlyDisposableIncome = householdDisposableIncome(house) * 52.0
        house.yearlyBenefits = benefits(house) * 52.0
        house.disposableIncomePerCapita = house.householdIncome/length(house.occupants)
    end
    
    
    # Then, from the household income subtract the cost of formal child and social care
    for house in Iterators.filter(x->!isEmpty(x), model.houses)
        house.householdNetIncome = house.householdDisposableIncome-house.costFormalCare
        house.netIncomePerCapita = house.householdNetIncome/float(len(house.occupants))
    end
    
    for house in Iterators.filter(x->!isempty(x), model.houses)
        house.totalIncome = sum(x->totalIncome(x), house.occupants)
        house.povertyLineIncome = 0
        independentMembers = filter(x->!isDependent(x), house.occupants)
        if length(independentMembers) == 1
            independentPerson = independentMembers[1]
            if independentPerson.status == WorkStatus.worker
                house.povertyLineIncome = pars.singleWorker
            elseif independentPerson.status == WorkStatus.retired
                house.povertyLineIncome = pars.singlePensioner
            end
        elseif length(independentMembers) == 2
            independentPerson_1 = independentMembers[1]
            independentPerson_2 = independentMembers[2]
            if independentPerson_1.status == WorkStatus.worker == independentPerson_2.status
                house.povertyLineIncome = pars.marriedCouple
            elseif (independentPerson_1.status == WorkStatus.retired && 
                    independentPerson_2.status == WorkStatus.worker) || 
                (independentPerson_2.status == WorkStatus.retired && 
                    independentPerson_1.status == WorkStatus.worker)
                house.povertyLineIncome = pars.mixedCouple
            elseif independentPerson_1.status == WorkStatus.retired == independentPerson_2.status
                house.povertyLineIncome = pars.couplePensioners
            end
        end
        nDependentMembers = count(isDependent, house.occupants)
        house.povertyLineIncome += nDependentMembers * pars.additionalChild
    end 
end
