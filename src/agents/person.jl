using TypedDelegation

using DeclUtils

include("../../loadLibsPath.jl")
# enable using/import from local directory
addToLoadPath!("agents_modules")

export Person
export PersonHouse, undefinedHouse

export moveToHouse!, resetHouse!, resolvePartnership!, householdIncome
export householdIncomePerCapita

export getHomeTown, getHomeTownName, agestepAlive!, livingTogether
export setAsParentChild!, setAsPartners!, setParent!
export hasAliveChild, ageYoungestAliveChild, hasBirthday, yearsold
export hasChildrenAtHome, areParentChild, related1stDegree, areSiblings
export canLiveAlone, isOrphan, setAsGuardianDependent!, setAsProviderProvidee!
export hasDependents, isDependent, hasProvidees
export setAsIndependent!, setAsSelfproviding!, resolveDependency!
export checkConsistencyDependents
export maxParentRank


include("agents_modules/basicinfo.jl")
include("agents_modules/kinship.jl")
include("agents_modules/maternity.jl")
include("agents_modules/work.jl")
include("agents_modules/care.jl")
include("agents_modules/class.jl")
include("agents_modules/dependencies.jl")


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
    dependencies :: DependencyBlock{Person}

    # Person(id,pos,age) = new(id,pos,age)
    "Internal constructor" 
    function Person(pos, info, kinship, maternity, work, care, class, dependencies)
        person = new(getIDCOUNTER(),pos,info,kinship, maternity, work, care, class, dependencies)
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
@delegate_onefield Person info [isFemale, isMale, agestep!, agestepAlive!, hasBirthday, yearsold]

@export_forward Person kinship [father, mother, partner, children]
@delegate_onefield Person kinship [hasChildren, addChild!, isSingle, parents, siblings]

@delegate_onefield Person maternity [startMaternity!, stepMaternity!, endMaternity!, 
    isInMaternity, maternityDuration]

@export_forward Person work [status, outOfTownStudent, newEntrant, initialIncome, finalIncome, 
    wage, income, potentialIncome, jobTenure, schedule, workingHours, weeklyTime, 
    availableWorkingHours, workingPeriods, pension]
@delegate_onefield Person work [setEmptyJobSchedule!, setFullWeeklyTime!]

@export_forward Person care [careNeedLevel, socialWork, childWork]

@export_forward Person class [classRank]
@delegate_onefield Person class [addClassRank!]

@export_forward Person dependencies [guardians, dependents, provider, providees]
@delegate_onefield Person dependencies [isDependent, hasDependents, hasProvidees]

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
               KinshipBlock{Person}(father,mother,partner,children), 
            MaternityBlock(false, 0),
            WorkBlock(),
            CareBlock(0, 0, 0),
            ClassBlock(0), DependencyBlock{Person}())


"Constructor with default values"
Person(;pos=undefinedHouse,age=0,
        gender=unknown,
        father=nothing,mother=nothing,
        partner=nothing,children=Person[]) = 
            Person(pos,BasicInfoBlock(;age,gender), 
                   KinshipBlock{Person}(father,mother,partner,children),
                MaternityBlock(false, 0),
                WorkBlock(),
                CareBlock(0, 0, 0),
                ClassBlock(0), DependencyBlock{Person}())


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


areParentChild(person1, person2) = person1 in children(person2) || person2 in children(person1)
areSiblings(person1, person2) = father(person1) == father(person2) != nothing || 
    mother(person1) == mother(person2) != nothing
related1stDegree(person1, person2) = areParentChild(person1, person2) || areSiblings(person1, person2)


# TODO check if correct
# TODO cache for optimisation?
householdIncome(person) = sum(p -> income(p), person.pos.occupants)
householdIncomePerCapita(person) = householdIncome(person) / length(person.pos.occupants)


"set the father of a child"
function setAsParentChild!(child::Person,parent::Person) 
    @assert isMale(parent) || isFemale(parent)
    @assert age(child) < age(parent)
    @assert (isMale(parent) && father(child) == nothing) ||
        (isFemale(parent) && mother(child) == nothing) 

    addChild!(parent, child)
    setParent!(child, parent) 
    # would be nice to ensure consistency of dependence/provision at this point as well
    # but there are so many specific situations that it is easier to do that in simulation
    # code
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
    @assert partner(person1) == person2 && partner(person2) == person1

    resetPartner!(person1)
end


"set two persons to be a partner"
function setAsPartners!(person1::Person,person2::Person)
    @assert isMale(person1) == isFemale(person2)

    resetPartner!(person1) 
    resetPartner!(person2)

    partner!(person1, person2)
    partner!(person2, person1)
end


"set child of a parent" 
function setParent!(child, parent)
    @assert isFemale(parent) || isMale(parent)

    if isFemale(parent) 
        mother!(child, parent)
    else 
        father!(child, parent)
    end

    nothing
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


canLiveAlone(person) = age(person) >= 18
isOrphan(person) = !canLiveAlone(person) && !isDependent(person)

function setAsGuardianDependent!(guardian, dependent)
    push!(dependents(guardian), dependent)
    push!(guardians(dependent), guardian)
    nothing
end

function resolveDependency!(guardian, dependent)
    deps = dependents(guardian)
    idx_d = findfirst(==(dependent), deps)
    if idx_d == nothing
        return
    end

    deleteat!(deps, idx_d)

    guards = guardians(dependent)
    idx_g = findfirst(==(guardian), guards)
    if idx_g == nothing
        error("inconsistent dependency!")
    end
    deleteat!(guards, idx_g)
end


function setAsIndependent!(person)
    if !isDependent(person) 
        return
    end

    for g in guardians(person)
        g_deps = dependents(g)
        deleteat!(g_deps, findfirst(==(person), g_deps))
    end
    empty!(guardians(person))
    nothing
end

# check basic consistency, if there's an error on any of these 
# then something is seriously wrong
function checkConsistencyDependents(person)
    for guard in guardians(person)
        @assert guard != nothing && alive(guard)
        @assert person in dependents(guard)
    end

    for dep in dependents(person)
        @assert dep != nothing && alive(dep)
        @assert age(dep) < 18
        @assert person.pos == dep.pos
        @assert person in guardians(dep)
    end
end


function setAsProviderProvidee!(prov, providee)
    @assert provider(providee) == nothing
    @assert !(providee in providees(prov))
    push!(providees(prov), providee)
    provider!(providee, prov)
    nothing
end

function setAsSelfproviding!(person)
    if provider(person) == nothing
        return
    end

    provs = providees(provider(person))
    deleteat!(provs, findfirst(==(person), provs))
    provider!(person, nothing)
    nothing
end


function maxParentRank(person)
    f = father(person)
    m = mother(person)
    if f == m == nothing
        classRank(person)
    elseif f == nothing
        classRank(m)
    elseif m == nothing
        classRank(f)
    else
        max(classRank(m), classRank(f))
    end
end
