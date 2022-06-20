"""
  A supertype for any agent of type Person. 

    Initial motivation is to resolve circular dependencies among 
    the agent types House and Person  
"""

using Global: Gender, unknown, female, male

export AbstractPersonAgent, isMale, isFemale
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