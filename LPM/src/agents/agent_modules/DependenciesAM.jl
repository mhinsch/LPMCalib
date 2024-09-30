module DependenciesAM
    

using Utilities


export Dependency
export isDependent, hasDependents, hasProvidees


@kwdef struct Dependency{P}
    guardians :: Vector{P} = []
    dependents :: Vector{P} = []
    provider :: P = undefined(P)
    providees :: Vector{P} = []
end

isDependent(p) = !isempty(p.guardians)

hasDependents(p) = !isempty(p.dependents)

hasProvidees(p) = !isempty(p.providees)


end
