using AgentTypes, GroupTypes, Test

@testset verbose=true "Basic declaration" begin
    person1 = Person() 
    @test person1  != nothing 
    @test (house  = House())  != nothing
    @test_throws MethodError person2 = Person(person1)
    person2 = person1 
    @test person1 === person2
    person3 = Person() 
    @test person3 != person2 skip=true  
    @test (pop = Population()) != nothing 
    @test household = Household() != nothing 
    @test_throws UndefVarError town = Town()
end 


