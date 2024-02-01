using Utilities

export hasChildren, addChild!, isSingle, parents, siblings, nChildren, 
    areSiblings, areParentChild

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

areSiblings(person1, person2) = person1.father == person2.father != undefinedPerson || 
    person1.mother == person2.mother != undefinedPerson
    
areParentChild(person1, person2) = person1 in person2.children || person2 in person1.children
    

function siblings(person::P) where {P}
    sibs = P[]

    for p in parents(person)
        if isUndefined(p) continue end
        for c in p.children
            if c != person
                push!(sibs, c)
            end
        end
    end

    sibs
end

