"""
Diverse useful functions 
"""
module Utilities

    export createTimeStampedFolder, readFromCSVFile, subtract! 

    """
       Subtract keys from a given dictionary
       @argument dict : input dictionary 
       @argument ks   : input keys
       @throws  ArgumentError if a key in keys not available in dict  
       @return a new dictionary with exactly the specified keys 
    """ 
    function subtract!(dict::Dict,ks::Vector{Symbol}) 
        if  ks ⊈  keys(dict) 
            throw(ArgumentError("$keys ⊈  $(keys(dict))")) 
        end 
        newdict = Dict{Symbol,Any}()  
        for k in ks 
            newdict[k] = dict[k] 
            delete!(dict,k) 
        end 
        newdict 
    end

    "" 
    subtract!(keys::Vector{Symbol},dict::Dict) = subtract!(dict,keys)

    "" 
    Base.:(-)(dict::Dict,keys::Vector{Symbol}) = subtract!(dict,keys) 

    """ 
       Read an array of values from CSV file name and return an array of values 
       vvv
       a way to read it as multidimensional array 
    """
    function readArrayFromCSVFile(csvfname::String)
        # CSVfname should ends with *.csv 
        nothing 
    end 

    # useful built-in functions: 
    # function ispath(str) check the existance of a file or a directory 
    # isdir(str), isfile(str)

    "create a folder in which simulation results are stored"
    function createTimeStampedFolder() 
        #timeStamp = datetime.datetime.today().strftime('%Y_%m_%d-%H_%M_%S')
        #folder = os.path.join('Simulations_Folder', timeStamp)
        #if not os.path.exists(folder):
        #    os.makedirs(folder)
        # folder
        "" 
    end

    # 
    # reading and writing a file 
    # try 
    #   fin = fopen("input.txt",mode)
    # catch exc
    #   println("$exc")
    # finally
    #   close(fin)
    # 
    
    # run(command)
end 