#=
If the types within this file to be instantiated separately from the parent module
one may employ the following import 

import MyAgents: AbstractAgent
=# 
export Person
    

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