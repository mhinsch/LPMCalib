module Tasks

export ATask, taskTimeToDay, taskTimeToHour


mutable struct ATask{PERSON}
    "task type: 1 - child care; 2 - social care"
    typ :: Int
    owner :: PERSON
    worker :: PERSON
    "Time in h after 0:00 on Monday."
    time :: Int
    "Urgency of the task (0-1)."
    urgency :: Float64
    "Focus required (0-1)."
    focus :: Float64
end


"Task time -> day of the week."
taskTimeToDay(t) = (t-1) ÷ 24 + 1
taskTimeToHour(t) = (t-1) % 24 + 1


end
