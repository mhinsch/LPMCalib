# LoneParentsModel.jl
An initial implementation of an ABM aiming at a social and child care simulation. 


# Releases
- V0.1: Initial concepts of agents, ABMs and a dummy exmaple are realized. Basic interfaces of the Package Agents.jl are imitated in order to fully exploit Agents.jl in future. 

# Source code structure 
- /src
  - SocialAgents.jl : Basic concept of an Agent
  - /agents/*       : Examples of agents 
  - SocialABMs.jl   : Basic concept of an elementary ABM
  - /abms/*         : Examples of abms
  - MainDummy.jl    : An example of a dummy simulation
  - SocialDummySimulation.jl
                    : the main functionalities of execcuting an ABM
  - Spaces.jl       : Spaces on which ABM and its agents are operating  
- /tests


# Running the code
See the head documentation of RunTests.jl and MainDummy.jl 
