using TypedDelegation

using DeclUtils

# enable using/import from local directory
push!(LOAD_PATH, "$(@__DIR__)/agents_modules")

export Person
export PersonHouse, undefinedHouse
export setHouse!, resetHouse!, resolvePartnership!, setDead!

export getHomeTown, getHomeTownName, agestepAlive!, setDead!
export setAsParentChild!, setAsPartners!, setParent!
export hasAliveChild, ageYoungestAliveChild


include("agents_modules/basicinfo.jl")
include("agents_modules/kinship.jl")


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
    info::BasicInfoBlock     
    kinship::KinshipBlock{Person}

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos, info, kinship)
        person = new(getIDCOUNTER(),pos,info,kinship)
        if !undefined(pos)
            addOccupant!(pos, person)
        end
        if kinship.father != nothing 
            addChild!(kinship.father,person) 
        end 
        if kinship.mother != nothing 
            addChild!(kinship.mother,person) 
        end 
        if kinship.partner != nothing
            resetPartner!(kinship.partner)
            partner.partner = person 
        end 
        if length(kinship.children) > 0
            for child in kinship.children
                setAsParentChild!(person,child)
            end
        end 
        person  
    end # Person Cor
end # struct Person 

# delegate functions to components

@export_forward Person.info age gender alive
@delegate_onefield Person info [isFemale, isMale, agestep!, agestepAlive!]

@export_forward Person.kinship father mother partner children
@delegate_onefield Person kinship [hasChildren, addChild!, isSingle]

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
            Person(pos,
                 BasicInfoBlock(;age, gender), 
                 KinshipBlock(father,mother,partner,children))



"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
                 gender=unknown,
                 father=nothing,mother=nothing,
                 partner=nothing,children=Person[]) = 
            Person(pos,
                   BasicInfoBlock(;age,gender), 
                   KinshipBlock(father,mother,partner,children))


const PersonHouse = House{Person, Town}
const undefinedHouse = PersonHouse(undefinedTown, (-1, -1))

"home town of a person"
getHomeTown(person::Person) = getHomeTown(person.pos) 

"home town name of a person" 
function getHomeTownName(person::Person) 
    getHomeTown(person).name 
end

"associate a house to a person"
function setHouse!(person::Person,house)
    if ! undefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = house
    addOccupant!(house, person)
end

"reset house of a person (e.g. became dead)"
function resetHouse!(person::Person) 
    if ! undefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = undefinedHouse
    nothing 
end 


"set the father of a child"
function setAsParentChild!(child::Person,parent::Person) 
    isMale(parent) || isFemale(parent) ? nothing : throw(InvalidStateException("$(parent) has unknown gender",:undefined))
    age(child) <  age(parent) ? nothing : throw(ArgumentError("child's age $(age(child)) >= parent's age $(age(parent))")) 
    (isMale(parent) && father(child) == nothing) ||
        (isFemale(parent) && mother(child) == nothing) ? nothing : 
            throw(ArgumentError("$(child) has a parent"))
    addChild!(parent, child)
    setParent!(child, parent) 
    nothing 
end

function resetPartner!(person)
    other = partner(person)
    if other != nothing 
        partner!(person, nothing)
        partner!(other, nothing)
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

        partner!(person1, person2)
        partner!(person2, person1)
        return nothing 
    end 
    throw(InvalidStateException("Undefined case + $person1 partnering with $person2",:undefined))
end


function setDead!(person::Person) 
    person.info.alive = false
    resetHouse!(person)
    if !isSingle(person) 
        resolvePartnership!(partner(person),person)
    end
    # no need to resolve parents / childern relationship
    nothing
end 

"set child of a parent" 
function setParent!(child, parent)
  if isFemale(parent) 
    mother!(child, parent)
  elseif isMale(parent) 
    father!(child, parent)
  else
    throw(InvalidStateException("undefined case",:undefined))
  end
end 

function hasAliveChild(person::KinshipBlock)
    for child in children(person) 
        if alive(child) return true end 
    end
    false 
end

function ageYoungestAliveChild(person::Person) 
    youngest = Rational(Inf)  
    for child in children(person) 
        if alive(child) 
            youngest = min(youngest,age(child))
        end 
    end
    youngest 
end
