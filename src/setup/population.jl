
# return agents with age in interval minAge, maxAge
# assumes pop is sorted by age
# very simple implementation, binary search would be faster
function ageInterval(pop, minAge, maxAge)
    idx_start = 1
    idx_end = 0

    for p in pop
        if p.age < minAge
            # not there yet
            idx_start += 1
            continue
        end

        if p.age > maxAge
            # we reached the end of the interval, return what we have
            return idx_start, idx_end
        end

        idx_end += 1
    end

    idx_start, idx_end
end

function randAge(pyramid, gender)
    data = pyramid[gender == male ? 1 : 2]
    r = rand() * data[end]
    i = searchsortedfirst(data, r)
    mi = (i-1) * 5 * 12 # we are working in months
    ma = i * 5 * 12 - 1
    rand(mi:ma) // 12
end


function createPyramidPopulation(pars, pyramid)
    population = Person[]
    men = Person[]
    women = Person[]

    # age pyramid
    #dist = TriangularDist(0, pars.maxStartAge * 12, 0)

    for i in 1:pars.initialPop
        # surplus of babies and toddlers, lower bit of age pyramid
        #if i < pars.startBabySurplus
        #    age = rand(1:36) // 12
        #else
        #    age = floor(Int, rand(dist)) // 12
        #end
        
        gender = rand() < pars.initialPMales ? male : female
        age = randAge(pyramid, gender)

        person = Person(;age, gender)
        if age < 18
            push!(population, person)
        else
            push!((gender==male ? men : women), person)
        end
    end

###  assign partners

    nCouples = floor(Int, pars.startProbMarried * length(men))
    for i in 1:nCouples
        man = men[1]
        # find woman of the right age
        for (j, woman) in enumerate(women)
            if man.age+2 >= woman.age >= man.age-5
                setAsPartners!(man, woman)
                push!(population, man)
                push!(population, woman)
                remove_unsorted!(men, 1)
                remove_unsorted!(women, j)
                break
            end
        end
    end

    # store unmarried people in population as well
    append!(population, men)
    append!(population, women)

### assign parents

    # get all adult women
    women = filter(population) do p
        isFemale(p) && p.age >= 18
    end

    # sort by age so that we can easily get age intervals
    sort!(women, by = x->x.age)

    for p in population
        a = p.age
        # adults remain orphans with a certain likelihood
        if a >= 18 && rand() < pars.startProbOrphan * a
            continue
        end

        # get all women that are between 18 and 40 years older than 
        # p (and could thus be their mother)
        start, stop = ageInterval(women, a + 18, a + 40)
        # check if we actually found any
        if start > length(women) || start > stop
            continue
        end

        @assert typeof(start) == Int
        @assert women[start].age >= a+18

        mother = women[rand(start:stop)]
        
        setAsParentChild!(p, mother)
        if !isSingle(mother)
            setAsParentChild!(p, mother.partner)
        end

        if p.age < 18
            setAsGuardianDependent!(mother, p)
            if !isSingle(mother) # currently not an option
                setAsGuardianDependent!(mother.partner, p)
            end
            setAsProviderProvidee!(mother, p)
        end
    end

    @assert length(population) == pars.initialPop 

    population
end


function createUniformPopulation(pars) 
    population = Person[] 

    for i in 1 : pars.initialPop
        ageMale = rand(pars.minStartAge:pars.maxStartAge)
        ageFemale = ageMale - rand(-2:5)
        ageFemale = ageFemale < 24 ? 24 : ageFemale
        
        rageMale = ageMale + rand(0:11) // 12     
        rageFemale = ageFemale + rand(0:11) // 12 

        # From the old code: 
        #    the following is direct translation but it does not ok 
        #    birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        #    why not 
        #    birthYear = properties[:startYear]  - ageMale/Female 
        #    birthMonth = rand((1:12))

        newMan = Person(age=rageMale, gender=male)
        newWoman = Person(age=rageFemale, gender=female)   
        setAsPartners!(newMan,newWoman) 
        
        push!(population,newMan);  push!(population,newWoman) 

    end # for 

    population

end # createUniformPopulation 


function initClass!(person, pars)
    p = rand()
    class = searchsortedfirst(pars.cumProbClasses, p)-1
    person.classRank = class

    nothing
end


function initWork!(person, pars)
    if person.age < pars.ageTeenagers
        person.status = WorkStatus.child
        return
    end
    if person.age < pars.ageOfAdulthood
        person.status = WorkStatus.teenager
        return
    end
    if person.age >= pars.ageOfRetirement
        person.status = WorkStatus.retired
        return
    end

    class = person.classRank+1

    if person.age < pars.startWorkingAge[class]
        person.status = WorkStatus.student
        return
    end

    person.status = WorkStatus.worker

    workingTime = 0
    for i in pars.startWorkingAge[class]:floor(Int, person.age)
        workingTime *= pars.workDiscountingTime
        workingTime += 1
    end

    person.workExperience = workingTime
    person.workingPeriods = workingTime
    
    setWageProgression!(person, pars)

    person.wage = computeWage(person, pars)
    person.income = person.wage * pars.weeklyHours[person.careNeedLevel+1]
    person.jobTenure = rand(1:50)

    nothing
end


function createShifts(pars)
    f = 9000 / sum(pars.shiftsWeights)
    # distribute 9000 according to shift weight
    allHours = [ round(Int, f * w) for w in pars.shiftsWeights ]
    
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
        
        # TODO why +7? currently not used
        startHour = (shift[1]+7)%24+1
        socIndex = exp(pars.shiftBeta * pars.shiftsWeights[shift[1]] + pars.dayBeta * weSocIndex)
        
        newShift = Shift(days, startHour, shift[1], shift, socIndex)
        push!(allShifts, newShift)
    end
    
    allShifts
end


function initWealth!(houses, wealthPercentiles, pars)
    households = [h for h in houses if !isEmpty(h)]
    for h in households
        h.cumulativeIncome = sum(x->x.cumulativeIncome, h.occupants)
    end
    
    assignWealthByIncPercentile!(households, wealthPercentiles, pars)
        
    # Assign household wealth to single members
    for h in households
        if h.cumulativeIncome > 0
            for m in Iterators.filter(x->x.cumulativeIncome>0, h.occupants)
                m.wealth = m.cumulativeIncome/h.cumulativeIncome * h.wealth
            end
        else
            indMembers = [m for m in h.occupants if !isDependent(m)]
            for m in indMembers
                m.wealth = h.wealth/length(indMembers)
            end
        end
    end
    
    nothing
end


function initJobs!(model, pars)
    hiredPeople = [p for p in model.pop if p.status == WorkStatus.worker]
    
    classShares, ageBandShares = calcAgeClassShares(hiredPeople, pars)
    
    unemploymentRate = model.unemploymentSeries[1]
    # not needed for now as assignJobs doesn't use unemploymentIndex anymore
    #uRates = computeURByClassAge(unemploymentRate, classShares, ageBandShares, pars)
    
    model.shiftsPool = createShifts(pars)
    assignJobs!(hiredPeople, model.shiftsPool, -1, pars)
    
    initWealth!(model.houses, model.wealthPercentiles, pars)
    
    nothing
end


function initCare!(model, pars)
    for person in model.pop
        # skip adolescents/adults that don't need care
        if person.age >= pars.stopChildCareAge && socialCareDemand(person, pars) <= 0
            continue
        end
        
        initCareTasks!(person, pars)
    end
end
