module IncomeHouseAM
    

export IncomeHouse


struct IncomeHouse
    householdIncome :: Float64 
    disposableIncome :: Float64
    incomePerCapita :: Float64
    cumulativeIncome :: Float64
    wealth :: Float64
    ownedByOccupants :: Bool
    incomeDecile :: Int
    ageOccupants :: Float64
end


end
