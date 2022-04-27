export Person
    

"""
Specification of a Person Agent Type. This file is included in the module SocialAgents
Type Person to extend from AbstractAgent.
""" 
mutable struct Person <: AbstractAgent
    id::Int
    pos             # could be a tuble of Town, location, house?
    age 
    # father
    # mother 
end

"Constructor with named arguments"
Person(id,pos;age=0) = Person(id,pos,age)


function agent_step!(person::Person) 
   # person += Rational(1,12) or GlobalVariable.DT
end 


#= 
Alternative approach

"Fields specification of a Person agent"
mutable struct PersonData <: DataSpec
#   father 
#   mother 
    age 
#   ..
end

"Agent person" 
const Person = Agent{PersonData}  
=#