export Person, getHomeTown, getHomeTownName, agestep!, isFemale, isMale

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
    age::Int             # Rational 
    # birthYear::Int        
    # birthMonth::Int
    gender 
    father::Union{Person,Nothing}
    mother::Union{Person,Nothing} 
    partner::Union{Person,Nothing}
    childern::Vector{Person}
    # self.yearMarried = []
    # self.yearDivorced = []
    # self.deadYear = 0

    # Person(id,pos,age) = new(id,pos,age)

    function Person(pos::House,age,gender,father,mother,partner,childern)
        global IDCOUNTER = IDCOUNTER+1
        #person = 
        new(IDCOUNTER,pos,age,gender,father,mother,partner,childern)
        #pos != undefinedHouse ? push!(pos.occupants,person) : nothing 
        #person
    end 
end

Person(pos,age;birthYear=0,birthMonth=0,
                gender="undefined",
                father=nothing,mother=nothing,
                partner=nothing,childern=Person[]) = 
                    Person(pos,age,gender,father,mother,partner,childern)

Person(;pos=undefinedHouse,age=0,
        gender="undefined",
        father=nothing,mother=nothing,
        partner=nothing,childern=Person[]) = 
            Person(pos,age,gender,father,mother,partner,childern)


function isFemale(person::Person) 
    person.gender == "Female"
end

function isPerson(person::Person) 
    person.gender == "Male"
end 

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


