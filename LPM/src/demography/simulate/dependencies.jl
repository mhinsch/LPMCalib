export selectAssignGuardian, assignGuardian!, findFamilyGuardian, findOtherGuardian


function hasValidGuardian(person)
    for g in guardians(person)
        if alive(g)
            return true
        end
    end

    false
end


selectAssignGuardian(person) = alive(person) && !canLiveAlone(person) && 
    !hasValidGuardian(person)


function assignGuardian!(person, time, model, pars)
    guard = findFamilyGuardian(person)
    if isUndefined(guard) 
        guard = findOtherGuardian(person, model.pop, pars)
    end

    # get rid of previous (possibly dead) guardians
    # this implies that relatives of a non-related former legal guardian
    # that are now excluded due to age won't get a chance again in the future
    empty!(guardians(person))

    if isUndefined(guard) 
        return false
    end

    # guard and partner become new guardians
    adopt!(guard, person)

    true
end
    
function findFamilyGuardian(person)
    potGuardians = Vector{Union{Person, Nothing}}()

    pparents = parents(person)
    # these might be nonexistent or dead
    append!(potGuardians, pparents)

    # these can but don't have to be identical to the parents
    for g in guardians(person)
        push!(potGuardians, partner(g))
    end

    # relatives of biological parents
    # any of these might already be guardians, but in that case they will be dead
    for p in pparents
        if isUndefined(p) 
            continue
        end
        append!(potGuardians, parents(p))
        append!(potGuardians, siblings(p))
    end
    
    # possible overlap with previous, but doesn't matter
    for g in guardians(person)
        append!(potGuardians, parents(g))
        append!(potGuardians, siblings(g))
    end

    # potentially lots of redundancy, but just take the first 
    # candidate that works
    for g in potGuardians
        if isUndefined(g) || !alive(g) || age(g) < 18 
            continue
        end
        return g
    end

    return undefinedPerson
end

function findOtherGuardian(person, people, pars)
    candidates = [ p for p in people if 
        isFemale(p) && canLiveAlone(p) && !isSingle(p) && 
            (status(p) == WorkStatus.worker || status(partner(p)) == WorkStatus.worker) ]

    if length(candidates) > 0
        return rand(candidates)
    end

    return undefinedPerson
end


function adopt!(guard, person)
    movePeopleToHouse!([person], guard.pos)
    setAsGuardianDependent!(guard, person)
    if ! isSingle(guard)
        setAsGuardianDependent!(partner(guard), person)
    end
end
