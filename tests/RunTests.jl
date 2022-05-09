"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/LoneParentsModels.jl/src")
julia> include("RunTests.jl")
"""

using SocialAgents, SocialABMs, Test, Utilities

import SocialAgents: getindex, getposition, setProperty! 

import SocialAgents: getHomeTown, getHomeTownName, getHouseLocation

import Spaces: HouseLocation

@testset "Lone Parent Model Components Testing" begin 

    @testset verbose=true "Basic declaration" begin
       
        glasgow   = Town((10,10),"Glasgow") 
        edinbrugh = Town((11,12),"Edinbrugh")
        sterling  = Town((12,10),"Sterling") 
        aberdeen  = Town((20,12),"Aberdeen")

        house1 = House(edinbrugh,(1,2)::HouseLocation,"small") 

        @test_throws MethodError person4 = Person(1,house1,22)                        # Default constructor should be disallowed

        person1 = Person(house1,45) 
        
        # skip implies that the test is broken indicating a non-implemented functionality
        @test getindex(person1) > 0                 skip=false         # every agent should have a unique id 
        @test getposition(person1) != nothing       skip=false         # every agent should be assigned with a location        
        @test getindex(house1) != getindex(person1)

        person2 = person1                                               # This is just an alais 
        @test person1 === person2

        house2 = House(aberdeen,(1,2)::HouseLocation,"small") 
        person3 = Person(house2,45) 
        @test getindex(person3) != getindex(person1) skip=false         # A new person is another person    
    end 


    @testset verbose=true "Type Person" begin
        glasgow = Town((10,10),"Glasgow") 
        house2 = House(glasgow,(1,2)::HouseLocation,"small") 
        person1 = Person(house2,45)  

        @test getHomeTown(person1) != nothing        skip=false 
        @test !isempty(getHomeTownName(person1))     skip=false  

        setProperty!(person1,:pos,house2)
        @test getHomeTown(person1) == glasgow     skip=false
    end 

    @testset verbose=true "Type House" begin

        edinbrugh = Town((11,12),"Edinbrugh")
        house = House(edinbrugh,(1,2),"small") 

        @test getindex(house) > 0                   skip=false 
        @test getposition(house) != nothing         skip=false
        @test getHomeTown(house) === edinbrugh 
        @test getHouseLocation(house) == (1,2)

    end # House functionalities 

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