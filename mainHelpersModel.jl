"""
Helper functions Temporarily placed here but they rather belong to the internal 
modules, s.a. Create & Initialize 
""" 

using LPM.ParamTypes
using LPM.ParamTypes.Loaders
using XAgents
using LPM.Demography.Create
using LPM.Demography.Initialize


mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}

    fertility :: Matrix{Float64}
    death_female :: Matrix{Float64}
    death_male :: Matrix{Float64}
end


function createUKDemography!(pars)
    ukTowns = createUKTowns(pars.mappars)

    ukHouses = Vector{PersonHouse}()

    ukPopulation = createUKPopulation(pars.poppars)

    ukDemoData   = loadUKDemographyData()

    Model(ukTowns, ukHouses, ukPopulation, 
            ukDemoData.fertility , ukDemoData.death_female, ukDemoData.death_male)
end

function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemography!(model, poppars, workpars, mappars)
    initialConnectH!(model.houses, model.towns, mappars)
    initialConnectP!(model.pop, model.houses, mappars)

    for person in model.pop
        initClass!(person, poppars)
        initWork!(person, workpars)
    end

    nothing
end



function getParameters()
    simPars = SimulationPars(false)

    pars = loadUKDemographyPars() 

    simPars, pars
end


function setupModel(pars)
    model = createUKDemography!(pars)

    initializeDemography!(model, pars.poppars, pars.workpars, pars.mappars)

    model
end
