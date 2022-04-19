#=
If the types within this file to be instantiated separately from the parent module
one may employ the following import 

import AgentTypes: AbstractAgent, Agent, DataSpec
=# 
export Person, PersonData
    
"Fields specification of a Person agent"
mutable struct PersonData <: DataSpec
#   father 
#   mother 
    age 
#   ..
end

"Agent person" 
const Person = Agent{PersonData}  

# TODO 
#      implement getAge() attribute function 
#      implement step! function 
# or 
#      adjust the implementation 
 
"Default constructor"
Person() = Person(nothing)

  