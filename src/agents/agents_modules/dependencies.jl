@kwdef struct Dependency{P}
    guardians :: Vector{P} = []
    dependents :: Vector{P} = []
    provider :: P = undefinedPerson#undefined(P)
    providees :: Vector{P} = []
end

isDependent(p) = !isempty(p.guardians)

hasDependents(p) = isempty(p.dependents)

hasProvidees(p) = isempty(p.providees)

