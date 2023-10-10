module DemographyModel

export Model, createDemographyModel!, initializeDemographyModel!, stepModel!

include("agents/shift.jl")
include("agents/town.jl")
include("agents/house.jl")
include("agents/person.jl")
include("agents/world.jl")

include("demography/common/income.jl")
include("demography/common/jobmarket.jl")

include("demography/setup/map.jl")
include("demography/setup/population.jl")
include("demography/setup/mapPop.jl")
include("demography/setup/mapBenefits.jl")

include("demography/simulate/allocate.jl")
include("demography/simulate/death.jl")
include("demography/simulate/birth.jl")  
include("demography/simulate/divorce.jl")       
include("demography/simulate/ageTransition.jl")
include("demography/simulate/socialTransition.jl")
include("demography/simulate/relocate.jl")
include("demography/simulate/marriages.jl")
include("demography/simulate/dependencies.jl")
include("demography/simulate/socialCareTransition.jl")
include("demography/simulate/care.jl")
include("demography/simulate/income.jl")
include("demography/simulate/jobmarket.jl")
include("demography/simulate/benefits.jl")
include("demography/simulate/wealth.jl")


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
            SocialCareCache(), DivorceCache())
end


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns!(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemographyModel!(model, poppars, workpars, mappars, mapbenefitpars)
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)

    initializeLHA!(model.towns, mapbenefitpars)

    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end
    
    initJobs!(model, fuse(poppars, workpars))

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
    deathPreCalc!(model, pars.poppars)

    applyTransition!(model.pop, "death") do person
        death!(person, time, model, pars.poppars)
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
        ageTransition!(person, time, model, pars.workpars)
    end
    
    updateIncome!(model, time, pars.workpars)
    
    updateWealth!(model.pop, model.wealthPercentiles, pars.workpars)
    
    jobMarket!(model, time, fuse(pars.workpars, pars.poppars))

    selected = Iterators.filter(p->selectSocialCareTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "social care") do person
        socialCareTransition!(person, time, model, fuse(pars.poppars, pars.carepars))
    end
    
    computeBenefits!(model.pop, fuse(pars.benefitpars, pars.workpars))
    
    socialCare!(model, pars.carepars)
    
    selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "work") do person
        workTransition!(person, time, model, pars.workpars)
    end
    
    selected = Iterators.filter(p->selectRelocate(p, pars.workpars), model.pop)
    applyTransition!(selected, "relocate") do person
        relocate!(person, time, model, pars.workpars)
    end

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
    
    
    append!(model.pop, model.babies)
    empty!(model.babies)
end


end # module DemographyModel
