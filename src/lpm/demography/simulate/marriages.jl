export resetCacheMarriages, marriage!


ageClass(person) = trunc(Int, age(person))


@memoize function shareMenNoChildren(model, ageclass)
    nAll = 0
    nNoC = 0

    for p in Iterators.filter(x->male(x) && ageClass(x) == ageclass, model.pop)
        nAll += 1
        if !hasChildrenAtHome(p)
            nNoC += 1
        end
    end

    nNoC / nAll
end


@memoize eligibleWomen(model, pars) = [f for f in model.pop if female(f) && 
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


function marryWeight(man, woman, pars)
    geoFactor = 1/exp(pars.betaGeoExp * geoDistance(man, woman, pars))

    if status(woman) == student 
        studentFactor = pars.studentFactorParam
        womanRank = maxParentRank(woman)
    else
        studentFactor = 1.0
        womanRank = classRank(woman)
    end

    statusDistance = abs(classRank(man) - womanRank) / (pars.numberClasses - 1)

    betaExponent = pars.betaSocExp * (classRank(man) < womanRank ? 1.0 : pars.rankGenderBias)

    socFactor = 1/exp(betaExponent * statusDistance)

    ageFactor = pars.deltageProb[deltaAge(age(man) - age(woman))]

    numChildrenWithWoman = count(x->house(x) == house(woman), children(woman))

    childrenFactor = 1/exp(pars.bridesChildrenExp * numChildrenWithWoman)

    geoFactor * socFactor * ageFactor * childrenFactor * studentFactor
end


# TODO pars
function marriage!(man, time, model, pars, verbose)
    ageclass = ageClass(person) 

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
    candidates = [i for enumerate(i,w) in women if (age(man)-10 < age(w) < age(man)+5)  &&
                                                # exclude siblings as well
                          !cohabiting(man, w) && !related2(man, w) ]
    
    if length(candidates) == 0
        return nothing
    end

    weights = [marryWeight(man, women[idx], pars) for idx in candidates]

    cumsum!(weights)
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

    # TODO joinCouple
    joinCouple!(man, selectedWoman)

    nothing
end

function gatherDependents(person)
    if independent(person)
        # TODO dependents
        dependents(person)
    else
        # TODO bringTheKids
        bringTheKids(person)
    end
end
    
function joinCouple(man, woman, model, pars)
    # they stay apart
    if rand() >= pars.probApartWillMoveTogether
        return nothing
    end

    peopleToMove = [man, woman]

    append!(peopleToMove, gatherDependents(man), gatherDependents(woman))

    if rand() < pars.couplesMoveToExistingHousehold
        targetHouse = nOccupants(house(man)) > nOccupants(house(woman)) ? 
            house(woman) : house(man)

        movePeopleIntoChosenHouse(targetHouse, peopleToMove)
    else
        distance = rand(["here", "near"])
        findNewHouse(peopleToMove, distance)
    end

    # TODO independent status
end
