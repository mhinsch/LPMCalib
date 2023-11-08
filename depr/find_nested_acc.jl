attr_names = [
    "age", "gender", "alive",
    "father", "mother", "partner", "children", "pTime",
    "status", "outOfTownStudent", "newEntrant", "initialIncome", "finalIncome", 
    "wage", "income", "potentialIncome", "jobTenure", "schedule", "workingHours", "weeklyTime", 
    "availableWorkingHours", "workingPeriods", "workExperience", "pension",
    "careNeedLevel", "socialWork", "childWork",
    "classRank", "parentClassRank",
    "guardians", "dependents", "provider", "providees"]

matches = [Regex("[^[:alnum:]]$(attr_name)!?\\([^)]+\\(") for attr_name in attr_names]

for file in ARGS
    lines = readlines(file)
    for (i, line) in enumerate(lines)
        for m in matches
            if match(m, line) != nothing
                println(file, ":$i ", line)
            end
        end
    end
end
