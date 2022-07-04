
using MultiAgents.Util: date2yearsmonths

mutable struct Kinship{P} 
  father::Union{P,Nothing}
  mother::Union{P,Nothing} 
  partner::Union{P,Nothing}
  children::Vector{P}
end 

"Default Constructor"
Kinship(;father=nothing,mother=nothing,partner=nothing,children=[]) = 
      Kinship(father,mother,partner,children)

father(child) = child.father
mother(child) = child.mother

"set the father of child"
setFather!(child::Kinship{P},father::P) where {P} = child.father = father
"set the mother of child"
setMother!(child::Kinship{P},mother::P) where {P} = child.mother = mother

"set child of a parent" 
function setParent!(child::Kinship{P},parent::P) where {P}
  if isFemale(parent) 
    setMother!(child,parent)
  elseif isMale(parent) 
    setFather!(child,parent)
  else
    throw(InvalidStateException("undefined case",:undefined))
  end
end 

addChild!(parent::Kinship{P}, child::P) where{P} = push!(parent.children, child)

isSingle(person::Kinship) = person.partner == nothing 

partner(person::Kinship) = person.partner

"set a partnership"
function setPartner!(person1::Kinship{P}, person2::P) where {P}
	person1.partner = person2
end



"costum @show method for Agent person"
function Base.show(io::IO, kinship::Kinship)
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
