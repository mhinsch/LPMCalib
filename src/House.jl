import Agent.AbstractAgent
import Agent.Agent 
import Agent.DataSpec

module House

    # type House to extend from AbstractAgent

    #= 
    Does house data need to be mutable during a simulation course?
    [mutable] struct HouseData <: DataSpec
        location 
        size
        ... 
    end

    const House  = Agent{HouseData} 
    =# 

end