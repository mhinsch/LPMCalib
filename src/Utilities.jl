"""
Diverse useful functions and types 
"""
module Utilities

    using CSV, Tables     # for reading 2D matrices from a file

    export createTimeStampedFolder, read2DArray, subtract! 

    """
       Subtract keys from a given dictionary
       @argument dict : input dictionary 
       @argument ks   : input keys
       @throws  ArgumentError if a key in keys not available in dict  
       @return a new dictionary with exactly the specified keys 
    """ 

    function  subtract!(ks::Vector{Symbol},dict::Dict) 
        if  ks ⊈  keys(dict) 
            throw(ArgumentError("$ks ⊈  $(keys(dict))")) 
        end 
        newdict = Dict{Symbol,Any}()  
        for key in ks 
            newdict[key] = dict[key] 
            delete!(dict,key) 
        end 
        newdict 
    end 

    "" 
    Base.:(-)(ks::Vector{Symbol},dict::Dict) = subtract!(ks,dict) 

    "Read and return a 2D array from a file without a header"
    function read2DArray(fname::String)
        CSV.File(fname,header=0) |> Tables.matrix
    end 

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