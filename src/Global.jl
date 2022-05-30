# Set of all global variables shared among modules 
module Global

    export Gender 
    export SimulationFolderPrefix

    # list of types 

    "Gender type enumeration"
    @enum Gender unknown female male 


    # list of global variables

    "Folder in which simulation results are stored"
    const SimulationFolderPrefix = "Simulations_Folder"
    
    # timeStamp ... 

end