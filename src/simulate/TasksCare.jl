module TasksCare
    

using Utilities

using ChangeEvents

using KinshipAM, TasksAM, DemoPerson, Tasks
using TasksCareCM, SocialCM
using Age, Death

export availableCareTime, removeAllCareAndTasks!, careNeedChanged!, careSupplyChanged!, distributeCare! 
export TasksCareT 

struct TasksCareT end


function ChangeEvents.process!(::ChangeAge1Yr, ::TasksCareT, person, model, pars)
    # child ages out of care need this time step
    if person.age == pars.stopBabyCareAge || person.age == pars.stopChildCareAge 
        careNeedChanged!(person, pars)
    end
end

function ChangeEvents.process!(::ChangeStatus, ::TasksCareT, person, oldStatus, pars)
    careSupplyChanged!(person, pars)
end


function ChangeEvents.process!(::ChangeDeath, ::TasksCareT, person)
    removeAllCareAndTasks!(person)
end    


function removeAllCareAndTasks!(person)
    removeAllTasks!(person)
    removeAllCare!(person)
end


function careNeedChanged!(person, pars)
    removeAllTasks!(person)
    initCareTasks!(person, pars)
end


function careSupplyChanged!(person, pars)
    removeAllCare!(person)
end

"Try to assign carers for all open tasks."
function distributeCare!(model, pars)
    AgentT = eltype(model.pop)
    TaskT = eltype(model.pop[1].openTasks)
    
    # agent => tasks
    askedTasks = Dict{AgentT, Vector{TaskT}}()
    
    # tasks can be rejected, plus more important tasks can
    # override already assigned tasks, so we iterate a couple of times
    for i in 1:pars.nIterCareDist
        # collect all open tasks
        for caree in model.pop
            if !hasOpenTasks(caree) 
                continue
            end
            assignOpenTasks!(caree, askedTasks, pars)
        end
        
        nc = length(askedTasks)
        # x[2] is the list of tasks
        nt = sum(x->length(x[2]), askedTasks)
        #print("$nc\t")
        
        # let carers accept tasks
        for (carer, tasks) in askedTasks
            checkAcceptTasks!(tasks, carer, pars)
        end
        
        empty!(askedTasks)
    end
end


function duringSchoolTime(task, pars)
    d = taskTimeToDay(task.time)
    h = taskTimeToHour(task.time)
    
    1<=d<=5 && 10<=h<=16
end


function assignSchoolCare!(agent, pars)
    if agent.age < 4 || agent.age >= 16
        return nothing
    end
    for task in agent.openTasks
        if task.typ == 1 && duringSchoolTime(task, pars)
            acceptTask!(task, [], schoolCare, pars)
            markTaskAssigned!(task)
        end
    end
    nothing
end


"Add tasks to carer's list of asked tasks."
function addAskedTasks!(carer, tasks, askedTasks)
    carerTasks = get!(askedTasks, carer) do; valtype(askedTasks)() end
    append!(carerTasks, tasks)
end

"Rough measure of availability, does not take into account focus."
availableCareTime(agent, pars) = weeklyCareSupply(agent, pars) - agent.taskHours


"Add agent to list if minimum requirements are met."
function checkAndAddCarer!(list, agent, pars)
    # TODO check location (max dist?)
    if isUndefined(agent) || availableCareTime(agent, pars) <= 0 || agent in list
        return
    end
    
    push!(list, agent)
    nothing
end

"Relatedness as a number in order: child, parent, partner, sibling, other"
function relatedStatus(ofAgent, toAgent)
    if ofAgent in toAgent.children
        1
    elseif toAgent in ofAgent.children
        2
    elseif toAgent.partner == ofAgent
        3
    elseif areSiblings(ofAgent, toAgent)
        4
    else 
        5
    end
end

"Create a list of potential carers for an agent."
function createCarerList(agent, pars)
    # people in the same house
    potentialCarers = similar(agent.pos.occupants, 0)
    for occ in agent.pos.occupants
        checkAndAddCarer!(potentialCarers, occ, pars)
    end
    checkAndAddCarer!(potentialCarers, agent.father, pars)
    checkAndAddCarer!(potentialCarers, agent.mother, pars)
    for c in agent.children
        checkAndAddCarer!(potentialCarers, c, pars)
    end
    
    for s in siblings(agent)
        checkAndAddCarer!(potentialCarers, s, pars)
    end
    
    potentialCarers
end


function careWeightDistance(carer, caree, pars)
    if carer.pos == caree.pos
        pars.careWeightDistance[1]
    elseif carer.pos.town == caree.pos.town
        pars.careWeightDistance[2]
    else
        pars.careWeightDistance[3]
    end
end

"Preference for a given potential carer dependent on task type."
function taskAskWeight(potentialCarer, caree, taskType, pars)
    weight = 1.0
    
    weight *= careWeightDistance(potentialCarer, caree, pars)
    
    # parent, child, sibling, etc.
    rel = relatedStatus(potentialCarer, caree)
    weight *= pars.careWeightRelated[rel, taskType]
    
    weight
end

"Return all open tasks of type `tt` at a (quasi) randomly selected day."
function getChunkOfOpenTasks!(agent, tt)
    rtasks = Vector{eltype(agent.openTasks)}()
    day = 0
    for i in length(agent.openTasks):-1:1
        task = agent.openTasks[i]
        
        if task.typ != tt
            continue
        end
        
        # first task of the right type determines day we are looking at
        # not ideal, but efficient
        if day == 0
            day = taskTimeToDay(task.time)
        elseif taskTimeToDay(task.time) != day
            continue
        end
        
        # add to return vector
        push!(rtasks, task)
        # mark as assigned
        push!(agent.assignedTasks, task)
        # remove from open list
        remove_unsorted!(agent.openTasks, i)
    end
    rtasks
end


# simplified version for now
taskTypes(pars) = 1:2

# TODO
function availabilityWeight(carer, tasks, par)
    t = availableCareTime(carer, par)/length(tasks)
    @assert t >= 0
    t+1
end

"Assign all open tasks of an agent to a potential carer."
function assignOpenTasks!(agent, askedTasks, pars)
    if !hasOpenTasks(agent)
        return nothing
    end
    
    potentialCarers = createCarerList(agent, pars)
    
    assignSchoolCare!(agent, pars)
    
    ttWeights = zeros(length(potentialCarers))
    weights = zeros(length(potentialCarers))
    
    for tt in taskTypes(pars)
        # calculate how likely it is that an agent is going to be asked
        for (i,pCarer) in enumerate(potentialCarers)
            ttWeights[i] = taskAskWeight(pCarer, agent, tt, pars)
        end
        
        # nobody available for this task type
        if sum(ttWeights) <= 0
            continue
        end
        
        # get a chunk of tasks of the same type (specifically with the same 
        # weight calculation)
        # we stop (and continue with next tt) when there are no more tasks of this type
        while true
            tasks = getChunkOfOpenTasks!(agent, tt)
            if isempty(tasks)
                break
            end
            # preferentially ask those that are available most of the time
            for (i,pCarer) in enumerate(potentialCarers)
                weights[i] = ttWeights[i] * availabilityWeight(pCarer, tasks, pars)
                # we actually need the cumulative sum
                if i>1
                    weights[i] += weights[i-1]
                end
            end
            
            r = rand() * weights[end]     
            # draw agent to ask
            pCarer = potentialCarers[searchsortedfirst(weights, r)]
            
            # add task to pCarer's list
            addAskedTasks!(pCarer, tasks, askedTasks)
        end
    end
    nothing
end

"Importance of the task to the carer."
function taskImportance(task, agent, pars) :: Float64
    importance = 1.0
    
    # parent, child, sibling, etc.
    rel = relatedStatus(agent, task.owner)
    importance *= pars.careWeightRelated[rel, task.typ]
    
    importance *= task.urgency
    
    @assert importance isa Float64
    
    importance
end


"Get importance of current tasks at a given hour. Returns list of priorites and list of tasks, an empty array if there are none, or nothing if agent has to work."
function getImportanceAt(agent, t, pars)
    if agent.jobSchedule[t]
        return nothing
    end
    tasks = findTasksAt(agent, t)
    
    [ (taskImportance(tt, agent, pars), tt) for tt in tasks ]
end

"Get list of tasks that would have to be given up in order to accomodate new task."
function taskAcceptPlan(agent, task, pars)
    t = task.time; focus = task.focus
    # get list of (importance, task) at time t
    tasks = getImportanceAt(agent, t, pars)
    # for now we return nothing if agent has to work at time t
    if tasks == nothing
        return nothing
    end
    
    @assert isempty(tasks) || (tasks[1][1] isa Float64)
    
    # tapped out, can't give up free hour
    if isempty(tasks) && availableCareTime(agent, pars) <= 0
        return tasks
    end
    
    # if new task is at different location we'd have to give up all previous tasks
    # currently assumes caree determines location
    if !isempty(tasks) && !tasksColocated(tasks[1][2], task)
        return tasks
    end
    
    # sort by order of importance
    sort!(tasks, by=x->x[1])
    
    f = focus 
    # check how many of the most important tasks we can keep
    while length(tasks) > 0
        # check if the current most important one still fits
        f += tasks[end][2].focus
        if f > 1
            break
        end
        # still fits, so remove it from delete list
        pop!(tasks)
    end   
    
    tasks
end

"Sigmoid with f(0)=0, f(1/2)=1/2, f(1)=1. Linear for shape=1; higher values increase slope at 0.5."
function sigmoid(x, shape)
    xs = x^shape
    xs/(xs + (1-x)^shape)
end

"Simple way to calculate probability to accept a task from importance."
diligence(agent, importance) = importance^agent.diligence 

"Probability that a task gets accepted."
function taskAcceptProb(task, giveUp, carer, pars)
    # agent has to work
    if giveUp == nothing
        return 0.0
    end
    
    # importance of new task
    importance = taskImportance(task, carer, pars)
    # importance of old tasks == prob to keep none of them
    curImportance = 1.0 - prod(x -> 1.0-x[1], giveUp, init=1.0)
    
    # probability to switch to new task; always 1 if no previous task
    ratio = importance/(importance + curImportance)
    prob = sigmoid(ratio, pars.acceptProbPolarity)
    
    diligence(carer, prob * importance)
end

"Check for all tasks whether to accept."
function checkAcceptTasks!(tasks, agent, pars)
    for task in tasks
        # we keep giveUp around for efficiency
        tasksToGiveUp = taskAcceptPlan(agent, task, pars)
        prob = taskAcceptProb(task, tasksToGiveUp, agent, pars)
        if rand() > prob
            # needed, since caree needs to mark task as open again
            markTaskUnassigned!(task)
        else
            acceptTask!(task, tasksToGiveUp, agent, pars)
        end
    end
end

end	# module TasksCareT

