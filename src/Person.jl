import Agent.AbstractAgent
import Agent.Agent
import Agent.DataSpec

module Person

    export Person, PersonData
    
    # type Person to inherit from AbstractAgent
    #=
     mutable struct PersonData <: DataSpec
        father 
        mother 
    end
    =# 

    struct PersonData <: DataSpec
    end 

    const Person = Agent{PersonData}  

end