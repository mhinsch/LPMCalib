"""
Diverse useful functions and types 
"""
module Utilities



# Functions
export p_yearly2monthly, applyTransition!, remove_unsorted!, limit 
export separate
export sorted_unique!, date2yearsmonths, age2yearsmonths
export checkAssumptions!, ignoreAssumptions!, assumption, setDelay!, delay
export setVerbose!, unsetVerbose!, verbose, verbosePrint, delayedVerbose
export fuse, countSubset 
export dump, dump_property, dump_header
export sumClassBias, rateBias, preCalcRateBias!
export WeightSampler, sampleNoReplace!, sampleNoReplaceFrom!, resetSampler!, initWeight!, mapWeights
export undefined, isUndefined


function undefined end
function isUndefined end

"convert date in rational representation to (years, months) as tuple"
function date2yearsmonths(date::Rational{Int})
    date < 0 ? throw(ArgumentError("Negative age")) : nothing 
    12 % denominator(date) != 0 ? throw(ArgumentError("$(date) not in age format")) : nothing 
    years  = trunc(Int, numerator(date) / denominator(date)) 
    months = trunc(Int, numerator(date) % denominator(date) * 12 / denominator(date) )
    (years , months)
end 

age2yearsmonths(age) = date2yearsmonths(age)

p_yearly2monthly(p) = 1 - (1-p)^(1/12)

limit(mi, v, ma) = min(ma, max(mi, v))

"Very efficiently remove element `index` from `list`. Does not preserve ordering of `list`."
function remove_unsorted!(list, index)
    list[index] = list[end]
    pop!(list)
end


function separate(pred, list)
    res_true = eltype(list)[]
    res_false = eltype(list)[]
    
    for el in list
        if pred(el)
            push!(res_true, el)
        else
            push!(res_false, el)
        end
    end
    
    res_true, res_false
end

"Remove double elements from a sorted vector."
function sorted_unique!(ar)
    if isempty(ar)
        return
    end
    v = ar[end]
    l = length(ar) - 1
    for i in l:-1:1
        e = ar[i]
        if e == v
            remove_unsorted!(ar, i)
        else
            v = e
        end
    end
    nothing
end

"Apply a transition function to an iterator."
@inline function applyTransition!(transition, people, name)
    count = 0
    for p in people 
        transition(p)
        count += 1
    end

    verbose() do 
        if name != ""
            println(count, " agents processed in ", name)
        end
    end
end

#="keep variable across function calls"
macro static_var(init)
  var = gensym()
  Base.eval(__module__, :(const $var = $init))
  quote
    global $var
    $var
  end |> esc
end=#


"Count the elements of a subset and a subset of that subset of population."
@inline function countSubset(condAll, condSubset, population)
    nAll = 0
    nS = 0

    for x in Iterators.filter(condAll, population)
        nAll += 1
        if condSubset(x)
            nS += 1
        end
    end

    nAll, nS
end

 
@inline function sumClassBias(classFn, range, bias)
    sum(range) do c
        classFn(c) * bias^c
    end
end

@inline function rateBias(classFn, range, bias, thisClass)
    bias^thisClass / sumClassBias(classFn, range, bias)  
end


@inline function preCalcRateBias!(fn, range, bias, array, offset = 0)
    sumBias = sumClassBias(fn, range, bias)
    for c in range
        array[c+offset] = bias^c/sumBias
    end
end



mutable struct Debug
    checkAssumptions :: Bool
    verbose :: Bool
    sleeptime :: Float64
end

const debug = Debug(false, false, 0.0)

checkAssumptions!() = debug.checkAssumptions = true
ignoreAssumptions!() = debug.checkAssumptions = false

function assumption(check, args...)
    if debug.checkAssumptions
        check(args...)
    end
end

setDelay!(delay) = debug.sleeptime = delay
delay() = sleep(debug.sleeptime)

setVerbose!() = debug.verbose = true
unsetVerbose!() = debug.verbose = false

function verbose(output, args...)
    if debug.verbose
        output(args...)
    end
end

verbosePrint(args...) = verbose(println, args...)

function delayedVerbose(output, args...)
    if debug.verbose
        output(args...)
        delay()
    end
end


"obtain a named tuple type with the same field types and names as `struct_T`"
function tuple_type(struct_Ts...)
    names = [ name for struct_T in struct_Ts for name in fieldnames(struct_T) ]
    types = [ typ for struct_T in struct_Ts for typ in fieldtypes(struct_T) ]
    NamedTuple{Tuple(names), Tuple{types...}}
end

"construct a named tuple from `x`"
@generated function fuse(args...)
	# constructor call
	tuptyp = Expr(:quote, tuple_type(args...))
	
	# constructor arguments
	tup = Expr(:tuple)
    # iterate indices, @generated only catches 'args'
    for a in eachindex(args)
        for i in 1:fieldcount(args[a])
            push!(tup.args, :(getfield(args[$a], $i)) )
        end
    end
	
	# both put together
	:($tuptyp($tup))
end


function dump_header(io, obj, FS="\t")
    fns = join(fieldnames(typeof(obj)), FS)
    print(io, fns)
end

function dump_property(io, prop, FS="\t", ES=",")
    print(io, prop)
end

function dump_property(io, prop::Rational, FS="\t", ES=",")
    print(io, Float64(prop))
end

function dump_property(io, prop::Vector, FS="\t", ES=",")
    print(io, "(") 
    for (i, el) in enumerate(prop)
        dump_property(io, el, FS, ES)
        if i != length(prop)
        	print(io, ES)
        end
    end
    print(io, ")")
end

function dump_property(io, prop::Matrix, FS="\t", ES=",")
    print(io, "(") 
    for i in 1:size(prop)[1]
        print(io, "(") 
        for j in 1:size(prop)[2]
            el = prop[i, j]
            dump_property(io, el, FS, ES)
            if j != size(prop)[2]
            	print(io, ES)
            end
        end
        print(io, ")")
        if i != size(prop)[1]
        	print(io, ES)
        end
    end
    print(io, ")")
end

function dump(io, obj, FS="\t", ES=",")
    for (i, f) in enumerate(fieldnames(typeof(obj)))
        dump_property(io, getfield(obj, f), FS, ES)
        if i != fieldcount(typeof(obj))
            print(io, FS)
        end
    end
end


mutable struct WeightSampler{LIST}
    weights :: LIST
    wSum :: Float64
end

WeightSampler(weights::LIST) where {LIST} = WeightSampler(weights, sum(weights))

function sampleNoReplace!(sampler)
    r = rand() * sampler.wSum
    i = 1
    while  (r -= sampler.weights[i]) > 0  
        i += 1
    end
    
    sampler.wSum -= sampler.weights[i]
    sampler.weights[i] = 0.0
    
    i
end

function sampleNoReplaceFrom!(sampler, list, n)
    @assert length(sampler.weights) == length(list)
    res = Vector{eltype(list)}()
    for i in 1:n
        push!(res, list[sampleNoReplace!(sampler)])
    end
    res
end

function resetSampler!(sampler, sz=0)
    resize!(sampler.weights, sz)
    sampler.wSum = 0
end

function initWeight!(sampler, i, val=0.0)
    sampler.weights[i] = val
    sampler.wSum += val
end

function mapWeights!(fn, sampler, list)
    resetSampler!(sampler, length(list))
    for (i, e) in enumerate(list)
        initWeight!(sampler, i, fn(e))
    end
end

end # module Utilities  
