module Work

using Utilities: @decl_setters, @decl_getters, @decl_getsetters

export WorkBlock
export WorkStatus
export status, outOfTownStudent, newEntrant, wage, income, jobTenure, schedule, workingHours, 
    workingPeriods, pension
export status!, outOfTownStudent!, newEntrant!, wage!, income!, jobTenure!, schedule!, 
    workingHours!, workingPeriods!, pension!

@enum WorkStatus child teenager student retired unemployed

mutable struct WorkBlock
    status :: WorkStatus
    outOfTownStudent :: Bool
    newEntrant :: Bool
    wage :: Float64
    income :: Float64
    jobTenure :: Int
    schedule :: Matrix{Int}
    workingHours :: Int         # how is that different from schedule?
    workingPeriods :: Int
    pension :: Float64
end

@decl_getsetters WorkBlock status outOfTownStudent newEntrant wage income jobTenure 
@decl_getsetters WorkBlock schedule workingHours workingPeriods pension


function setEmptyJobSchedule!(work)
    work.schedule = zeros(Int, 7, 24)
end


end # Work
