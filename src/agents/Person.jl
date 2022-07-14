using TypedDelegation

# enable using/import from local directory
push!(LOAD_PATH, @__DIR__)

import KinshipM: Kinship, 
    isSingle, partner, father, mother, setParent!, addChild!, setPartner!
import BasicInfoM: BasicInfo, isFemale, isMale, age, agestep!, agestepAlive!, alive, setDead!

export Person
export PersonHouse, undefinedHouse
export isSingle, setHouse!, resolvePartnership!

#export Kinship
export isMale, isFemale, age
export getHomeTown, getHomeTownName, agestep!, agestepAlive!, alive, setDead!
export setAsParentChild!, setPartner!, setAsPartners!, partner 
export isFemale, isMale



"""
Specification of a Person Agent Type. 

This file is included in the module XAgents

Type Person extends from AbstractAgent.

Person ties various agent modules into one compound agent type.
""" 

# vvv More classification of attributes (Basic, Demography, Relatives, Economy )
mutable struct Person <: AbstractXAgent
    id
    """
    location of a parson's house in a map which implicitly  
    - (x-y coordinates of a house)
    - (town::Town, x-y location in the map)
    """ 
    pos::House{Person}
    info::BasicInfo     
    kinship::Kinship{Person}

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos, info, kinship)
        person = new(getIDCOUNTER(),pos,info,kinship)
        if !undefined(pos)
            addOccupant!(pos, person)
        end
        person  
    end 
end

# delegate functions to components

@delegate_onefield Person info [isFemale, isMale, age, agestep!, agestepAlive!, alive, setDead!]
@delegate_onefield Person kinship [isSingle, partner, father, mother, setParent!, addChild!, setPartner!]


"costum @show method for Agent person"
function Base.show(io::IO,  person::Person)
    print(person.info)
    undefined(person.pos) ? nothing : print(" @ House id : $(person.pos.id)") 
    print(person.kinship)
    println() 
end

#Base.show(io::IO, ::MIME"text/plain", person::Person) = Base.show(io,person)

"Constructor with default values"
Person(pos,age; gender=unknown,
                father=nothing,mother=nothing,
                partner=nothing,children=Person[]) = 
                    Person(pos,BasicInfo(;age, gender), 
                    Kinship(father,mother,partner,children))


"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,children=Person[]) = 
            Person(pos,BasicInfo(;age,gender), 
                       Kinship(father,mother,partner,children))

const PersonHouse = House{Person}
const undefinedHouse = PersonHouse((undefinedTown, (-1, -1)))

"home town of a person"
getHomeTown(person::Person) = getHomeTown(person.pos) 

"home town name of a person" 
function getHomeTownName(person::Person) 
    getHomeTown(person).name 
end

"associate a house to a person"
function setHouse!(person::Person,house)
    if ! undefined(person.pos) 
        removeOccupant!(house, person)
    end

    person.pos = house
    addOccupant!(house, person)
end


"set the father of a child"
function setAsParentChild!(child::Person,parent::Person) 
    @assert age(child) < age(parent)
    @assert (isMale(parent) && father(child) == nothing) ||
        (isFemale(parent) && mother(child) == nothing)
    addChild!(parent, child)
    setParent!(child, father) 
    nothing 
end

function resetPartner!(person)
    other = partner(person)
    if other != nothing 
        setPartner!(person, nothing)
        setPartner!(other, nothing)
    end
    nothing 
end

"resolving partnership"
function resolvePartnership!(person1::Person, person2::Person)
    if partner(person1) != person2 || partner(person2) != person1
        throw(ArgumentError("$(person1) and $(person2) are not partners"))
    end
    resetPartner!(person1)
end


"set two persons to be a partner"
function setAsPartners!(person1::Person,person2::Person)
    if (isMale(person1) && isFemale(person2) || 
        isFemale(person1) && isMale(person2)) 

        resetPartner!(person1) 
        resetPartner!(person2)

        setPartner!(person1, person2)
        setPartner!(person2, person1)
        return nothing 
    end 
    throw(InvalidStateException("Undefined case + $person1 partnering with $person2",:undefined))
end


