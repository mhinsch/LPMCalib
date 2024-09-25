module DependenciesIM
    

using Utilities
using DependenciesAM

export canLiveAlone, isOrphan, setAsGuardianDependent!, setAsProviderProvidee!
export setAsIndependent!, setAsSelfproviding!, resolveDependency!
export livesInSharedHouse, checkConsistencyDependents


"Whether the person shares their house with a non-dependent, non-guardian. Note that this includes spouses and spouses' children."
function livesInSharedHouse(person)
    for p in person.pos.occupants
        if p != person && ! (p in person.guardians) && ! (p in person.dependents)
            return true
        end
    end
    
    false
end

canLiveAlone(person) = person.age >= 18
isOrphan(person) = !canLiveAlone(person) && !isDependent(person)

function setAsGuardianDependent!(guardian, dependent)
    push!(guardian.dependents, dependent)
    push!(dependent.guardians, guardian)

    # set class rank to maximum of guardians'
    dependent.parentClassRank = maximum(x->x.classRank, dependent.guardians)
    nothing
end

function resolveDependency!(guardian, dependent)
    deps = guardian.dependents
    idx_d = findfirst(==(dependent), deps)
    if idx_d == nothing
        return
    end

    deleteat!(deps, idx_d)

    guards = dependent.guardians
    idx_g = findfirst(==(guardian), guards)
    if idx_g == nothing
        error("inconsistent dependency!")
    end
    deleteat!(guards, idx_g)
    nothing
end

"Dissolve all guardian-dependent relationships of `person`"
function setAsIndependent!(person)
    if !isDependent(person) 
        return
    end

    for g in person.guardians
        g_deps = g.dependents
        deleteat!(g_deps, findfirst(==(person), g_deps))
    end
    empty!(person.guardians)
    nothing
end

# check basic consistency, if there's an error on any of these 
# then something is seriously wrong
function checkConsistencyDependents(person)
    for guard in person.guardians
        @assert !isUndefined(guard) && guard.alive
        @assert person in guard.dependents
    end

    for dep in person.dependents
        @assert !isUndefined(dep)  
        @assert dep.age < 18
        @assert person.pos == dep.pos
        @assert person in dep.guardians
    end
end


function setAsProviderProvidee!(prov, providee)
    @assert isUndefined(providee.provider)
    @assert !(providee in prov.providees)
    push!(prov.providees, providee)
    providee.provider = prov
    nothing
end

function setAsSelfproviding!(person)
    if isUndefined(person.provider)
        return
    end

    provs = person.provider.providees
    deleteat!(provs, findfirst(==(person), provs))
    person.provider = undefined(person.provider)
    nothing
end

end
