"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/LoneParentsModels.jl/src")
julia> include("RunTests.jl")
"""

using SocialAgents, SocialABMs, Test, Utilities

import SocialAgents: getindex, getposition 

@testset "Lone Parent Model combonents testing" begin 

    @testset verbose=true "Basic declaration" begin
        person1 = Person(1,"Glasgow",45) 
    
        # skip implies that the test is broken indicating a non-implemented functionality
        @test getindex(person1) > 0                 skip=false         # every agent should have a unique id 
        @test getposition(person1) != nothing       skip=false         # every agent should be assigned with a location        
  
        house = House(2,"Edinburgh","small") 
        @test house.id > 0                           skip=false 
        @test house.pos != nothing                   skip=false
    
        person2 = person1                                               # This is just an alais 
        @test person1 === person2

        person3 = Person(3,"Aberdeen",45) 
        @test getindex(person3) != getindex(person2) skip=false         # A new person is another person    
  
    end 

    # detect_ambiguities(AgentTypes)

    #=
        testing SocialABMs TODO 

        @test (pop = Population()) != nothing                           # Population means something 
        @test household = Household() != nothing                        # a household instance is something 

        @test_throws UndefVarError town = Town()                        # Town class is not yet implemented 
        @test town = Town()                          skip=true  
    =# 

    # TODO testing SocialABMs once designed

    # TODO testing stepping functions once design is fixed 

    @testset verbose=true "Utilities" begin
        simfolder = createTimeStampedFolder()
        @test !isempty(simfolder)                    skip=false 
        @test isdir(simfolder)                       skip=false 
    end

end  # Lone Parent Model main components 