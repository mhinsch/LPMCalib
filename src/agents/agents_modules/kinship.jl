using Utilities

export hasChildren, addChild!, isSingle, parents, siblings, nChildren

@kwdef struct Kinship{P} 
  father::P = undefinedPerson#undefined(P)
  mother::P = undefinedPerson#undefined(P)
  partner::P = undefinedPerson#undefined(P)
  pTime :: Rational{Int} = 0//1
  children::Vector{P} = []
end 

hasChildren(parent) = length(parent.children) > 0

function addChild!(parent, child)
    push!(parent.children, child)
end

isSingle(person) = isUndefined(person.partner) 

parents(person) = [person.father, person.mother]

nChildren(person) = length(person.children)

function siblings(person::P) where {P}
    sibs = P[]

    for p in parents(person)
        if isUndefined(p) continue end
        for c in children(p)
            if c != person
                push!(sibs, c)
            end
        end
    end

    sibs
end

