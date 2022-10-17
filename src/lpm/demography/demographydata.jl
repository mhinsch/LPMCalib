
export loadDemographyData


function loadDemographyData(fertFName, deathFFName, deathMFname) 
    fert = CSV.File(fertFname, header=0) |> Tables.matrix
    deathFemale = CSV.File(deathFFName, header=0) |> Tables.matrix
    deathMale = CSV.File(deathMFName, header=0) |> Tables.matrix

    (fertility=fert,deathFemale=deathFemale,deathMale=deathMale)
end
