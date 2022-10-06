export resetCacheMarriages, marriage!, selectMarriage


ageClass(person) = trunc(Int, age(person)/10)


@memoize function shareMenNoChildren(model, ageclass)
    nAll = 0
    nNoC = 0

    for p in Iterators.filter(x->isMale(x) && ageClass(x) == ageclass, model.pop)
        nAll += 1
        if !hasChildrenAtHome(p)
            nNoC += 1
        end
    end

    nNoC / nAll
end


@memoize eligibleWomen(model, pars) = [f for f in model.pop if isFemale(f) && alive(f) &&
                                       isSingle(f) && age(f) > pars.minPregnancyAge]

# reset memoization caches
# needs to be done on every time step
function resetCacheMarriages()
    Memoization.empty_cache!(shareMenNoChildren)
    Memoization.empty_cache!(eligibleWomen)
end


function deltaAge(delta)
    if delta <= -10
        0
    elseif -10 < delta < -2
        1
    elseif -2 < delta < 1
        2
    elseif 1 < delta < 5
        3
    elseif 5 < delta < 10
        4
    else
        5
    end
end


function marryWeight(man, woman, pars)
    geoFactor = 1/exp(pars.betaGeoExp * geoDistance(man, woman, pars))

    if status(woman) == WorkStatus.student 
        studentFactor = pars.studentFactorParam
        womanRank = maxParentRank(woman)
    else
        studentFactor = 1.0
        womanRank = classRank(woman)
    end

    statusDistance = abs(classRank(man) - womanRank) / (length(pars.cumProbClasses) - 1)

    betaExponent = pars.betaSocExp * (classRank(man) < womanRank ? 1.0 : pars.rankGenderBias)

    socFactor = 1/exp(betaExponent * statusDistance)

    ageFactor = pars.deltaAgeProb[deltaAge(age(man) - age(woman))]

    numChildrenWithWoman = count(x->x.pos == woman.pos, children(woman))

    childrenFactor = 1/exp(pars.bridesChildrenExp * numChildrenWithWoman)

    geoFactor * socFactor * ageFactor * childrenFactor * studentFactor
end

geoDistance(m, w, pars) = manhattanDistance(getHomeTown(m), getHomeTown(w))/
    (pars.mapGridXDimension + pars.mapGridYDimension)

selectMarriage(p, pars) = isMale(p) && isSingle(p) && age(p) > pars.ageOfAdulthood &&
    careNeedLevel(p) < 4


function marriage!(man, time, model, pars)
    ageclass = ageClass(man) 

    manMarriageProb = pars.basicMaleMarriageProb * pars.maleMarriageModifierByDecade[ageclass]

    if status(man) != WorkStatus.worker || careNeedLevel(man) > 1
        manMarriageProb *= pars.notWorkingMarriageBias
    end

    snc = shareMenNoChildren(model, ageclass)
    den = snc + (1-snc) * pars.manWithChildrenBias

    prob = manMarriageProb / den * (hasChildrenAtHome(man) ? pars.manWithChildrenBias : 1)

    if rand() >= p_yearly2monthly(prob) 
        return nothing
    end

    women = eligibleWomen(model, pars)

    # we store candidates as indices, so that we can efficiently remove married women 
    candidates = [i for (i,w) in enumerate(women) if (age(man)-10 < age(w) < age(man)+5)  &&
                                                # exclude siblings as well
                          !livingTogether(man, w) && !related1stDegree(man, w) ]
    
    if length(candidates) == 0
        return nothing
    end

    weights = [marryWeight(man, women[idx], pars) for idx in candidates]

    cumsum!(weights, weights)
    if weights[end] == 0
        selected = rand(1:length(weights))
    else
        r = rand() * weights[end]
        selected = findfirst(>(r), weights)
        @assert selected != nothing
    end

    selectedIdx = candidates[selected]
    selectedWoman = women[selectedIdx]

    setAsPartners!(man, selectedWoman)
    remove_unsorted!(women, selectedIdx)

    joinCouple!(man, selectedWoman, model, pars)

    nothing
end

bringTheKids(person) = [ child for child in children(person) if 
                 !independent(child) && alive(child) && child.pos == person.pos ]


dependents(person) = [ p for p in person.pos.occupants if p != person ]


function gatherDependents(person)
    if independent(person)
        dependents(person)
    else
        bringTheKids(person)
    end
end

    
function joinCouple!(man, woman, model, pars)
    # they stay apart
    if rand() >= pars.probApartWillMoveTogether
        return false
    end

    # decide who leads the move
    peopleToMove = rand()<0.5 ? [man, woman] : [woman, man]

    append!(peopleToMove, gatherDependents(man), gatherDependents(woman))

    if rand() < pars.couplesMoveToExistingHousehold
        targetHouse = nOccupants(man.pos) > nOccupants(woman.pos) ? 
            woman.pos : man.pos

        movePeopleToHouse!(targetHouse, peopleToMove)
    else
        distance = rand([:here, :near])
        movePeopleToEmptyHouse!(peopleToMove, distance, model.houses, model.towns)
    end

    independent!(man, true)
    independent!(woman, true)

    # TODO movedThisYear
    # required by moving around (I think)
    
    true
end
