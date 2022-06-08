# Set of all global variables shared among modules 
module Global

    export Gender 
    export USEAGENTSJL, SimulationFolderPrefix

    # list of types 

    "Gender type enumeration"
    @enum Gender unknown female male 


    # list of global variables

    "whether the package Agents.jl shall be used" 
    const USEAGENTSJL = false 

    "Folder in which simulation results are stored"
    const SimulationFolderPrefix = "Simulations_Folder"
    
    # timeStamp ... 

end