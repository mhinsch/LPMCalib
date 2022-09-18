using EnumX

export WorkBlock
export setEmptyJobSchedule!

export WorkStatus

# better (scoped) enums from package EnumX
@enumx WorkStatus child teenager student retired unemployed

mutable struct WorkBlock
    status :: WorkStatus.T
    outOfTownStudent :: Bool
    newEntrant :: Bool
    wage :: Float64
    initialIncome :: Float64
    finalIncome :: Float64
    income :: Float64
    jobTenure :: Int
    schedule :: Matrix{Int}
    workingHours :: Int         # how is that different from schedule?
    workingPeriods :: Int
    pension :: Float64
end

function setEmptyJobSchedule!(work)
    work.schedule = zeros(Int, 7, 24)
end

