export marriage!, selectMarriage

using Utilities

ageClass(person) = trunc(Int, age(person)/10)


mutable struct MarriageCache{PERSON}
    shareMenNoChildren :: Vector{Float64}
    eligibleWomen :: Vector{PERSON}
    weights :: Vector{Float64}
end

MarriageCache{Person}() where {Person} = MarriageCache(Float64[], Person[], Float64[])

function marriagePreCalc!(model, pars)
    pc = model.marriageCache
    
    resize!(pc.shareMenNoChildren, 20)
    fill!(pc.shareMenNoChildren, 0.0)
    nAll = zeros(Int, 20)
    for p in Iterators.filter(isMale, model.pop)
        ac = ageClass(p)
        nAll[ac+1] += 1
        # only looks at legally dependent persons (which usually are underage and 
        # living in the same household)
        if !hasDependents(p)
            pc.shareMenNoChildren[ac+1] += 1
        end
    end
    pc.shareMenNoChildren ./= nAll
    
    empty!(pc.eligibleWomen)
    for f in model.pop 
        if isFemale(f) && isSingle(f) && age(f) > pars.minPregnancyAge
            push!(pc.eligibleWomen, f)
        end
    end
end


function ageFactor(agem, agew, pars)
    diff = Float64(agem - agew) - pars.modeAgeDiff
    diff > 0 ? 
        1/exp(pars.maleOlderFactor * diff^2) :
        1/exp(pars.maleYoungerFactor * diff^2)
end


function marryWeight(man, woman, pars)
    if livingTogether(man, woman) || related1stDegree(man, woman)
        return 0.0
    end
        
    geoFactor = 1/exp(pars.betaGeoExp * geoDistance(man, woman, pars))

    if status(woman) == WorkStatus.student 
        studentFactor = pars.studentFactorParam
        womanRank = parentClassRank(woman)
    else
        studentFactor = 1.0
        womanRank = classRank(woman)
    end

    statusDistance = abs(classRank(man) - womanRank) / (length(pars.cumProbClasses) - 1)

    betaExponent = pars.betaSocExp * (classRank(man) < womanRank ? 1.0 : pars.rankGenderBias)

    socFactor = 1/exp(betaExponent * statusDistance)

    #ageFactor = pars.deltaAgeProb[deltaAge(age(man) - age(woman))]

    # legal dependents (i.e. usually underage persons living at the same house)
    numChildrenWithWoman = length(dependents(woman))

    childrenFactor = 1/exp(pars.bridesChildrenExp * numChildrenWithWoman)

    geoFactor * socFactor * ageFactor(age(man), age(woman), pars) * childrenFactor * studentFactor
end

geoDistance(m, w, pars) = manhattanDistance(getHomeTown(m), getHomeTown(w))/
    (pars.mapGridXDimension + pars.mapGridYDimension)

selectMarriage(p, pars) = alive(p) && isMale(p) && isSingle(p) && 
    age(p) > pars.ageOfAdulthood && careNeedLevel(p) < 4


function marriage!(man, time, model, pars)
    @assert alive(man)

    ageclass = ageClass(man) 

    manMarriageProb = ageclass > length(pars.maleMarriageModifierByDecade) ? 
        0.0 : pars.basicMaleMarriageProb * pars.maleMarriageModifierByDecade[ageclass]

    if status(man) != WorkStatus.worker || careNeedLevel(man) > 1
        manMarriageProb *= pars.notWorkingMarriageBias
    end

    snc = model.marriageCache.shareMenNoChildren[ageclass+1]
    den = snc + (1-snc) * pars.manWithChildrenBias

    prob = manMarriageProb / den * (hasDependents(man) ? pars.manWithChildrenBias : 1)

    if rand() >= p_yearly2monthly(limit(0.0, prob, 1.0)) 
        return nothing
    end

    # get cached list
    # note: this is getting updated as we go
    women = model.marriageCache.eligibleWomen
    if isempty(women)
        return nothing
    end
    
    # keep array across fun calls
    weights = model.marriageCache.weights
    resize!(weights, length(women))
    sum = 0.0
    for (i,woman) in enumerate(women) 
        w = marryWeight(man, woman, pars)
        weights[i] = sum += w
    end
    
    if weights[end] == 0
        return nothing
    end
    
    r = rand() * weights[end]
    selected = searchsortedfirst(weights, r)
    @assert selected <= length(women)
    selectedWoman = women[selected]

    setAsPartners!(man, selectedWoman)
    # remove from cached list
    remove_unsorted!(women, selected)

    joinCouple!(man, selectedWoman, model, pars)

    dep_man = dependents(man)
    dep_woman = dependents(selectedWoman)
    # all dependents become joint dependents
    for child in dep_man
        setAsGuardianDependent!(selectedWoman, child)
    end
    for child in dep_woman
        setAsGuardianDependent!(man, child)
    end

    nothing
end


# for now simply all dependents
function gatherDependentsSingle(person)
    assumption() do
        for p in dependents(person)
            @assert p.pos == person.pos
            @assert length(guardians(p)) == 1
            @assert guardians(p)[1] == person
        end
    end

    dependents(person)
end

    
function joinCouple!(man, woman, model, pars)
    # they stay apart
    if rand() >= pars.probApartWillMoveTogether
        return false
    end

    # decide who leads the move
    peopleToMove = rand()<0.5 ? [man, woman] : [woman, man]

    append!(peopleToMove, gatherDependentsSingle(man), gatherDependentsSingle(woman))

    if rand() < pars.couplesMoveToExistingHousehold
        targetHouse = nOccupants(man.pos) > nOccupants(woman.pos) ? 
            woman.pos : man.pos

        movePeopleToHouse!(targetHouse, peopleToMove)
    else
        distance = rand([:here, :near])
        movePeopleToEmptyHouse!(peopleToMove, distance, model.houses, model.towns)
    end

    # TODO movedThisYear
    # required by moving around (I think)
    
    true
end
