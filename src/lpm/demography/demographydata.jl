using CSV
using Tables


export loadDemographyData, DemographyData

struct DemographyData
    fertility   :: Matrix{Float64}
    deathFemale :: Matrix{Float64}
    deathMale   :: Matrix{Float64}  
end

function loadDemographyData(fertFName, deathFFName, deathMFName) 
    fert = CSV.File(fertFName, header=0) |> Tables.matrix
    deathFemale = CSV.File(deathFFName, header=0) |> Tables.matrix
    deathMale = CSV.File(deathMFName, header=0) |> Tables.matrix

    DemographyData(fert,deathFemale,deathMale)
end

function loadDemographyData(datapars)
    dir = datapars.datadir
    ukDemoData   = loadDemographyData(dir * "/" * datapars.fertFName, 
                                      dir * "/" * datapars.deathFFName,
                                      dir * "/" * datapars.deathMFName)
end
