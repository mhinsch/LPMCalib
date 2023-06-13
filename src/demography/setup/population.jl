
# return agents with age in interval minAge, maxAge
# assumes pop is sorted by age
# very simple implementation, binary search would be faster
function ageInterval(pop, minAge, maxAge)
    idx_start = 1
    idx_end = 0

    for p in pop
        if age(p) < minAge
            # not there yet
            idx_start += 1
            continue
        end

        if age(p) > maxAge
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
            if age(man)+2 >= age(woman) >= age(man)-5
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
        isFemale(p) && age(p) >= 18
    end

    # sort by age so that we can easily get age intervals
    sort!(women, by = age)

    for p in population
        a = age(p)
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
        @assert age(women[start]) >= a+18

        mother = women[rand(start:stop)]
        
        setAsParentChild!(p, mother)
        if !isSingle(mother)
            setAsParentChild!(p, partner(mother))
        end

        if age(p) < 18
            setAsGuardianDependent!(mother, p)
            if !isSingle(mother) # currently not an option
                setAsGuardianDependent!(partner(mother), p)
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
    classRank!(person, class)

    nothing
end


function initWork!(person, pars)
    if age(person) < pars.ageTeenagers
        status!(person, WorkStatus.child)
        return
    end
    if age(person) < pars.ageOfAdulthood
        status!(person, WorkStatus.teenager)
        return
    end
    if age(person) >= pars.ageOfRetirement
        status!(person, WorkStatus.retired)
        return
    end

    class = classRank(person)+1

    if age(person) < pars.workingAge[class]
        status!(person, WorkStatus.student)
        return
    end

    status!(person, WorkStatus.worker)

    workingTime = 0
    for i in pars.workingAge[class]:floor(Int, age(person))
        workingTime *= pars.workDiscountingTime
        workingTime += 1
    end

    workExperience!(person, workingTime)
    workingPeriods!(person, workingTime)

    dKi = rand(Normal(0, pars.wageVar))
    initialWage = pars.incomeInitialLevels[class] * exp(dKi)
    dKf = rand(Normal(dKi, pars.wageVar))
    finalWage = pars.incomeFinalLevels[class] * exp(dKf)

    initialIncome!(person, initialWage)
    finalIncome!(person, finalWage)

    wage!(person, computeWage(person, pars))
    income!(person, wage(person) * pars.weeklyHours[careNeedLevel(person)+1])
    potentialIncome!(person, income(person))
    jobTenure!(person, rand(1:50))

    nothing
end
