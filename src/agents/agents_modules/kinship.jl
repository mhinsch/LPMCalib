export KinshipBlock
export hasChildren, addChild!, isSingle, parents, siblings, nChildren

mutable struct KinshipBlock{P} 
  father::Union{P,Nothing}
  mother::Union{P,Nothing} 
  partner::Union{P,Nothing}
  children::Vector{P}
end 

hasChildren(parent::KinshipBlock{P}) where{P} = length(parent.children) > 0

addChild!(parent::KinshipBlock{P}, child::P) where{P} = push!(parent.children, child)

isSingle(person::KinshipBlock) = person.partner == nothing 

parents(person::KinshipBlock) = [person.father, person.mother]

nChildren(person::KinshipBlock) = length(person.children)

function siblings(person::KinshipBlock{P}) where P
    sibs = P[]

    for p in parents(person)
        if p == nothing continue end
        for c in children(p)
            if c != person
                push!(sibs, c)
            end
        end
    end

    sibs
end

"costum @show method for Agent person"
function Base.show(io::IO, kinship::KinshipBlock)
  father = kinship.father; mother = kinship.mother; partner = kinship.partner; children = kinship.children;              
  father  == nothing        ? nothing : print(" , father    : $(father.id)") 
  mother  == nothing        ? nothing : print(" , mother    : $(mother.id)") 
  partner == nothing        ? nothing : print(" , partner   : $(partner.id)") 
  length(children) == 0      ? nothing : print(" , children  : ")
  for child in children
    print(" $(child.id) ") 
  end 
  println() 
end

