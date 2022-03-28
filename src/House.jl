import Agent.AbstractAgent
import Agent.Agent 
import Agent.DataSpec

module House

    export  House, HouseData

    # type House to extend from AbstractAgent

    #= 
    Does house data need to be mutable during a simulation course?
    if yes, then declare the following struct as mutable 
    [mutable] struct HouseData <: DataSpec
        location 
        size
        ... 
    end
    =# 
    struct HouseData <: DataSpec
    end 

    const House  = Agent{HouseData} 


end