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
    initialWage:: Float64 = 0
    finalWage:: Float64 = 0
    "hourly income for current job"
    wage :: Float64 = 0
    "monthly income dependent on wage/work schedule"
    income :: Float64 = 0
    cumulativeIncome :: Float64 = 0
    disposableIncome :: Float64 = 0
    "last income, used for pension"
    lastIncome :: Float64 = 0
    wealth :: Float64 = 0
    financialWealth :: Float64 = 0
    "potential total working hours per week"
    workingHours :: Int = 0 
    jobShift :: Shift = Shift()
    daysOff :: Vector{Int} = []
    jobSchedule :: Matrix{Bool} = zeros(Bool, 24, 7)
    "sum of actual working hours"
    availableWorkingHours :: Int = 0
    "lifetime work"
    workingPeriods :: Float64 = 0
    workExperience :: Float64 = 0
    pension :: Float64 = 0
    unemploymentMonths :: Int = 0
    "periods worked so far in current job"
    jobTenure :: Int = 0
    monthHired :: Int = 0
end


mutable struct RMWork
    "marker for people who enter job market outside of jobMarket function 
    (to assign unemployment duration)"
    newEntrant :: Bool = true
    unemploymentDuration :: Int = 0
end        


function setEmptyJobSchedule!(work)
    fill!(work.jobSchedule, false)
end


function loseJob!(person)
    setEmptyJobSchedule!(person)
    person.monthHired = -1
    person.income = 0
    person.workingHours = 0
    person.jobShift = EmptyShift
    person.jobTenure = 0
end


