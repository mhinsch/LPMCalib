"""
Specification of a House Agent Type. This file is included in the module AgentTypes
Type House to extend from AbstractAgent.

To test the code in this file seperate from the parent module, 
use the following code 

if not Symbol(:AgentTypes) in names(parentmodule(House),imported=true)
    # using AgentTypes The same as below
    import AgentTypes: AbstractAgent, Agent, DataSpec
end 
""" 

export  House, HouseData

#= 
Does house data need to be mutable during a simulation course?
if yes, then declare the following struct as mutable 
[mutable] struct HouseData <: DataSpec
location 
size
... 
end
=# 

"""
   HouseData: Data fields specifying an Agent of type House 
"""
struct HouseData <: DataSpec
    # location 
    # size
    # ... 
end 

"House Agent" 
const House  = Agent{HouseData} 
