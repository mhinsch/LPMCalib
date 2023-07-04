using CompositeStructs

using DeclUtils
using TypedDelegation

export Person
export PersonHouse, isUndefined, undefinedHouse

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
Person ties various agent modules into one compound agent type.
""" 

@composite @kwdef mutable struct Person 
    
    BasicInfo...
    Kinship{Person}...
    Maternity...
    Work...
    Care...
    Class...
    Dependency{Person}...
    
    pos::House{Person, Town} = undefinedHouse
    # undefined Person
    function Person(::Nothing)
        p = new()
        p.age = -1
        p
    end
    
    # default constructor
    Person(args...) = new(args...)
end # struct Person 


# delegate functions to components
# and export accessors

@delegate_onefield Person pos [getHomeTown, getHomeTownName]

@export_forward Person [age, gender, alive]
@export_forward Person [father, mother, partner, children, pTime]
@export_forward Person [status, outOfTownStudent, newEntrant, initialIncome, finalIncome, 
    wage, income, potentialIncome, jobTenure, schedule, workingHours, weeklyTime, 
    availableWorkingHours, workingPeriods, workExperience, pension]
@export_forward Person [careNeedLevel, socialWork, childWork]
@export_forward Person [classRank, parentClassRank]
@export_forward Person [guardians, dependents, provider, providees]

const PersonHouse = House{Person, Town}
const PersonTown = Town{PersonHouse}
const undefinedTown = PersonTown((-1,-1), 0.0)
const undefinedHouse = PersonHouse(undefinedTown, (-1, -1))
const undefinedPerson = Person(nothing)

undefined(::Type{PersonHouse}) = undefinedHouse
undefined(::Type{PersonTown}) = undefinedTown
undefined(::Type{Person}) = undefinedPerson


isUndefined(h::PersonHouse) = h == undefinedHouse
isUndefined(t::PersonTown) = t == undefinedTown
isUndefined(p::Person) = p == undefinedPerson

"associate a house to a person, removes person from previous house"
function moveToHouse!(person::Person,house)
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = house
    addOccupant!(house, person)
end

"reset house of a person (e.g. became dead)"
function resetHouse!(person::Person) 
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = undefinedHouse
    nothing 
end 

livingTogether(person1, person2) = person1.pos == person2.pos

"Whether the person shares their house with a non-dependent, non-guardian. Note that this includes spouses and spouses' children."
function livesInSharedHouse(person)
    for p in person.pos.occupants
        if p != person && ! (p in guardians(person)) && ! (p in dependents(person))
            return true
        end
    end
    
    false
end


areParentChild(person1, person2) = person1 in children(person2) || person2 in children(person1)
areSiblings(person1, person2) = father(person1) == father(person2) != undefinedPerson || 
    mother(person1) == mother(person2) != undefinedPerson
related1stDegree(person1, person2) = areParentChild(person1, person2) || areSiblings(person1, person2)


# TODO check if correct
# TODO cache for optimisation?
householdIncome(person) = sum(p -> income(p), person.pos.occupants)
householdIncomePerCapita(person) = householdIncome(person) / length(person.pos.occupants)


"set the father of a child"
function setAsParentChild!(child::Person,parent::Person) 
    @assert isMale(parent) || isFemale(parent)
    @assert age(child) < age(parent)
    @assert (isMale(parent) && isUndefined(father(child))) ||
        (isFemale(parent) && isUndefined(mother(child))) 

    addChild!(parent, child)
    setParent!(child, parent) 
    # would be nice to ensure consistency of dependence/provision at this point as well
    # but there are so many specific situations that it is easier to do that in simulation
    # code
    nothing 
end

function resetPartner!(person)
    other = partner(person)
    if !isUndefined(other) 
        partner!(person, undefinedPerson)
        pTime!(person, 0)
        partner!(other, undefinedPerson)
        pTime!(other, 0)
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

    # set class rank to maximum of guardians'
    parentClassRank!(dependent, maximum(classRank, guardians(dependent)))
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
    nothing
end

"Dissolve all guardian-dependent relationships of `person`"
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
        @assert !isUndefined(guard) && alive(guard)
        @assert person in dependents(guard)
    end

    for dep in dependents(person)
        @assert !isUndefined(dep)  
        @assert age(dep) < 18
        @assert person.pos == dep.pos
        @assert person in guardians(dep)
    end
end


function setAsProviderProvidee!(prov, providee)
    @assert isUndefined(provider(providee))
    @assert !(providee in providees(prov))
    push!(providees(prov), providee)
    provider!(providee, prov)
    nothing
end

function setAsSelfproviding!(person)
    if isUndefined(provider(person))
        return
    end

    provs = providees(provider(person))
    deleteat!(provs, findfirst(==(person), provs))
    provider!(person, undefinedPerson)
    nothing
end


function maxParentRank(person)
    f = father(person)
    m = mother(person)
    if f == m == undefinedPerson
        classRank(person)
    elseif f == undefinedPerson
        classRank(m)
    elseif m == undefinedPerson
        classRank(f)
    else
        max(classRank(m), classRank(f))
    end
end

function Utilities.dump_header(io, p::Person, FS)
    print(io, "id", FS, "house", FS)
    Utilities.dump_header(io, p.info, FS); print(io, FS)
    Utilities.dump_header(io, p.kinship, FS); print(io, FS)
    Utilities.dump_header(io, p.maternity, FS); print(io, FS)
    Utilities.dump_header(io, p.work, FS); print(io, FS)
    Utilities.dump_header(io, p.care, FS); print(io, FS)
    Utilities.dump_header(io, p.class, FS); print(io, FS)
    Utilities.dump_header(io, p.dependencies, FS)
end

# links to objects are dumped as object id
function Utilities.dump_property(io, prop::Person, FS="\t", ES=",")
    print(io, objectid(prop))
end

function Utilities.dump_property(io, prop::House, FS="\t", ES=",")
    print(io, objectid(prop))
end

function Utilities.dump_property(io, prop::Union{Person, Nothing}, FS="\t", ES=",") 
    if prop == nothing
        print(io, 0)
    else
        Utilities.dump_property(io, prop, FS, ES)
    end
end

function Utilities.dump(io, person::Person, FS="\t", ES=",")
    print(io, objectid(person), FS)
    Utilities.dump_property(io, person.pos, FS, ES); print(io, FS)
    Utilities.dump(io, person.info, FS, ES); print(io, FS)
    Utilities.dump(io, person.kinship, FS, ES); print(io, FS)
    Utilities.dump(io, person.maternity, FS, ES); print(io, FS)
    Utilities.dump(io, person.work, FS, ES); print(io, FS)
    Utilities.dump(io, person.care, FS, ES); print(io, FS)
    Utilities.dump(io, person.class, FS, ES); print(io, FS)
    Utilities.dump(io, person.dependencies, FS, ES)
end
  
