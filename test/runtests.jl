include("../src/MiniSimObserve.jl")
using .MiniSimObserve

using Test

struct Agent
	capital :: Float64
	n :: Int
end

has_neighbours(a) = a.n > 0

struct Model
	time :: Float64
	population :: Vector{Agent}
end

function Model()
	t = 10.0
	p = [Agent(0.0, 2), Agent(2.0, 0), Agent(1.0, 10)]

	Model(t, p)
end


@observe Data model begin
	@record "time"      model.time
	@record "N"     Int length(model.population)

	@for ind in model.population begin
	    @stat("capital", MaxMinAcc{Float64}) <| ind.capital
		@stat("n_alone", CountAcc)           <| !has_neighbours(ind)
	end
end


@testset "Analysis" begin

m = Model()
result = observe(Data, m)

@test typeof(result) == Data
@test result.time == m.time
@test result.N == length(m.population)
@test result.capital.max == 2.0
@test result.capital.min == 0.0
@test result.n_alone.n == 1

end


@observe Data2 model user1 begin
	@record "time"      model.time
	@record "N"     Int length(model.population)

	@for ind in model.population begin
	    @stat("capital", MaxMinAcc{Float64}) <| ind.capital
		@stat("n_alone", CountAcc)           <| !has_neighbours(ind)
	end

	@record "user"		user1
end

@testset "User data" begin

m = Model()
result = observe(Data2, m, 42)

@test typeof(result) == Data2
@test result.time == m.time
@test result.N == length(m.population)
@test result.capital.max == 2.0
@test result.capital.min == 0.0
@test result.n_alone.n == 1
@test result.user == 42.0

end

