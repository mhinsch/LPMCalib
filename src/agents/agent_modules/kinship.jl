using Utilities

export hasChildren, addChild!, isSingle, parents, siblings, nChildren, 
    nSiblings, areSiblings, areParentChild

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

parents(person) = (person.father, person.mother)

nChildren(person) = length(person.children)

areSiblings(person1, person2) = person1.father == person2.father != undefinedPerson || 
    person1.mother == person2.mother != undefinedPerson
    
areFullSiblings(person1, person2) = parents(person1) == parents(person2)    
    
areParentChild(person1, person2) = person1 in person2.children || person2 in person1.children


function nSiblings(person)
    full = 0
    half = 0
    
    pparents = parents(person)
    for s in siblings(person)
        if parents(s) == pparents
            full += 1
        else
            half += 1
        end
    end
    
    full, half
end


function siblings(person::P) where {P}
    sibs = P[]

    for p in parents(person)
        if isUndefined(p) continue end
        for c in p.children
            if c != person && !(c in sibs)
                push!(sibs, c)
            end
        end
    end

    sibs
end

