export KinshipBlock
export hasChildren, addChild!, isSingle 

mutable struct KinshipBlock{P} 
  father::Union{P,Nothing}
  mother::Union{P,Nothing} 
  partner::Union{P,Nothing}
  children::Vector{P}
end 

hasChildren(parent::KinshipBlock{P}) where{P} = length(parent.children) > 0

addChild!(parent::KinshipBlock{P}, child::P) where{P} = push!(parent.children, child)

isSingle(person::KinshipBlock) = person.partner == nothing 


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

