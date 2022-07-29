"""
  A supertype for any agent of type Person. 

    Initial motivation is to resolve circular dependencies among 
    the agent types House and Person  
"""

using SomeUtil: date2yearsmonths
using Utilities: Gender, unknown, female, male

export AbstractPerson, Kinship
export isMale, isFemale
export getHomeTown, getHomeTownName, agestep!
export setFather!, setMother!, setParent!, setPartner!, agestepAlivePerson!

abstract type AbstractPerson <: AbstractXAgent end 

# Interfaces / hard contract 
isFemale(::AbstractPerson) = error("Not implemented")
isMale(::AbstractPerson) = error("Not implemented")

"home town of a person"
getHomeTown(::AbstractPerson) = error("Not implemented")
"home town name of a person" 
getHomeTownName(::AbstractPerson) = error("Not implemented") 

"set the father of child"
setFather!(child::AbstractPerson,father::AbstractPerson) = error("Not implemented") 
"set the mother of child"
setMother!(child::AbstractPerson,mother::AbstractPerson) = error("Not implemented")

agestepAlivePerson!(::AbstractPerson;dt) = error("not implemented") 

"set child of a parent" 
function setParent!(child::AbstractPerson,parent::AbstractPerson) 
  if isFemale(parent) 
    setMother!(child,parent)
  elseif isMale(parent) 
    setFather!(child,parent)
  else
    throw(InvalidStateException("undefined case",:undefined))
  end
end 

"set a partnership"
setPartner!(::AbstractPerson,::AbstractPerson) = error("Not implemented") 


mutable struct Kinship{P <: AbstractPerson} # <: DynamicStruct 
  father::Union{P,Nothing}
  mother::Union{P,Nothing} 
  partner::Union{P,Nothing}
  children::Vector{P}
end 

"Default Constructor"
Kinship(;father=nothing,mother=nothing,partner=nothing,children=Person[]) = 
      Kinship(father,mother,partner,children)


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
        

mutable struct BasicInfo
  age::Rational 
  # (birthyear, birthmonth)
  gender::Gender  
  alive::Bool 
  # (deathyear, deathmonth)
end

"Default constructor"
BasicInfo(;age=0//1, gender=unknown, alive = true) = BasicInfo(age,gender,alive)

"costum @show method for Agent person"
function Base.show(io::IO,  info::BasicInfo)
  year, month = date2yearsmonths(info.age)
  print(" $(year) years & $(month) months, $(info.gender) ")
  info.alive ? print(" alive ") : print(" dead ")  
end