"""
Diverse useful functions and types 
"""
module Utilities

    # Types 
    export Gender 
    export Map4DLocation, TownLocation, HouseLocation 

    # Constants 
    export SimulationFolderPrefix

    # Functions
    export createTimeStampedFolder, p_yearly2monthly, applyTransition!

    # list of types 

    "Gender type enumeration"
    @enum Gender unknown female male 

    const Map4DLocation = NTuple{4,Int}

    const TownLocation  = NTuple{2,Int}

    const HouseLocation  = NTuple{2,Int}

    p_yearly2monthly(p) = 1 - (1-p)^(1/12)

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


"Apply a transition function to an iterator."
function applyTransition!(people, transition, time, model, pars, name = "", verbose = true)
    count = 0
    for p in people 
        transition(p, time, model, pars, verbose)
        count += 1
    end

    if verbose && name != ""
        println(count, " agents in ", name)
    end
end

 
end 
