"""
Diverse useful functions 
"""
module Utilities

    export createTimeStampedFolder

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