export Person
export isSingle, setHouse!, resolvePartnership!

using Spaces: GridSpace
using Utilities: age2yearsmonths


"""
Specification of a Person Agent Type. 

This file is included in the module XAgents

Type Person extends from AbstractAgent.
""" 

# vvv More classification of attributes (Basic, Demography, Relatives, Economy )
mutable struct Person <: AbstractPerson
    id
    """
    location of a parson's house in a map which implicitly  
    - (x-y coordinates of a house)
    - (town::Town, x-y location in the map)
    """ 
    pos::House    
    info::BasicInfo     
    kinship::Kinship

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos::House,info::BasicInfo,kinship::Kinship)
        person = new(getIDCOUNTER(),pos,info,kinship)
        pos != undefinedHouse ? push!(pos.occupants,person) : nothing
        person  
    end 
end

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
                    Person(pos,BasicInfo(age = age, gender = gender), 
                    Kinship(father,mother,partner,children))


"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,children=Person[]) = 
            Person(pos,BasicInfo(age=age,gender=gender), 
                       Kinship(father,mother,partner,children))


"increment an age for a person to be used in typical stepping functions"
agestep!(person::Person; dt=1//12) = person.info.age += dt  

"increment an age for a person to be used in typical stepping functions"
function agestepAlivePerson!(person::Person;dt=1//12) 
    person.info.age += person.info.alive ?  dt : 0  
end 


isFemale(person::Person) = person.info.gender == female

isMale(person::Person) = person.info.gender == male

isSingle(person::Person) = person.kinship.partner == nothing 

"home town of a person"
getHomeTown(person::Person) = getHomeTown(person.pos) 

"home town name of a person" 
function getHomeTownName(person::Person) 
    getHomeTown(person).name 
end

"set the father of a child"
function setFather!(child::Person,father::Person) 
    child.info.age < father.info.age  ? nothing  : throw(ArgumentError("$(child.info.age) >= $(father.info.age)")) 
    isMale(father) ?                    nothing  : throw(ArgumentError("$(father) is not a male")) 
    (child.kinship.father == nothing) ? nothing : throw(ArgumentError("$(child) has a father")) 
    child.kinship.father = father 
    push!(father.kinship.children,child)
    nothing 
end

"set the mother of a child"
function setMother!(child::Person,mother::Person) 
    child.info.age < mother.info.age    ?  nothing : throw(ArgumentError("$(child.info.age) >= $(father.info..age)")) 
    isFemale(mother)          ?            nothing : throw(ArgumentError("$(mother) is not a female")) 
    (child.kinship.mother == nothing) ?  nothing  : throw(ArgumentError("$(child) has a mother")) 
    child.kinship.mother = mother 
    push!(mother.kinship.children,child)
    nothing 
end

"help function"
partner(person::Person) = person.kinship.partner 

function resetPartner!(person)
    if partner(person) != nothing # reset 
        person.kinship.partner.kinship.partner = nothing
        person.kinship.partner = nothing  
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
function setPartner!(person1::Person,person2::Person)
    if (isMale(person1) && isFemale(person2) || 
        isFemale(person1) && isMale(person2)) 

        resetPartner!(person1) 
        resetPartner!(person2)

        person1.kinship.partner = person2
        person2.kinship.partner = person1
        return nothing 
    end 
    throw(InvalidStateException("Undefined case + $person1 partnering with $person2",:undefined))
end

"associate a house to a person"
function setHouse!(person::Person,house::House)
    try 
        deleteat!(person.pos.occupants, findfirst(x->x==person,person.pos.occupants))
    catch 
        throw(InvalidStateException("inconsistancy $person is not within $(person.pos.occupants)",:inconsistant))
    end 
    person.pos = house
    push!(house.occupants,person)
end


