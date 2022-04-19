"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/...")
julia> include("RunTests.jl")
"""

using AgentTypes, GroupTypes, Test, Utilities

@testset "Lone Parent Model combonents testing" begin 

    @testset verbose=true "Basic declaration" begin
        person1 = Person() 
    
        # skip implies that the test is broken indicating a non-implemented functionality
        @test person1.id > 0               skip=false         # every agent should have a unique id 
        @test person1.location != nothing  skip=false         # every agent should be assigned with a location        
  
        house = House() 
        @test house.id > 0                skip=false 
        @test house.location != nothing   skip=false
        @test_throws MethodError person2 = Person(person1)  # copy constructor should not be implm,ented 
    
        person2 = person1                                   # This is just an alais 
        @test person1 === person2

        person3 = Person() 
        @test getID(person3) != getID(person2) skip=false                  # A new person is another person    
  
        @test (pop = Population()) != nothing              # Population means something 

        @test household = Household() != nothing           # a household instance is something 

        @test_throws UndefVarError town = Town()           # Town class is not yet implemented 
        @test town = Town()                    skip=true  
    end 

    # detect_ambiguities(AgentTypes)


    @testset verbose=true "Utilities" begin
        simfolder = createTimeStampedFolder()
        @test !isempty(simfolder)              skip=false 
        @test isdir(simfolder)                 skip=false 
    end

end  # Lone Parent Model main components 