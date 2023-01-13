using CSV
using Tables


export loadDemographyData, DemographyData

struct DemographyData
	pre51Fertility :: Matrix{Float64}
    fertility   :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale   :: Matrix{Float64}  
end

function loadDemographyData(pre51FertFName, fertFName, deathFFName, deathMFName) 
    pre51Fert = CSV.File(pre51FertFName, header=0) |> Tables.matrix
    fert = CSV.File(fertFName, header=0) |> Tables.matrix
    deathFemale = CSV.File(deathFFName, header=0) |> Tables.matrix
    deathMale = CSV.File(deathMFName, header=0) |> Tables.matrix

    DemographyData(pre51Fert, fert, deathFemale, deathMale)
end

