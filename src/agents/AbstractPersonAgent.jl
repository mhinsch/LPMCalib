"""
  A supertype for any agent of type Person. 

    Initial motivation is to resolve circular dependencies among 
    the agent types House and Person  
"""

using Global: Gender, unknown, female, male

export AbstractPersonAgent, Kinship
export isMale, isFemale
export getHomeTown, getHomeTownName, agestep!
export setFather!, setMother!, setParent!, setPartner! 


abstract type AbstractPersonAgent <: AbstractSocialAgent end 

# Interfaces / hard contract 

isFemale(::AbstractPersonAgent) = error("Not implemented")
isMale(::AbstractPersonAgent) = error("Not implemented")

"home town of a person"
getHomeTown(::AbstractPersonAgent) = error("Not implemented")
"home town name of a person" 
getHomeTownName(::AbstractPersonAgent) = error("Not implemented") 

# "set a new house to a person"
# setHouse(person::AbstractPersonAgent,house::House) = error("Not implemented") 
"set the father of child"
setFather!(child::AbstractPersonAgent,father::AbstractPersonAgent) = error("Not implemented") 
"set the mother of child"
setMother!(child::AbstractPersonAgent,mother::AbstractPersonAgent) = error("Not implemented")

"set child of a parent" 
function setParent!(child::AbstractPersonAgent,parent::AbstractPersonAgent) 
  if isFemale(parent) 
    setMother!(child,parent)
  elseif isMale(parent) 
    setFather!(child,parent)
  else
    throw(InvalidStateException("undefined case",:undefined))
  end
end 

"set a partnership"
setPartner!(::AbstractPersonAgent,::AbstractPersonAgent) = error("Not implemented") 


mutable struct Kinship # <: DynamicStruct 
  father::Union{AbstractPersonAgent,Nothing}
  mother::Union{AbstractPersonAgent,Nothing} 
  partner::Union{AbstractPersonAgent,Nothing}
  children::Vector{AbstractPersonAgent}
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
  year, month = age2yearsmonths(info.age)
  print(" $(year) years & $(month) months, $(info.gender) ")
  info.alive ? print(" alive ") : print(" dead ")  
end