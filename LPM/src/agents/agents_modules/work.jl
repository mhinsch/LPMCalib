using EnumX

export setEmptyJobSchedule!, setFullWeeklyTime!

export WorkStatus

# better (scoped) enums from package EnumX
@enumx WorkStatus child teenager student worker retired unemployed

const WST = WorkStatus.T

# TODO some of this should probably be moved to Care
@kwdef struct Work
    "work status"
    status :: WST = WorkStatus.child
    outOfTownStudent :: Bool = false
    newEntrant :: Bool = true
    initialIncome :: Float64 = 0
    finalIncome :: Float64 = 0
    wage :: Float64 = 0
    income :: Float64 = 0
    "income for full work schedule"
    potentialIncome :: Float64 = 0
    "periods worked so far in current job"
    jobTenure :: Int = 0
    "7x24 schedule of actual working hours"
    schedule :: Matrix{Int} = zeros(Int, 7, 24)
    "potential total working hours per week"
    workingHours :: Int = 0 
    "free time slots"
    weeklyTime :: Matrix{Int} = zeros(Int, 7, 24)
    "sum of realised working hours"
    availableWorkingHours :: Int = 0
    "lifetime work"
    workingPeriods :: Float64 = 0
    workExperience :: Float64 = 0
    pension :: Float64 = 0
end

function setEmptyJobSchedule!(work)
    work.schedule = zeros(Int, 7, 24)
end

function setFullWeeklyTime!(work)
    work.weeklyTime = ones(Int, 7, 24)
end

