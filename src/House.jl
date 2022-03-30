"""
Specification of a House Agent Type. This file is included in the module AgentTypes
Type House to extend from AbstractAgent.
""" 

#=
If the code in this file to be included seperately, use the following imports 

import AgentTypes: AbstractAgent, Agent, DataSpec
=# 

export  House, HouseData

#= 
Does house data need to be mutable during a simulation course?
if yes, then declare the following struct as mutable 
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
