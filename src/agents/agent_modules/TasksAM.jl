module TasksAM
    

using Utilities


using InstitutionsAM, Tasks


export TaskPerson
export howBusyAt, hasOpenTasks, acceptTask!, markTaskAssigned!, markTaskUnassigned!, findTasksAt
export tasksColocated, removeAllCare!, removeAllTasks!

# TODO
# We might need to rethink how to store assigned vs open tasks.
# If there are a lot of tasks per agent and tasks get refused 
# repeatedly this can become quite inefficient.
# * keep assigned tasks in a set?
# * store tasks by day/owner/type?
@kwdef mutable struct TaskPerson{TASK}
    assignedTasks :: Vector{TASK} = []
    openTasks :: Vector{TASK} = []
    
    "Hourly schedule over the entire week containing sum of focus per hour."
    taskSchedule :: Matrix{Float64} = zeros(24, 7)
    "Tasks the agent does. Sorted by day for faster access."
    todo :: Vector{Vector{TASK}} = [ [] for i in 1:7]
    
    "How eagerly the agent accepts tasks."
    diligence :: Float64 = 1.0
    
    # cache this for efficiency
    taskHours :: Int = 0
end


hasOpenTasks(person) = length(person.openTasks) > 0

tasksColocated(task1, task2) = task1.owner.pos == task2.owner.pos

function markTaskAssigned!(task)
    owner = task.owner
    @assert !isUndefined(owner)
    
    idx = findfirst(isequal(task), owner.openTasks)
    @assert idx != nothing
    
    remove_unsorted!(owner.openTasks, idx)
    push!(owner.assignedTasks, task)
    task.worker = undefined(owner)
    nothing
end


function markTaskUnassigned!(task)
    owner = task.owner
    @assert !isUndefined(owner)
    
    idx = findfirst(isequal(task), owner.assignedTasks)
    @assert idx != nothing
    
    remove_unsorted!(owner.assignedTasks, idx)
    push!(owner.openTasks, task)
    task.worker = undefined(owner)
    nothing
end


function scheduleTask!(agent, task)
    @assert !isUndefined(task)
    @assert task.focus > 0
    # e.g. school
    if !isRealPerson(agent)
        return nothing
    end
    day = taskTimeToDay(task.time)
    @assert !(task in agent.todo[day])
    push!(agent.todo[day], task)
    # another hour committed
    if agent.taskSchedule[task.time] <= 0
        agent.taskHours += 1
    end
    agent.taskSchedule[task.time] += task.focus
    @assert agent.taskSchedule[task.time] <= 1.0
    #@assert agent.taskHours == taskHours(agent)
    nothing
end


function unscheduleTask!(agent, task)
    if !isRealPerson(agent)
        return nothing
    end
    day = taskTimeToDay(task.time)
    idx = findfirst(isequal(task), agent.todo[day])
    @assert idx != nothing
    
    remove_unsorted!(agent.todo[day], idx)
    agent.taskSchedule[task.time] -= task.focus
    # freed up an hour
    if agent.taskSchedule[task.time] <= 0
        agent.taskHours -= 1
    end
    @assert agent.taskSchedule[task.time] >= 0.0
    #@assert agent.taskHours == taskHours(agent)
    nothing
end


function removeAllTasks!(person)
    for task in person.assignedTasks
        unscheduleTask!(task.worker, task)
    end
    
    empty!(person.openTasks)
    empty!(person.assignedTasks)
end


function removeAllCare!(person)
    if !isRealPerson(person)
        return nothing
    end
    for day in person.todo
        for task in day
            markTaskUnassigned!(task)
        end
        empty!(day)
    end
    
    fill!(person.taskSchedule, 0.0)
    person.taskHours = 0
    nothing
end


"Agent accepts task and will clear schedule accordingly if necessary."
function acceptTask!(task, tasksToClear, agent, pars)
    @assert !isUndefined(task)
    @assert !isUndefined(agent)
    @assert !isUndefined(task.owner)
    
    task.worker = agent
    
    for t in tasksToClear
        unscheduleTask!(agent, t[2])
        markTaskUnassigned!(t[2])
    end
    
    scheduleTask!(agent, task)
    nothing
end


taskHours(agent) = count(x->x>0, agent.taskSchedule)


howBusyAt(agent, hour) = agent.taskSchedule[hour]
focusFitsSchedule(agent, t, focus) = howBusyAt(agent, t) + focus < 1

"Whether a given task can be accomodated by an agent's schedule without changes."
fitsSchedule(agent, task) = focusFitsSchedule(agent, task.time, task.focus)

"Return a list of the agent's current tasks that is due at t."
function findTasksAt(agent, t)
    if howBusyAt(agent, t) == 0
        return eltype(agent.todo[1])[]
    end
    
    day = taskTimeToDay(t)
    [ task for task in agent.todo[day]
        if task.time == t ]
end


end
