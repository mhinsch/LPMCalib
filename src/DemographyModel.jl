module DemographyModel

export Model, createDemographyModel!, initializeDemographyModel!, stepModel!

include("agents/shift.jl")
include("agents/task.jl")
include("agents/town.jl")
include("agents/house.jl")
include("agents/person.jl")
include("agents/world.jl")

include("common/income.jl")
include("common/jobmarket.jl")
include("common/tasksCare.jl")

include("setup/map.jl")
include("setup/population.jl")
include("setup/mapPop.jl")
include("setup/mapBenefits.jl")

include("simulate/allocate.jl")
include("simulate/death.jl")
include("simulate/birth.jl")  
include("simulate/divorce.jl")       
include("simulate/ageTransition.jl")
include("simulate/socialTransition.jl")
include("simulate/jobtransition.jl")
include("simulate/relocate.jl")
include("simulate/marriages.jl")
include("simulate/dependencies.jl")
include("simulate/socialCareTransition.jl")
include("simulate/care.jl")
include("simulate/income.jl")
include("simulate/jobmarket.jl")
include("simulate/benefits.jl")
include("simulate/wealth.jl")
include("simulate/housing_topdown.jl")
include("simulate/taskscare.jl")

using Utilities


mutable struct Model
    towns :: Vector{PersonTown}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}
    babies :: Vector{Person}
    shiftsPool :: Vector{Shift}
    
    fertFByAge51 :: Vector{Float64}
    fertility :: Matrix{Float64}
    pre51Fertility :: Vector{Float64}
    pre51Deaths :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale :: Matrix{Float64}
    unemploymentSeries :: Vector{Float64}
    wealthPercentiles :: Vector{Float64}
    
    birthCache :: BirthCache{Person}
    deathCache :: DeathCache
    marriageCache :: MarriageCache{Person}
    socialCache :: SocialCache
    socialCareCache :: SocialCareCache
    divorceCache :: DivorceCache
    jobCache :: JobCache
end


function createDemographyModel!(demoData, workData, pars)
    towns = createTowns(pars.mappars)

    houses = Vector{PersonHouse}()

    # maybe switch using parameter
    #ukPopulation = createPopulation(pars.poppars)
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


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns!(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemographyModel!(
    model, poppars, workpars, carepars, taskcarepars, mappars, mapbenefitpars)
    
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)

    initializeLHA!(model.towns, mapbenefitpars)

    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end
    
    initJobs!(model, fuse(poppars, workpars))
    initCare!(model, fuse(carepars, taskcarepars))

    nothing
end


function removeDead!(model)
    for i in length(model.pop):-1:1
        if !model.pop[i].alive
            remove_unsorted!(model.pop, i)
        end
    end
end


function addBaby!(model, baby)
    push!(model.babies, baby)
end


# TODO not entirely sure if this really belongs here
function stepModel!(model, time, pars)
    shuffle!(model.pop)
    socialPreCalc!(model, pars)
    socialCarePreCalc!(model, fuse(pars.poppars, pars.carepars))
    divorcePreCalc!(model, fuse(pars.poppars, pars.divorcepars, pars.workpars))
    birthPreCalc!(model, fuse(pars.poppars, pars.birthpars))
    deathPreCalc!(model, fuse(pars.poppars, pars.carepars))
    jobPreCalc!(model, time, fuse(pars.poppars, pars.workpars))

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
    
    append!(model.pop, model.babies)
    empty!(model.babies)
end


end # module DemographyModel
