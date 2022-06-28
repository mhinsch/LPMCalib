"""
Diverse useful functions and types 
"""
module Utilities

    # Types 
    export Gender 

    # Constants 
    export SimulationFolderPrefix

    # Functions
    export createTimeStampedFolder


    # list of types 

    "Gender type enumeration"
    @enum Gender unknown female male 


    # constants 

    "Folder in which simulation results are stored"
    const SimulationFolderPrefix = "Simulations_Folder"
    
    # timeStamp ... 

    "create a folder in which simulation results are stored"
    function createTimeStampedFolder() 
        #timeStamp = datetime.datetime.today().strftime('%Y_%m_%d-%H_%M_%S')
        #folder = os.path.join('Simulations_Folder', timeStamp)
        #if not os.path.exists(folder):
        #    os.makedirs(folder)
        # folder
        "" 
    end
 
end 