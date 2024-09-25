"""
Implementation of the full model, containing all usable modules.
"""


module FullModel


using Utilities

# entity types
using FullModelPerson, FullModelHouse, Towns, Tasks, Shifts, World 
# common modules
using TasksCareCM


include("../setup/map.jl")
include("../setup/population.jl")
include("../setup/mapPop.jl")
include("../setup/mapBenefits.jl")

# simulation processes
using Dependencies, Age, Social, TasksCare, Income, SocialCare, Relocate, Divorce, Marriage, Death
using Birth, JobTransition, Benefits, Wealth, HousingTopDown

# event subscription
include("fullModelEvents.jl")


export Model, createModel!, initializeModel!, stepModel!

"Main model struct that contains entities, loaded data and caches."
mutable struct Model
# model entities
    "Towns containing houses."
    towns :: Vector{PersonTown}
    "Houses (located in towns)."
    houses :: Vector{PersonHouse}
    "The entire population."
    pop :: Vector{Person}
    "Babies born in the current time step (moved to pop at the end)."
    babies :: Vector{Person}
    "Probability distribution of shifts."
    shiftsPool :: Vector{Shift}
    
# some empirical data used in the model
    fertFByAge51 :: Vector{Float64}
    fertility :: Matrix{Float64}
    pre51Fertility :: Vector{Float64}
    pre51Deaths :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale :: Matrix{Float64}
    unemploymentSeries :: Vector{Float64}
    wealthPercentiles :: Vector{Float64}
    
# caches used by some of the transitions
    birthCache :: BirthCache{Person}
    deathCache :: DeathCache
    marriageCache :: MarriageCache{Person}
    socialCache :: SocialCache
    socialCareCache :: SocialCareCache
    divorceCache :: DivorceCache
    jobCache :: JobCache
end


TasksCare.schoolCare() = schoolCareP


"Create a basic model instance from parameters and loaded empirical data."
function createModel!(demoData, workData, pars)
    towns = createTowns(pars.mappars)

    houses = Vector{PersonHouse}()

    # maybe switch using parameter
    population = createPyramidPopulation(pars.poppars, demoData.initialAgePyramid)
    
    yearsFert = [1951 > demoData.pre51Fertility[y, 1] >= pars.poppars.startTime 
        for y in 1:size(demoData.pre51Fertility)[1]]
    
    yearsMort = [1951 > demoData.pre51Deaths[y, 1] >= pars.poppars.startTime 
        for y in 1:size(demoData.pre51Deaths)[1]]
                
    fert = demoData.fertility[:, 1] # age-specific fertility in 1951
    byAgeF = fert ./ (sum(fert)/length(fert)) 
    
    Model(towns, houses, population, [], [],
            byAgeF, demoData.fertility, demoData.pre51Fertility[yearsFert, 2], 
            demoData.pre51Deaths[yearsMort, 2:3], demoData.deathFemale, demoData.deathMale, 
            workData.unemployment, workData.wealth,
            BirthCache{Person}(), DeathCache(), MarriageCache{Person}(), SocialCache(),
            SocialCareCache(), DivorceCache(), JobCache())
end

"Create houses."
function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns!(towns, pars)
    append!(houses, newHouses)
end

"Assign population to homes."
function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


"Initialise the model."
function initializeModel!(
    model, poppars, workpars, carepars, taskcarepars, mappars, mapbenefitpars)
    
    
    # create houses and assign to pop
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)
    
    # initialise local housing allowance
    initializeLHA!(model.towns, mapbenefitpars)
    
    # initialise social structure and work status
    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end
    
    initJobs!(model, fuse(poppars, workpars))
    initCare!(model, fuse(carepars, taskcarepars))

    nothing
end


"Remove individuals that died from the population."
function removeDead!(model)
    for i in length(model.pop):-1:1
        if !model.pop[i].alive
            remove_unsorted!(model.pop, i)
        end
    end
end

"Add a baby to a temp list, to be added to pop later."
function addBaby!(model, baby)
    push!(model.babies, baby)
end


"One model time step."
function stepModel!(model, time, pars)
    # avoid order effects
    shuffle!(model.pop)
    
    # *** pre-calc various population properties
    
    socialPreCalc!(model, pars)
    socialCarePreCalc!(model, fuse(pars.poppars, pars.carepars))
    divorcePreCalc!(model, fuse(pars.poppars, pars.divorcepars, pars.workpars))
    birthPreCalc!(model, fuse(pars.poppars, pars.birthpars))
    deathPreCalc!(model, fuse(pars.poppars, pars.carepars))
    jobPreCalc!(model, time, fuse(pars.poppars, pars.workpars))
    
    
    # *** run transitions
    
    applyTransition!(model.pop, "death") do person
        death!(person, time, model, fuse(pars.poppars, pars.carepars))
    end
    removeDead!(model)

    orphans = Iterators.filter(p->selectAssignGuardian(p), model.pop)
    applyTransition!(orphans, "adoption") do person
        assignGuardian!(person, time, model, pars)
    end

    selected = Iterators.filter(p->selectBirth(p, pars.birthpars), model.pop)
    applyTransition!(selected, "birth") do person
        birth!(person, time, model, fuse(pars.poppars, pars.birthpars), addBaby!)
    end

    selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "age") do person
        ageTransition!(person, time, model, fuse(pars.workpars, pars.taskcarepars))
    end
    
    updateIncome!(model, time, pars.workpars)
    
    updateWealth!(model.pop, model.wealthPercentiles, pars.workpars)
    
    houseOwnership!(model, pars.housingpars)
    
    selected = Iterators.filter(selectUnemployed, model.pop)
    applyTransition!(selected, "hire") do person
        unemployedTransition!(person, time, model, fuse(pars.poppars, pars.workpars))
    end
    selected = Iterators.filter(selectEmployed, model.pop)
    applyTransition!(selected, "fire") do person
        employedTransition!(person, time, model, fuse(pars.poppars, pars.workpars))
    end

    selected = Iterators.filter(p->selectSocialCareTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "social care") do person
        socialCareTransition!(person, time, model, fuse(pars.poppars, pars.carepars, pars.taskcarepars))
    end
    
    computeBenefits!(model.pop, fuse(pars.benefitpars, pars.workpars))
    
    selected = Iterators.filter(p->selectRelocate(p, pars.workpars), model.pop)
    applyTransition!(selected, "relocate") do person
        relocate!(person, time, model, pars.workpars)
    end
    
    # sort new adults into students and workers
    selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
    applyTransition!(selected, "social") do person
        socialTransition!(person, time, model, pars.workpars) 
    end

    selected = Iterators.filter(p->selectDivorce(p, pars), model.pop)
    applyTransition!(selected, "divorce") do person
        divorce!(person, time, model, fuse(pars.poppars, pars.divorcepars, pars.workpars))
    end
    
    marriagePreCalc!(model, fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))
    selected = Iterators.filter(p->selectMarriage(p, pars.workpars), model.pop)
    applyTransition!(selected, "marriage") do person
        marriage!(person, time, model, 
            fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))
    end
    
    distributeCare!(model, fuse(pars.carepars, pars.taskcarepars))
    
    # now we can add the babies to the pop
    append!(model.pop, model.babies)
    empty!(model.babies)
end


end # module FullModel
