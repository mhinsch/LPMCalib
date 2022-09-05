module Work

export WorkBlock
export setStatus!, setWage!, setEmptyJobSchedule!, setPension!

@enum WorkStatus teenager student retired unemployed

mutable struct WorkBlock
    status :: WorkStatus
    newEntrant :: Bool
    wage :: Float64
    income :: Float64
    jobTenure :: Int
    schedule :: Matrix{Int}
    workingHours :: Int         # how is that different from schedule?
    workingPeriods :: Int
    pension :: Float64
end

function setStatus!(work, status)
    work.status = status
end

function setWage!(work, wage)
    work.wage = wage
end

function setEmptyJobSchedule!(work)
end

function setPension!(work, pension)
    work.pension = pension
end


end Work
