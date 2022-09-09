"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia MainMALPM.jl

from REPL execute it using 
> include("MainMALPM.jl")
"""

using CSV
using Tables

include("./loadLibsPath.jl")

if !occursin("src/generic",LOAD_PATH)
    push!(LOAD_PATH, "src/generic") 
end


using LPM.ParamTypes.Loaders:    loadUKDemographyPars
using LPM.ParamTypes: SimulationPars

using XAgents: Person, Town, PersonHouse, alive, agestep!

using LPM.Demography.Create:     createUKTowns, createUKPopulation
using LPM.Demography.Initialize: initializeHousesInTowns,
                                  assignCouplesToHouses!
using LPM.Demography.Simulate: doDeaths!

mutable struct Model
    towns :: Vector{Town}
    houses :: Vector{PersonHouse}
    pop :: Vector{Person}

    fert :: Matrix{Float64}
    death_female :: Matrix{Float64}
    death_male :: Matrix{Float64}
end


function createUKDemography!(pars)
    ukTowns = createUKTowns(pars.mappars)

    ukHouses = Vector{PersonHouse}()

    ukPopulation = createUKPopulation(pars.poppars)

    fert = CSV.File("data/babyrate.txt.csv",header=0) |> Tables.matrix
    death_female = CSV.File("data/deathrate.fem.csv",header=0) |> Tables.matrix
    death_male = CSV.File("data/deathrate.male.csv",header=0) |> Tables.matrix

    Model(ukTowns, ukHouses, ukPopulation, fert, death_female, death_male)
end


function initialConnectH!(houses, towns, pars)
    newHouses = initializeHousesInTowns(towns, pars)
    append!(houses, newHouses)
end

function initialConnectP!(pop, houses, pars)
    assignCouplesToHouses!(pop, houses)
end


function initializeDemography!(towns, houses, pop, pars)
    initialConnectH!(houses, towns, pars)
    initialConnectP!(pop, houses, pars)
end


function populationStep!(pop, simPars, pars)
    for agent in pop
        if !alive(agent)
            continue
        end

        agestep!(agent, simPars.dt)
    end
end


function run!(model, simPars, pars)
    time = Rational(simPars.startTime)

    while time < simPars.finishTime
        
        doDeaths!(people = Iterators.filter(a->alive(a), model.pop),
                  parameters = pars, data = model, currstep = time)

        populationStep!(model.pop, simPars, pars)

        time += simPars.dt
    end
end


const pars = loadUKDemographyPars() 

const model = createUKDemography!(pars)

initializeDemography!(model.towns, model.houses, model.pop, pars.mappars)

@show "Town Samples: \n"     
@show model.towns[1:10]
println(); println(); 
                        
@show "Houses samples: \n"      
@show model.houses[1:10]
println(); println(); 
                        
@show "population samples : \n" 
@show model.pop[1:10]
println(); println(); 


# Declaration of a simulation 

const simPars = SimulationPars()


# Execution 

@time run!(model, simPars, pars.poppars)

model
