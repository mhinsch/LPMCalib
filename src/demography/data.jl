using CSV
using Tables


export loadDemographyData, DemographyData

struct DemographyData
    initialAgePyramid :: Vector{Vector{Float64}}
	pre51Fertility :: Matrix{Float64}
    fertility   :: Matrix{Float64}
    pre51Deaths :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale   :: Matrix{Float64}  
end

function loadDemographyData(apFName, pre51FertFName, fertFName, 
    pre51DeathsFName, deathFFName, deathMFName) 
    
    agePyramid = CSV.File(apFName, header=0) |> Tables.matrix 
    pre51Fert = CSV.File(pre51FertFName, header=0) |> Tables.matrix
    fert = CSV.File(fertFName, header=0) |> Tables.matrix
    pre51Deaths = CSV.File(pre51DeathsFName, header=0) |> Tables.matrix
    deathFemale = CSV.File(deathFFName, header=0) |> Tables.matrix
    deathMale = CSV.File(deathMFName, header=0) |> Tables.matrix

    DemographyData([cumsum(agePyramid[:, 1]), cumsum(agePyramid[:, 2])],
        pre51Fert, fert, pre51Deaths, deathFemale, deathMale)
end

