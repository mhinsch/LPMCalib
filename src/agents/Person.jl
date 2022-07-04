export Person
export isSingle, setHouse!, resolvePartnership!

export AbstractPerson, Kinship
export isMale, isFemale
export getHomeTown, getHomeTownName, agestep!
export setFather!, setMother!, setParent!, setPartner! 


using TypedDelegation

include("kinship.jl")
include("basicinfo.jl")


"""
Specification of a Person Agent Type. 

This file is included in the module XAgents

Type Person extends from AbstractAgent.
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
        pos != undefinedHouse ? addOccupant(house,person) : nothing
        person  
    end 
end

# delegate functions to components

@delegate_onefield Person info [isFemale, isMale, age, agestep!, agestepAlive!]
@delegate_onefield Person kinship [isSingle, partner, father, mother, setParent!, addChild!, setPartner!]


"costum @show method for Agent person"
function Base.show(io::IO,  person::Person)
    print(person.info)
    person.pos     == undefinedHouse ? nothing : print(" @ House id : $(person.pos.id)") 
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


"home town of a person"
getHomeTown(person::Person) = getHomeTown(person.pos) 

"home town name of a person" 
function getHomeTownName(person::Person) 
    getHomeTown(person).name 
end

"associate a house to a person"
function setHouse!(person::Person,house::House)
    try 
        deleteat!(person.pos.occupants, findfirst(x->x==person,person.pos.occupants))
    catch 
        throw(InvalidStateException("inconsistancy $person is not within $(person.pos.occupants)",:inconsistant))
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
	setPartner!(person, nothing)
	setPartner!(other, nothing)
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


