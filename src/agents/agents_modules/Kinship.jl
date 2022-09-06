module Kinship

using  SomeUtil: date2yearsmonths
using  BasicInfo: isFemale, isMale      # Otherwise, unit test for setAsParentChild! fails


export KinshipBlock
export father, mother, children
export setFather!, setMother!, setParent!, addChild!
export partner, isSingle, setPartner!


mutable struct KinshipBlock{P} 
  father::Union{P,Nothing}
  mother::Union{P,Nothing} 
  partner::Union{P,Nothing}
  children::Vector{P}
end 

"Default Constructor"
KinshipBlock{P}(;father=nothing,mother=nothing,partner=nothing,children=P[]) where {P} = 
      KinshipBlock(father,mother,partner,children)

father(child::KinshipBlock) = child.father
mother(child::KinshipBlock) = child.mother
children(person::KinshipBlock) = person.children

"set the father of child"
setFather!(child::KinshipBlock{P},father::P) where {P} = child.father = father
"set the mother of child"
setMother!(child::KinshipBlock{P},mother::P) where {P} = child.mother = mother

"set child of a parent" 
function setParent!(child::KinshipBlock{P},parent::P) where {P}
  if isFemale(parent) 
    setMother!(child,parent)
  elseif isMale(parent) 
    setFather!(child,parent)
  else
    throw(InvalidStateException("undefined case",:undefined))
  end
end 

addChild!(parent::KinshipBlock{P}, child::P) where{P} = push!(parent.children, child)

isSingle(person::KinshipBlock) = person.partner == nothing 

partner(person::KinshipBlock) = person.partner

"set a partnership"
function setPartner!(person1::KinshipBlock{P}, person2) where {P}
	person1.partner = person2
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


end # Kinship
