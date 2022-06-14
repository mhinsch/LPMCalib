module Loaders 

export loadUKMapParameters, loadUKPopulationParameters


function loadUKMapParameters()
    mappars = Dict(:dummy=>any,:mapGridXDimension=>8)::Dict{Symbol,Any} 

    # mappars[:mapGridXDimension] = 8
    mappars[:mapGridYDimension] = 12    
    mappars[:townGridDimension] = 25    

        # Relative population density of UK.  A density of 1.0 corresponds to 
    #   the cell with the highest density   
   
    mappars[:ukMap] = [0.0 0.1 0.2 0.1 0.0 0.0 0.0 0.0;
                       0.1 0.1 0.2 0.2 0.3 0.0 0.0 0.0;
                       0.0 0.2 0.2 0.3 0.0 0.0 0.0 0.0;
                       0.0 0.2 1.0 0.5 0.0 0.0 0.0 0.0;
                       0.4 0.0 0.2 0.2 0.4 0.0 0.0 0.0;
                       0.6 0.0 0.0 0.3 0.8 0.2 0.0 0.0;
                       0.0 0.0 0.0 0.6 0.8 0.4 0.0 0.0;
                       0.0 0.0 0.2 1.0 0.8 0.6 0.1 0.0;
                       0.0 0.0 0.1 0.2 1.0 0.6 0.3 0.4;
                       0.0 0.0 0.5 0.7 0.5 1.0 1.0 0.0;
                       0.0 0.0 0.2 0.4 0.6 1.0 1.0 0.0;
                       0.0 0.2 0.3 0.0 0.0 0.0 0.0 0.0] 


     #= not considered yet 
    # ?? looks like deviation from the average 
    meta[:ukClassBias] = [0.0  -0.05 -0.05 -0.05  0.0   0.0  0.0  0.0;
                          -0.05 -0.05  0.0   0.0   0.0   0.0  0.0  0.0;
                           0.0  -0.05 -0.05  0.0   0.0   0.0  0.0  0.0;
                           0.0  -0.05 -0.05  0.05  0.0   0.0  0.0  0.0;
                          -0.05  0.0  -0.05 -0.05  0.0   0.0  0.0  0.0;
                          -0.05  0.0   0.0  -0.05 -0.05 -0.05 0.0  0.0;
                           0.0   0.0   0.0  -0.05 -0.05 -0.05 0.0  0.0;
                           0.0   0.0  -0.05 -0.05  0.0   0.0  0.0  0.0;
                           0.0   0.0  -0.05  0.0  -0.05  0.0  0.0  0.0;
                           0.0   0.0   0.0  -0.05  0.0   0.2  0.15 0.0;
                           0.0   0.0   0.0   0.0   0.1   0.2  0.15 0.0;
                           0.0   0.0   0.1   0.0   0.0   0.0  0.0  0.0] 
    
    #
    # Local house allowances for houses with 1,2,3 and 4-bed room houses 
    meta[:lha_1] = [0.0    91.81  91.81  91.81  0.0    0.0    0.0    0.0;
                     91.81  91.81  91.81  91.81  97.81  0.0    0.0    0.0;
                     0.0    91.81  91.81  79.24  0.0    0.0    0.0    0.0;
                     0.0    84.23  94.82  127.33 0.0    0.0    0.0    0.0;
                     0.0    0.0    80.55  72.00  74.15  0.0    0.0    0.0;
                     0.0    0.0    0.0    79.24  90.90  83.78  0.0    0.0;
                     0.0    0.0    0.0    85.00  100.05 69.73  0.0    0.0;
                     0.0    0.0    71.41  105.04 94.80  90.90  90.64  0.0;
                     0.0    0.0    65.59  92.05  101.84 106.14 133.72 95.77;
                     0.0    0.0    103.56 132.43 163.67 276.51 165.05 0.0;
                     0.0    0.0    116.52 105.94 120.03 222.54 170.83 0.0;
                     0.0    104.89 96.98  0.0    0.0    0.0    0.0    0.0]
    
    # ?? 
    meta[:lha_2] = [0.0    110.72 110.72 110.72 0.0    0.0    0.0    0.0;
                     110.72 110.72 110.72 110.72 133.48 0.0    0.0    0.0;
                     0.0    110.72 110.72 103.85 0.0    0.0    0.0    0.0;
                     0.0    103.85 120.03 154.28 0.0    0.0    0.0    0.0;
                     0.0    0.0    97.81  92.05  87.45  0.0    0.0    0.0;
                     0.0    0.0    0.0    92.05  103.56 97.81  0.0    0.0;
                     0.0    0.0    0.0    113.92 122.36 86.30  0.0    0.0;
                     0.0    0.0    91.43  123.58 107.11 108.26 115.58 0.0;
                     0.0    0.0    86.00  117.37 127.62 134.00 153.79 120.02;
                     0.0    0.0    126.92 160.73 192.48 320.74 204.35 0.0;
                     0.0    0.0    141.24 136.93 161.07 280.60 210.17 0.0;
                     0.0    132.32 122.36 0.0    0.0    0.0    0.0    0.0]
    
    # ??
    meta[:lha_3] = [0.0    126.92 126.92 126.92 0.0    0.0    0.0    0.0;
                     126.92 126.92 126.92 126.92 172.60 0.0    0.0    0.0;
                     0.0    126.92 126.92 128.19 0.0    0.0    0.0    0.0;
                     0.0    120.29 137.31 192.06 0.0    0.0    0.0    0.0;
                     0.0    0.0    115.07 109.62 103.56 0.0    0.0    0.0;
                     0.0    0.0    0.0    104.89 115.07 114.00 0.0    0.0;
                     0.0    0.0    0.0    130.00 149.59 103.56 0.0    0.0;
                     0.0    0.0    110.41 137.32 116.53 123.90 133.35 0.0;
                     0.0    0.0    101.11 135.19 135.96 144.04 178.71 139.42;
                     0.0    0.0    150.00 192.03 230.14 376.04 257.16 0.0;
                     0.0    0.0    164.79 161.10 190.02 336.96 257.16 0.0;
                     0.0    151.50 145.43 0.0    0.0    0.0    0.0    0.0]
    
    # ??
    meta[:lha_4] = [0.0    160.38 160.38 160.38 0.0    0.0    0.0    0.0;
                     160.38 160.38 160.38 160.38 228.99 0.0    0.0    0.0;
                     0.0    160.38 160.38 189.07 0.0    0.0    0.0    0.0;
                     0.0    180.00 212.21 276.92 0.0    0.0    0.0    0.0;
                     0.0    0.0    158.90 142.61 138.08 0.0    0.0    0.0;
                     0.0    0.0    0.0    134.02 149.59 149.59 0.0    0.0;
                     0.0    0.0    0.0    150.00 195.62 132.33 0.0    0.0;
                     0.0    0.0    133.32 186.47 156.00 156.05 168.05 0.0;
                     0.0    0.0    126.58 173.09 173.41 192.75 238.38 184.11;
                     0.0    0.0    190.38 257.09 299.18 442.42 331.81 0.0;
                     0.0    0.0    218.63 200.09 242.40 429.53 322.15 0.0;
                     0.0    185.29 182.45 0.0    0.0    0.0    0.0    0.0]
    
    =# 

    mappars[:mapDensityModifier] = 0.6                          # for allocating houses in towns 

    mappars
end


function loadUKPopulationParameters() 
    # TODO this is going to change after identifying a better 
    # data structure for parameters 
    poppars = Dict(:dummy=>any,:initialPop=>500)  # Population parameters  

    # a population of males to be randomly generated in the 
    # range of minStartAge - maxStartAge
    poppars[:minStartAge] = 24                  
    poppars[:maxStartAge] = 45    

    # TODO this parameter does not belong here. It is a simulation parameters
    poppars[:startYear]   = 1860 

    poppars 
end




"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic SocialSimulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
function loadSimulationParameters() 
Dict(:numRepeats=>1,
     :startTime=>1860,
     :endTime=>2040,
     :dt=>1//12,
     :seed=> floor(Int,time()))

#= multiprocessing params
meta["multiprocessing"] = false
meta["numberProcessors"] = 10
meta["debuggingMode"] = true
=# 

#= Graphical interface details
meta["interactiveGraphics"] = false
meta["delayTime"] = 0.0
meta["screenWidth"] = 1300
meta["screenHeight"] = 700
meta["bgColour"] = "black"
meta["mainFont"] = "Helvetica 18"
meta["fontColour"] = "white"
meta["dateX"] = 70
meta["dateY"] = 20
meta["popX"] = 70
meta["popY"] = 50
meta["pixelsInPopPyramid"] = 2000
meta["careLevelColour"] = ["blue","green","yellow","orange","red"]
# ?? number of colors = number of house classes x 2
meta["houseSizeColour"] = ["blue","green","yellow","orange","red", "lightgrey"]
meta["pixelsPerTown"] = 56
meta["maxTextUpdateList"] = 22
=# 
end 



end # Loaders 