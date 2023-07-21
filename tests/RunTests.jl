"""
Run this script from shell as 
# julia tests/RunTests.jl

or within REPL

julia> include("tests/RunTests.jl")
"""

include("../loadLibsPath.jl")

using Test

using XAgents: Person, House, Town

using MultiAgents: verifyAgentsJLContract 

# BasicInfo module 
using XAgents: alive, setDead!, age, agestep!, agestepAlive!
using XAgents: isFemale, isMale

# Kinship Module 
using XAgents: father, mother, children, partner, isSingle 
using XAgents: setAsParentChild!, setAsPartners!, resolvePartnership!, resetPartner!

# Person type 
using XAgents: setHouse!, getHomeTown, getHomeTownName, getHouseLocation, resetHouse!, undefined 

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
        
        @test verifyAgentsJLContract(glasgow) 
        @test verifyAgentsJLContract(house1)
        @test verifyAgentsJLContract(person1)

        # Testing that every agent should have a unique ID 
        @test person1.id > 0                        
        @test house1.id != person1.id       
        @test person3.id != person1.id                  # A new person is another person   

        # every agent should be assigned with a location        
        @test person1.pos == house1   
        @test person1 in house1.occupants     

        @test person1 === person2 
    end 

    @testset verbose=true "BasicInfo Module" begin 

        @test typeof(person1.age) == Rational{Int64} 
        @test isMale(person1)
        @test !isFemale(person1)
        @test person1.alive 
        
        person7 = Person(house1,25,gender=male) 
        setDead!(person7)
        @test !person7.alive

        agestepAlive!(person7)
        @test person7.age < 25.01 
        agestep!(person7) 
        @test person7.age > 25

    end

    @testset verbose=true "Kinship Module" begin 
        
        setAsParentChild!(person1,person6) 
        @test person1 in person6.kinship.children
        @test person1.father === person6 

        setAsParentChild!(person2,person4) 
        @test person2.mother === person4
        @test person2 in person4.kinship.children 

        @test isSingle(person1)
        setAsPartners!(person1,person4)
        @test !isSingle(person4) 
        @test person1.partner === person4 && person4.partner === person1 

        @test_throws InvalidStateException setAsPartners!(person3,person4) # same gender 

        @test_throws InvalidStateException setAsParentChild!(person4,person5)  # unknown gender 
        @test_throws ArgumentError setAsParentChild!(person4,person1)          # ages incompatibe / well they are also partners  
        @test_throws ArgumentError setAsParentChild!(person2,person3)          # person 2 has a mother 

        resolvePartnership!(person4,person1) 
        @test isSingle(person4)
        @test person1.partner !== person4 && person4.partner != person1
        @test_throws ArgumentError resolvePartnership!(person1,person4) 

    end

    @testset verbose=true "Type Person" begin
        @test getHomeTown(person1) != nothing             
        @test getHomeTownName(person1) == "Edinbrugh"    

        setAsPartners!(person4,person6) 
        @test !isSingle(person6)
        @test !isSingle(person4)

        person7 = Person(pos=person4.pos,gender=male,mother=person4,father=person6)
        @test person7.father === person6
        @test person7.mother === person4 
        @test person7 ∈ person4.children 
        @test person7 ∈ person6.children
        
        resetPartner!(person4) 
        @test isSingle(person6)
        @test isSingle(person4)
    end 

    @testset verbose=true "Type House" begin

        @test house1.id > 0                    
        @test house1.pos != nothing         
        @test getHomeTown(house1) === edinbrugh 
        @test getHouseLocation(house1) == (1,2)

        setHouse!(person1,house2) # person1.pos = house2       
        @test getHomeTown(person1) === aberdeen   
        @test person1 in house2.occupants   
        
        setHouse!(person4,house2)
        @test getHomeTown(person4) === aberdeen    

        person1.pos = house1 
        @test_throws ArgumentError setHouse!(person1,house3)
        person1.pos = house2

        resetHouse!(person4)
        @test undefined(person4.pos)

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
