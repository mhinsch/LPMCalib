export Person, getHomeTown, getHomeTownName

import Spaces: GridSpace

"""
Specification of a Person Agent Type. This file is included in the module SocialAgents
Type Person to extend from AbstractAgent.
""" 
mutable struct Person <: AbstractAgent
    id
    """
    location of a parson's house in a map which implicitly  
    - (x-y coordinates of a house)
    - (town::Town, x-y location in the map)
    """ 
    pos::House     
    age::Int 
    # father
    # mother 
    # houseid 

    # Person(id,pos,age) = new(id,pos,age)

    function Person(pos::House,age)
        global IDCOUNTER = IDCOUNTER+1
        # @show IDCOUNTER
        new(IDCOUNTER,pos,age)
    end 
end

"Constructor with named arguments"
Person(pos;age=0) = Person(pos,age)

Person(;pos=undefinedTown,age=0) = Person(pos,age)

"stepping function for person"
function agent_step!(person::Person) 
   # person += Rational(1,12) or GlobalVariable.DT
end 

"home town of a person"
function getHomeTown(person::Person)
    getHomeTown(person.pos) 
end

"home town name of a person" 
function getHomeTownName(person::Person) 
    getProperty(getHomeTown(person),:name)
end

"set a new house to a person"
function setHouse(person::Person,house::House)
    person.pos = house
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