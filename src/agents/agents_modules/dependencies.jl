export DependencyBlock


mutable struct DependencyBlock{P}
    guardians :: Vector{P}
    dependents :: Vector{P}
    provider :: Union{P, nothing}
    providees :: Vector{P}
end

DependencyBlock{P}() where {P} = DependencyBlock{P}([], [], nothing, [])

isDependent(p) = !isempty(p.guardians)

hasDependents(p) = isempty(p.dependents)

hasProvidees(p) = isempty(p.providees)

