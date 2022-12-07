module DemographyModel

export Model, createDemographyModel!, initializeDemographyModel!, stepModel!

include("agents/town.jl")
include("agents/house.jl")
include("agents/person.jl")
include("agents/world.jl")

include("demography/setup/map.jl")
include("demography/setup/population.jl")
include("demography/setup/mapPop.jl")

include("demography/simulate/allocate.jl")
include("demography/simulate/death.jl")
include("demography/simulate/birth.jl")  
include("demography/simulate/divorce.jl")       
include("demography/simulate/ageTransition.jl")
include("demography/simulate/socialTransition.jl")
include("demography/simulate/marriages.jl")
include("demography/simulate/dependencies.jl")


using Utilities


mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}
    babies :: Vector{Person}

    fertility :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale :: Matrix{Float64}
end


function createDemographyModel!(data, pars)
    towns = createTowns(pars.mappars)

    houses = Vector{PersonHouse}()

    # maybe switch using parameter
    #ukPopulation = createPopulation(pars.poppars)
    population = createPyramidPopulation(pars.poppars)
    
    Model(towns, houses, population, [],
            data.fertility , data.deathFemale, data.deathMale)
end


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemographyModel!(model, poppars, workpars, mappars)
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)

    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end

    nothing
end


function removeDead!(model)
    for i in length(model.pop):-1:1
        if !alive(model.pop[i])
            remove_unsorted!(model.pop, i)
        end
    end
end


function addBaby!(model, baby)
    push!(model.babies, baby)
end


# TODO not entirely sure if this really belongs here
function stepModel!(model, time, pars)
    resetCacheSocialClassShares()
    resetCachePClassInReprWomen()
    resetCachePMarriedInReprWAndClass()
    resetCachePNChildrenInReprWAndClass()

    applyTransition!(model.pop, death!, "death", time, model, pars.poppars)
    removeDead!(model)

    orphans = Iterators.filter(p->selectAssignGuardian(p), model.pop)
    applyTransition!(orphans, assignGuardian!, "adoption", time, model, pars)

    selected = Iterators.filter(p->selectBirth(p, pars.birthpars), model.pop)
    applyTransition!(selected, birth!, "birth", time, model, 
        fuse(pars.poppars, pars.birthpars), addBaby!)

    selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, ageTransition!, "age", time, model, pars.workpars)

    selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, workTransition!, "work", time, model, pars.workpars)

    selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
    applyTransition!(selected, socialTransition!, "social", time, model, pars.workpars) 

    selected = Iterators.filter(p->selectDivorce(p, pars), model.pop)
    applyTransition!(selected, divorce!, "divorce", time, model, 
                     fuse(pars.poppars, pars.divorcepars, pars.workpars))

    resetCacheMarriages()
    selected = Iterators.filter(p->selectMarriage(p, pars.workpars), model.pop)
    applyTransition!(selected, marriage!, "marriage", time, model, 
                     fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))

    append!(model.pop, model.babies)
    empty!(model.babies)
end


end # module DemographyModel
