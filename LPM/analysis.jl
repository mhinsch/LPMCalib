using MiniObserve

using BasicInfoAM, KinshipAM, WorkAM, BasicHouseAM
using DependenciesIM
using FullModelPerson, FullModelHouse
using TasksCare

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

function income_deciles(pop)
    incomes = [ p.income for p in pop ]
    sort!(incomes)

    dec_size = length(pop) ÷ 10
    inc_decs = zeros(10)
    
    for i in 1:(10*dec_size)
        inc = incomes[i]
        inc_decs[(i-1) ÷ dec_size + 1] += inc
    end

    inc_decs ./ dec_size
end


function work_by_time(pop)
    nWorkers = zeros(Int, 7, 24)
    for p in pop
        nWorkers .+= p.jobSchedule
    end
    
    nWorkers
end


requiresCare(person, pars) = person.careNeedLevel > 0 || person.age < 13
providesCare(person, pars) = person.careNeedLevel == 0 && person.age >= 13


@observe Data model t pars begin
    @record "time" Float64 t
    @record "N" Int length(model.pop)
    
    @for house in model.houses begin
        # format:
        # @stat(name, accumulators...) <| expression
        @stat("hh_size", MVA, MMA, HistAcc(1.0, 1.0)) <| Float64(length(house.occupants))
    end

    # households with children
    @for house in Iterators.filter(h->!isEmpty(h), model.houses) begin
        i_c = findfirst(p->p.age<18, house.occupants)
        if i_c != nothing
            child = house.occupants[i_c]
        end

        is_lp = i_c != nothing && !isOrphan(child) && isSingle(child.guardians[1])

        # all hh with children
        @stat("n_ch_hh", CountAcc) <| (i_c != nothing) 
        # hh with children with lone parents
        @stat("n_lp_hh", CountAcc) <| is_lp
        # number of children in lp households
        @if is_lp @stat("n_ch_lp_hh", HistAcc(0, 1)) <| count(p->p.age<18, house.occupants)
        
       #= ncs = house.netCareSupply
        scn = householdSocialCareNeed(house, model, pars.carepars)
        cbn = careBalance(house)
        unmet_pre = min(0, max(ncs, -scn))
        unmet_post = min(0, max(cbn, -scn))
        
        @stat("care_supply", MVA) <| Float64(ncs)
        @stat("unmet_care", MVA) <| Float64(min(cbn, 0))
        @stat("unmet_scare_pre", MVA) <| Float64(unmet_pre)
        @stat("unmet_scare_post", MVA) <| Float64(unmet_post)
        =#
    end

    @for person in model.pop begin
        @stat("age", MVA, HistAcc(0.0, 3.0)) <| Float64(person.age)
        @stat("married", CountAcc) <| (!isSingle(person))
        @stat("single", CountAcc) <| (person.age > 18 && isSingle(person))
        @stat("alive", CountAcc) <| true
        @stat("class", HistAcc(0.0, 1.0, 4.0)) <| Float64(person.classRank)
        @stat("careneed", HistAcc(0.0, 1.0)) <| Float64(person.careNeedLevel)
        @stat("income", MVA) <| person.income
        @stat("employed", CountAcc) <| statusWorker(person)
        @stat("unemployed", CountAcc) <| statusUnemployed(person)
        @stat("n_orphans", CountAcc) <| isOrphan(person)
        @if isFemale(person) && person.age>50 @stat("n_children", HistAcc(0,1)) <| nChildren(person)
        @if isFemale(person) @stat("f_status", HistAcc(0, 1, 5)) <| Int(person.status)
        @if isMale(person) @stat("m_status", HistAcc(0, 1, 5)) <| Int(person.status)
        @if requiresCare(person, pars) @stat("open_tasks", MVA) <| Float64(length(person.openTasks))
        @if providesCare(person, pars) @stat("av_care_time", MVA) <| Float64(availableCareTime(person, fuse(pars.carepars, pars.taskcarepars)))
        #@stat("p_care_supply", HistAcc(0.0, 4.0), MVA) <| 
        #    Float64(weeklyCareSupply(person, pars.carepars))
        #@stat("p_care_demand", HistAcc(0.0, 4.0), MVA) <| 
        #    Float64(weeklyCareDemand(person, pars.carepars))
    end
    
    @for person in Iterators.filter(p -> isFemale(p) && ! isSingle(p), model.pop) begin
        @stat("age_diff", HistAcc(-10.0, 1.0)) <| Float64(person.partner.age - person.age)
    end
    @record "income_deciles" Vector{Float64} income_deciles(model.pop)
end


function saveHouses(io, houses)
    dump_header(io, houses[1])
    println(io)
    for h in houses
        Utilities.dump(io, h)
        println(io)
    end
end


function saveAgents(io, pop)
    dump_header(io, pop[1])
    println(io)
    for p in pop
        Utilities.dump(io, p)
        println(io)
    end
end
