attr_names = [
    "age", "gender", "alive",
    "father", "mother", "partner", "children", "pTime",
    "status", "outOfTownStudent", "newEntrant", "initialIncome", "finalIncome", 
    "wage", "income", "potentialIncome", "jobTenure", "schedule", "workingHours", "weeklyTime", 
    "availableWorkingHours", "workingPeriods", "workExperience", "pension",
    "careNeedLevel", "socialWork", "childWork",
    "classRank", "parentClassRank",
    "guardians", "dependents", "provider", "providees"]

replacements = [Regex("([^[:alnum:]])$attr_name\\(([^)]+)\\)") => SubstitutionString("\\1\\2.$attr_name") for attr_name in attr_names]

for file in ARGS
    cp(file, file * ".bak")
    path, io = mktemp()
    println(path)
    
    lines = readlines(file)
    
    for line in lines
        for repl in replacements
            line = replace(line, repl)
        end
        println(io, line)
    end
    
    flush(io)
    close(io)
    
    cp(path, file, force=true)
end
