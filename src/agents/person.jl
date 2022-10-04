using TypedDelegation

using DeclUtils

# enable using/import from local directory
push!(LOAD_PATH, "$(@__DIR__)/agents_modules")

export Person
export PersonHouse, undefinedHouse

export moveToHouse!, resetHouse!, resolvePartnership!, setDead!, householdIncome
export householdIncomePerCapita

export getHomeTown, getHomeTownName, agestepAlive!, setDead!, livingTogether
export setAsParentChild!, setAsPartners!, setParent!
export hasAliveChild, ageYoungestAliveChild, hasBirthday
export hasChildrenAtHome, areParentChild, related1stDegree, areSiblings


include("agents_modules/basicinfo.jl")
include("agents_modules/kinship.jl")
include("agents_modules/maternity.jl")
include("agents_modules/work.jl")
include("agents_modules/care.jl")
include("agents_modules/class.jl")


"""
Specification of a Person Agent Type. 

This file is included in the module XAgents

Type Person extends from AbstractAgent.

Person ties various agent modules into one compound agent type.
""" 

# vvv More classification of attributes (Basic, Demography, Relatives, Economy )
mutable struct Person <: AbstractXAgent
    id::Int
    """
    location of a parson's house in a map which implicitly  
    - (x-y coordinates of a house)
    - (town::Town, x-y location in the map)
    """ 
    pos::House{Person}
    info::BasicInfoBlock     
    kinship::KinshipBlock{Person}
    maternity :: MaternityBlock
    work :: WorkBlock
    care :: CareBlock
    class :: ClassBlock

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos, info, kinship, maternity, work, care, class)
        person = new(getIDCOUNTER(),pos,info,kinship, maternity, work, care, class)
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
# and export accessors

@delegate_onefield Person pos [getHomeTown, getHomeTownName]

@export_forward Person info [age, gender, alive]
@delegate_onefield Person info [isFemale, isMale, agestep!, agestepAlive!, hasBirthday]

@export_forward Person kinship [father, mother, partner, children]
@delegate_onefield Person kinship [hasChildren, addChild!, isSingle]

@delegate_onefield Person maternity [startMaternity!, stepMaternity!, endMaternity!, 
    isInMaternity, maternityDuration]

@export_forward Person work [status, outOfTownStudent, newEntrant, initialIncome, finalIncome, 
    wage, income, potentialIncome, jobTenure, schedule, workingHours, weeklyTime, 
    availableWorkingHours, workingPeriods, pension]
@delegate_onefield Person work [setEmptyJobSchedule!, setFullWeeklyTime!]

@export_forward Person care [careNeedLevel, socialWork, childWork]

@export_forward Person class [classRank]
@delegate_onefield Person class [addClassRank!]


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
        Person(pos,BasicInfoBlock(;age, gender), 
            KinshipBlock(father,mother,partner,children), 
            MaternityBlock(false, 0),
            WorkBlock(),
            CareBlock(0, 0, 0),
            ClassBlock(0))


"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,children=Person[]) = 
            Person(pos,BasicInfoBlock(;age,gender), 
                KinshipBlock(father,mother,partner,children),
                MaternityBlock(false, 0),
                WorkBlock(),
                CareBlock(0, 0, 0),
                ClassBlock(0))


const PersonHouse = House{Person, Town}
const undefinedHouse = PersonHouse(undefinedTown, (-1, -1))


"associate a house to a person, removes person from previous house"
function moveToHouse!(person::Person,house)
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

livingTogether(person1, person2) = person1.pos == person2.pos

# parent - child
areParentChild(person1, person2) = person1 in children(person2) || person2 in children(person1)
areSiblings(person1, person2) = father(person1) == father(person2) != nothing || 
    mother(person1) == mother(person2) != nothing
# siblings
related1stDegree(person1, person2) = areParentChild(person1, person2) || areSiblings(person1, person2)


# TODO check if correct
# TODO cache for optimisation?
householdIncome(person) = sum(p -> income(p), person.pos.occupants)
householdIncomePerCapita(person) = householdIncome(person) / length(person.pos.occupants)


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

function hasAliveChild(person)
    for child in children(person) 
        if alive(child) return true end 
    end
    false 
end

function hasChildrenAtHome(person)
    for c in children(person)
        if alive(c) && c.pos == person.pos
            return true
        end
    end
    
    false
end


function ageYoungestAliveChild(person::Person) 
    youngest = Rational{Int}(Inf)  
    for child in children(person) 
        if alive(child) 
            youngest = min(youngest,age(child))
        end 
    end
    youngest 
end
