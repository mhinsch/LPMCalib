using StatsBase


"Set individual wealth (depending on income and care expenses)."
function updateWealth_Ind!(pop, wealthPercentiles, pars)
    # Only workers: retired are assigned a wealth at the end of their working life 
    # (which they consume thereafter)
    earningPop = [x for x in pop if x.cumulativeIncome > 0]
    
    sort!(earningPop, by=cumulativeIncome)
    percLength = length(earningPop) 
    # assign wealth (to people with income) according to income percentile
    for (i, agent) in enumerate(earningPop)
        percentile = floor(Int, (i-1)/percLength * 100) + 1
        dK = randn() * pars.wageVar
        person.wealth = wealthPercentiles[percentile] * exp(dK)
    end
    
    # calculate financial wealth from overall wealth
    # people without wage (== pensioners) only consume financial wealth
    for person in pop
        # Update financial wealth
        if person.wage > 0
            person.financialWealth = person.wealth * pars.shareFinancialWealth
        else
            # TODO add care expenses back in
            #person.financialWealth -= person.wealthSpentOnCare
        end
    end
    
    # passive income on wealth
    for person in Iterators.filter(x->x.cumulativeIncome>0 && x.wage==0, pop)
        person.financialWealth = financialWealth(person) * (1 + pars.pensionReturnRate)
    end
    
    nothing
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
    
    assignUnemploymentDuration!(newUnemployed, pars)
end

# TODO generalise, put elsewhere
canWork(person) = person.careNeedLevel < 4 && !isInMaternity(person) 

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
        person.jobTenure = person.jobTenure + 1
        if person.workingHours > 0
            person.workingPeriods = person.workingPeriods + 
                person.availableWorkingHours/person.workingHours
        end
        person.workExperience = person.workExperience + 
            person.availableWorkingHours/pars.weeklyHours[1]
        person.wage = computeWage(person, pars)
    end
    
    # *** count SES and age bands for active pop
    
    # TODO fuse with classShares in social transition?
    classShares = zeros(length(pars.cumProbClasses))
    for p in activePop
        classShares[p.classRank+1] += 1
    end
    
    ageBandShares = zeros(length(pars.cumProbClasses), pars.numberAgeBands)
    for p in activePop
        ageBandShares[p.classRank+1, ageBand(p.age)+1] += 1
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
        person.unemploymentIndex = computeUR(unemploymentRate, classShares, ageBandShares, 
                person.classRank, ageBand(person.age), pars)
    end
    
    # people entering the jobmarket need waiting time calculated 
    newEntrants = filter(x->x.newEntrant, unemployed)
    assignUnemploymentDuration!(newEntrants, pars)
    
    # update times
    for person in unemployed
        person.unemploymentMonths = person.unemploymentMonths + 1
        person.unemploymentDuration = person.unemploymentDuration - 1
    end
    
    longTermUnemployed = filter(p->p.unemploymentMonths >= 12, unemployed)
    longTermUnemploymentRate = length(longTermUnemployed)/length(activePop)
                
    for c in 1:size(ageBandShares)[2]
        for a in 1:size(ageBandShares)[1]
            agePop = filter(p->p.classRank == c && ageBand(p.age) == a, activePop)
            
            if length(agePop) <= 0
                continue
            end
            
            ageSES_ur = computeUR(unemploymentRate, classShares, ageBandShares, c, a, pars)
            workPop = filter(p->p.classRank == c && ageBand(p.age) == a, workingPop)
            
            # *** some people lose their jobs
            
            if length(workPop) > 0
                # Age and SES-specific unemployment rate 
                layOffsRate = pars.meanLayOffsRate * ageSES_ur/unemploymentRate
                dismissableWorkers = filter(p->p.jobTenure >= pars.probationPeriod, workPop)
                numLayOffs = min(floor(Int, length(workPop)*layOffsRate), 
                    length(dismissableWorkers))
                    
                if numLayOffs > 0
                    weights = [1.0/exp(pars.layOffsBeta*p.jobTenure) for p in dismissableWorkers]
                    firedWorkers = sample(dismissableWorkers, Weights(weights), numLayOffs, 
                        replace=false)
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
                sort!(actualUnemployed, by=x->x.unemploymentDuration)
                peopleHired = actualUnemployed[1:peopleToHire]
                assignJobs!(peopleHired, model.shiftsPool, month, pars)
                for person in peopleHired
                    person.unemploymentIndex = ageSES_ur
                end
            elseif nEmpiricalUnemployed > length(actualUnemployed)
                peopleToFire = min(nEmpiricalUnemployed-length(actualUnemployed), 
                    length(employedWorkers))
                weights = [1.0/exp(pars.layOffsBeta*p.jobTenure) for p in employedWorkers]
                firedWorkers = sample(employedWorkers, Weights(weights), peopleToFire, replace=false)
                dismissWorkers!(firedWorkers, pars)
                for person in firedWorkers
                    person.unemploymentIndex = ageSES_ur
                end
            end
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
        dependentMembers = [x for x in house.occupants if x.independentStatus == False]
        house.povertyLineIncome += len(dependentMembers) * pars.additionalChild
    end 
end
