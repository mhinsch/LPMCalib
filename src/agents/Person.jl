export Person, setHouse!

using Spaces: GridSpace



"""
Specification of a Person Agent Type. 

This file is included in the module SocialAgents

Type Person extends from AbstractAgent.
""" 
mutable struct Person <: AbstractPersonAgent
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
    gender::Gender  
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
                gender=unknown,
                father=nothing,mother=nothing,
                partner=nothing,childern=Person[]) = 
                    Person(pos,age,gender,father,mother,partner,childern)

Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,childern=Person[]) = 
            Person(pos,age,gender,father,mother,partner,childern)



"increment an age for a person to be used in typical stepping functions"
function agestep!(person::Person;dt=1) 
   # person += Rational(1,12) or GlobalVariable.DT
   person.age += dt 
end 


function isFemale(person::AbstractPersonAgent) 
    person.gender == female
end

function isMale(person::AbstractPersonAgent) 
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

"set the father of a hild"
function setFather!(child::Person,father::Person) 
    @assert child.age < father.age 
    child.father = father 
    push!(father.childern,child)
    nothing 
end

"set the mother of a child"
function setMother!(child::Person,mother::Person) 
    @assert child.age < mother.age 
    child.mother = mother 
    push!(mother.childern,child)
    nothing 
end


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
    error("Undefined case + $person1 partnering with $person2")
end

"associate a house to a person"
function setHouse!(person::Person,house::House)
    person.pos = house
    push!(house.occupants,person)
end

