"""
Run this script from shell as 
$ JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:$JULIA_LOAD_PATH" julia RunTests.jl

or with REPL

julia> push!(LOAD_PATH,"/path/to/...")
julia> include("RunTests.jl")
"""

using AgentTypes, GroupTypes, Test

@testset verbose=true "Basic declaration" begin
    person1 = Person() 
    @test person1  != nothing 
    @test (house  = House())  != nothing
    @test_throws MethodError person2 = Person(person1)
    person2 = person1 
    @test person1 === person2
    person3 = Person() 
    # The following test will fail since at the moment the person class is not implemented
    # skip implies that the test is broken indicating a non-implemented functionality
    @test person3 != person2 skip=true 
    @test person3 != person2 broken=true               
    @test (pop = Population()) != nothing 
    @test household = Household() != nothing 
    @test_throws UndefVarError town = Town() 
    @test town = Town() skip=true 
end 

# detect_ambiguities(AgentTypes)

