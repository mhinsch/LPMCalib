struct Shift
    days :: Vector{Int}
    start :: Int
    startIndex :: Int
    shiftHours :: Vector{Int}
    finish :: Int
    socialIndex :: Float64
end

Shift() = Shift([], 0, 0, [], 0, 0)

Shift(days, hour, hourIndex, shiftHours, socInd) = 
    Shift(days, hour, hourIndex, shiftHours, hour+8, socInd)
    
const EmptyShift = Shift()

currentlyWorking(shift, day, hour) = day in shift.days && hour in shiftHours
