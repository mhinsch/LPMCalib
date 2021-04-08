module MiniSimObserve

using Reexport

include("Observation.jl")
include("StatsAccumulator.jl")

@reexport using .Observation
@reexport using .StatsAccumulator
#using .Observation
#using .StatsAccumulator


import .Observation.prefixes
prefixes(::Type{CountAcc}) = ["#"]
prefixes(::Type{<:MeanVarAcc}) = ["mean", "var"]
prefixes(::Type{<:MaxMinAcc}) = ["max", "min"]


import .Observation.printable
printable(acc :: CountAcc, FS="\t") = acc.n
printable(acc :: MaxMinAcc, FS="\t") = (acc.max, FS, acc.min)
function printable(acc :: MeanVarAcc, FS="\t")
	res = result(acc)
	(res[1], FS, res[2])
end

end # module
