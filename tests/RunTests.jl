"""
Run this script from shell as 
# JULIA_LOAD_PATH="/path/to/LoneParentsModel.jl/src:\$JULIA_LOAD_PATH" julia RunTests.jl

or within REPL

julia> push!(LOAD_PATH,"/path/to/LoneParentsModels.jl/src")
julia> include("RunTests.jl")
"""

using Test

using XAgents: Person, House, Town

using MultiAgents: verify 
using XAgents: isFemale, isMale
using XAgents: setAsParentChild!, setAsPartners!, setHouse!
using XAgents: resolvePartnership!
using XAgents: getHomeTown, getHomeTownName, getHouseLocation 

using Utilities: HouseLocation

using Utilities:  createTimeStampedFolder

using Utilities: Gender, male, female, unknown 

@testset "Lone Parent Model Components Testing" begin 

    # List of towns 
    glasgow   = Town((10,10),name="Glasgow") 
    edinbrugh = Town((11,12),name="Edinbrugh")
    sterling  = Town((12,10),name="Sterling") 
    aberdeen  = Town((20,12),name="Aberdeen")

    # List of houses 
    house1 = House{Person}(edinbrugh,(1,2)::HouseLocation) 
    house2 = House{Person}(aberdeen,(5,10)::HouseLocation) 
    house3 = House{Person}(glasgow,(2,3)::HouseLocation) 

    # List of persons 
    person1 = Person(house1,25,gender=male) 
    person2 = person1               
    person3 = Person(house2,35,gender=female) 
    person4 = Person(house1,40,gender=female) 
    person5 = Person(house3,55,gender=unknown)
    person6 = Person(house1,55,gender=male) 

    @testset verbose=true "Basic declaration" begin
        @test_throws MethodError person4 = Person(1,house1,22)         # Default constructor is disallowed
        
        @test verify(glasgow) 
        @test verify(house1)
        @test verify(person1)

        # Testing that every agent should have a unique ID 
        @test person1.id > 0                        
        @test house1.id != person1.id       
        @test person3.id != person1.id                  # A new person is another person   

        # every agent should be assigned with a location        
        @test person1.pos == house1   
        @test person1 in house1.occupants     

        @test person1 === person2 
    end 

    @testset verbose=true "Type Person" begin
        @test getHomeTown(person1) != nothing             
        @test getHomeTownName(person1) == "Edinbrugh"    
        
        @test typeof(person1.info.age) == Rational{Int64} 
        
        @test isMale(person1)
        @test !isFemale(person1)
        
        setAsParentChild!(person1,person6) 
        @test person1 in person6.kinship.children
        @test person1.kinship.father === person6 

        setParent!(person2,person4) 
        @test person2.kinship.mother === person4
        @test person2 in person4.kinship.children 

        setPartner!(person1,person4) 
        @test person1.kinship.partner === person4 && person4.kinship.partner === person1 

        @test_throws InvalidStateException setPartner!(person3,person4) # same gender 

        @test_throws InvalidStateException setParent!(person4,person5)  # unknown gender 
        @test_throws ArgumentError setAsParentChild!(person4,person1)          # ages incompatibe / well they are also partners  
        @test_throws ArgumentError setAsParentChild!(person2,person3)          # person 2 has a mother 

        resolvePartnership!(person4,person1) 
        @test person1.kinship.partner !== person4 && person4.kinship.partner != person1
        @test_throws ArgumentError resolvePartnership!(person1,person4) 
    end 

    @testset verbose=true "Type House" begin

        @test house1.id > 0                    
        @test house1.pos != nothing         
        @test getHomeTown(house1) === edinbrugh 
        @test getHouseLocation(house1) == (1,2)

        setHouse!(person1,house2) # person1.pos = house2       
        @test getHomeTown(person1) === aberdeen   
        @test person1 in house2.occupants   
        
        setHouse!(house2,person4)
        @test getHomeTown(person4) === aberdeen    

        person1.pos = house1 
        @test_throws InvalidStateException setHouse!(person1,house3)
        person1.pos = house2

    end # House functionalities 

    # detect_ambiguities(AgentTypes)

    #=
        testing ABMs TODO 

        @test (pop = Population()) != nothing                           # Population means something 
        @test household = Household() != nothing                        # a household instance is something 

        @test_throws UndefVarError town = Town()                        # Town class is not yet implemented 
        @test town = Town()                          skip=true  
    =# 

    # TODO testing ABMs once designed

    # TODO testing stepping functions once design is fixed 

    @testset verbose=true "Utilities" begin
        simfolder = createTimeStampedFolder()
        @test !isempty(simfolder)                            
        @test isdir(simfolder)
    end

    @testset verbose=true "Lone Parent Model Simulation" begin

        #= 

        To re-implement 
        
        using  SocialSimulations: SocialSimulation
       

        simProperties = LoneParentsModel.loadSimulationParameters()
        lpmSimulation = SocialSimulation(LoneParentsModel.createPopulation,simProperties)

        @test LoneParentsModel.loadMetaParameters!(lpmSimulation) != nothing  skip=true
        @test LoneParentsModel.loadModelParameters!(lpmSimulation) != nothing skip=false
        @test LoneParentsModel.createShifts!(lpmSimulation) != nothing        skip=false 
        =# 

    end 

end  # Lone Parent Model main components 