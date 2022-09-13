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
    export createTimeStampedFolder, p_yearly2monthly
    export @decl_setters, @decl_getters, @decl_getsetters

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
 
    function setter(field, type) 
        name = Symbol(String(field) * "!")
        :($(esc(name))(x::$(esc(type)), value) = (x.$field = value))
    end

    function getter(field, type) 
        :($(esc(field))(x::$(esc(type))) = x.$field)
    end

    macro decl_setters(type, fields...)
        Expr(:block, [setter(f, type) for f in fields]...)
    end

    macro decl_getters(type, fields...)
        Expr(:block, [getter(f, type) for f in fields]...)
    end

    macro decl_getsetters(type, fields...)
        Expr(:block, 
             [[setter(f, type) for f in fields] ;
              [getter(f, type) for f in fields]]...)
    end
end 
