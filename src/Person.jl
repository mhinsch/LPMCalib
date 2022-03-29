#import AgentTypes: AbstractAgent, Agent, DataSpec

export Person, PersonData
    
# type Person to inherit from AbstractAgent
mutable struct PersonData <: DataSpec
#   father 
#   mother 
#   age 
#   ..
end

const Person = Agent{PersonData}  

