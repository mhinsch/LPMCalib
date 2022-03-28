import Agent.AbstractAgent
import Agent.Agent
import Agent.DataSpec

module Person
    
    # type Person to inherit from AbstractAgent
    #=
     mutable struct PersonData <: DataSpec
        father 
        mother 
    end


    const Person = Agent{PersonData} 
    =# 

end