# LoneParentsModel.jl
An initial implementation of an ABM aiming at a social and child care simulation. 


### Releases
- **V0.1** (11-05-2022): Initial concepts of agents, ABMs and a dummy exmaple are realized. Basic interfaces of the Package Agents.jl are imitated in order to fully exploit Agents.jl in future. 
  - V0.1.1: Improved concept for an ABM and data structure for a simulation    
  - V0.1.2: Improved concepts for Social Simulation, Social ABMs, started translation of LPM & further unit tests 
- **V0.2** (30-05-2022): improved unification potentials with Agents.jl, improved agents subtypes, SocialABM with a constructor with an argument as a declare function, First realization of a multiABM concept, Initialization of the demography model
  - V0.2.1: unnecessary code removed, additional functionalities, exception handling, Unit testing (Person & House)
  - V0.2.2: Distributing properties among smaller ABMs, Separation between declaration and initialisation, utilisation of built-in exceptions, Agent person tuning + unit tests
  - v0.2.3: re-structure of examples, improved printing 
  - v0.2.4: simulation concept 
- **V0.3** (23.06.2022): Improved simulation concep, Flexibility for simulating same example with different implementation (via type traits), Population
simulation considering death probabilities 
  - v0.3.1: The abstract conceptual part of the code moved to MultiAgents.jl 
  - v0.3.2: Kinship & BasicInfo modules for the type Person 


### Source code structure 
- /src
  - XAgents.jl : Basic concept of an Agent
  - /agents/*       : Examples of agents 
  - MultiABMs.jl   : Basic concept of elementary ABMs
  - /abms/*         : Examples of abms and useful step functions 
  - LoneParentsModel.jl : Main modules for realizing LPM.jl 
  - /lpm                  submodules for declaring, initializing and simulating lpm 
  - Utilities.jl    : util routines used across the library
- /tests
- MainDummy.jl    : An example of a dummy simulation
- MainLPM.jl      : Initial (empty) translation of LPM
- loadLibsPath    : load paths to internal libraries


### Running the code
See the head documentation of RunTests.jl and MainDummy.jl 
dummy edit 
