export Person, getHomeTown, getHomeTownName, agestep!

import Spaces: GridSpace

"""
Specification of a Person Agent Type. 

This file is included in the module SocialAgents

Type Person extends from AbstractAgent.
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
    # partner

    # Person(id,pos,age) = new(id,pos,age)

    function Person(pos::House,age)
        global IDCOUNTER = IDCOUNTER+1
        new(IDCOUNTER,pos,age)
    end 
end

"Constructor with named arguments"
Person(pos;age=0) = Person(pos,age)

Person(;pos=undefinedTown,age=0) = Person(pos,age)

"increment an age for a person to be used in typical stepping functions"
function agestep!(person::Person;dt=1) 
   # person += Rational(1,12) or GlobalVariable.DT
   person.age += dt 
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


