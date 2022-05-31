"""
  A supertype for any agent of type Person. 

    Initial motivation is to resolve circular dependencies among 
    the agent types House and Person  
"""

import Global: Gender, unknown, female, male

export AbstractPersonAgent, isMale, isFemale


abstract type AbstractPersonAgent <: AbstractSocialAgent end 


  function isFemale(person::AbstractPersonAgent) 
    person.gender == female
end

function isMale(person::AbstractPersonAgent) 
    person.gender == male
end 

