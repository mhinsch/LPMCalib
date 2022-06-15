export Person, setHouse!

using Spaces: GridSpace
using Utilities: age2yearsmonths



"""
Specification of a Person Agent Type. 

This file is included in the module SocialAgents

Type Person extends from AbstractAgent.
""" 

# vvv More classification of attributes (Basic, Demography, Relatives, Economy )
mutable struct Person <: AbstractPersonAgent
    id
    """
    location of a parson's house in a map which implicitly  
    - (x-y coordinates of a house)
    - (town::Town, x-y location in the map)
    """ 
    pos::House     
    age::Rational 
    # birthYear::Int        
    # birthMonth::Int
    gender::Gender  
    father::Union{Person,Nothing}
    mother::Union{Person,Nothing} 
    partner::Union{Person,Nothing}
    childern::Vector{Person}
    # self.yearMarried = []
    # self.yearDivorced = []
    # self.deadYear = 0

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos::House,age,gender,father,mother,partner,childern)
        global IDCOUNTER = IDCOUNTER+1
        person = new(IDCOUNTER,pos,age,gender,father,mother,partner,childern)
        pos != undefinedHouse ? push!(pos.occupants,person) : nothing
        person  
    end 
end

"costum @show method for Agent person"
function Base.show(io::IO,  person::Person)
    years , months = age2yearsmonths(person.age)
    print("Person: $(person.id), $(years) years & $(months) months, $(person.gender)") 
    person.pos     == undefinedHouse ? nothing : print(" @ House id : $(person.pos.id)") 
    person.father  == nothing        ? nothing : print(" , father    : $(person.father.id)") 
    person.mother  == nothing        ? nothing : print(" , mother    : $(person.mother.id)") 
    person.partner == nothing        ? nothing : print(" , partner   : $(person.partner.id)") 
    length(person.childern) == 0      ? nothing : print(" , childern  : ")
    for child in person.childern
        print(" $(child.id) ") 
    end 
    println() 
end

#Base.show(io::IO, ::MIME"text/plain", person::Person) = Base.show(io,person)

"Constructor with default values"
Person(pos,age; gender=unknown,
                father=nothing,mother=nothing,
                partner=nothing,childern=Person[]) = 
                    Person(pos,age,gender,father,mother,partner,childern)


"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,childern=Person[]) = 
            Person(pos,age,gender,father,mother,partner,childern)



"increment an age for a person to be used in typical stepping functions"
function agestep!(person::Person;dt=1//12) 
   # person += Rational(1,12) or GlobalVariable.DT
   person.age += dt 
end 


function isFemale(person::Person) 
    person.gender == female
end

function isMale(person::Person) 
    person.gender == male
end 

"home town of a person"
function getHomeTown(person::Person)
    getHomeTown(person.pos) 
end

"home town name of a person" 
function getHomeTownName(person::Person) 
    getHomeTown(person).name 
end

"set the father of a child"
function setFather!(child::Person,father::Person) 
    child.age < father.age  ? nothing  : throw(ArgumentError("$(child.age) >= $(father.age)")) 
    isMale(father) ?          nothing  : throw(ArgumentError("$(father) is not a male")) 
    (child.father == nothing) ? father : throw(ArgumentError("$(child) has a father")) 
    child.father = father 
    push!(father.childern,child)
    nothing 
end

"set the mother of a child"
function setMother!(child::Person,mother::Person) 
    child.age < mother.age    ?  nothing : throw(ArgumentError("$(child.age) >= $(father.age)")) 
    isFemale(mother)          ?  nothing : throw(ArgumentError("$(mother) is not a female")) 
    (child.mother == nothing) ?  mother  : throw(ArgumentError("$(child) has a mother")) 
    child.mother = mother 
    push!(mother.childern,child)
    nothing 
end

"set two persons to be a partner"
function setPartner!(person1::Person,person2::Person)
    if (isMale(person1) && isFemale(person2) || 
        isFemale(person1) && isMale(person2)) 

        # resolve previous partnership 
        if person1.partner != nothing 
            person1.partner.partner = nothing 
        end 
        if person2.partner != nothing 
            person2.partner.partner = nothing 
        end 

        person1.partner = person2
        person2.partner = person1
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


