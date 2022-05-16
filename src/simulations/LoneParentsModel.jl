"""
    just a list of [stepping] functions to operate a Multi ABM 
    design of function arguments and return values to be specified later
""" 

module LoneParentsModel

    export createPopulation, loadData!

    import SocialAgents: Person
    import SocialABMs: SocialABM 
    import SocialSimulations: SocialSimulation, setProperty!

    "Create an empty population initially with no agents"
    function createPopulation() 
        population = SocialABM{Person}()
    end

    function loadData!(simulation::SocialSimulation)
        loadMetaParameters!(simulation)
    end 

    function loadMetaParameters!(simulation::SocialSimulation) 
       
        meta = Dict()

        simulation.properties[:meta] = meta 

        meta["numRepeats"] = 1
        meta["initialPop"] = 500
        meta["startYear"] = 1860            
        setProperty!(simulation,:startTime,meta["startYear"])
        meta["endYear"] = 2040 
        setProperty!(simulation,:finishTime,meta["endYear"])              
        meta["thePresent"] = 2012
        meta["statsCollectFrom"] = 1960
        meta["policyStartYear"] = 2020
        meta["outputYear"] = 2015
       
        # a population of males to be randomly generated in the 
        # range of minStartAge - maxStartAge
        meta["minStartAge"] = 24                  
        meta["maxStartAge"] = 45                  
       
        meta["verboseDebugging"] = false
        meta["singleRunGraphs"] = false                           # ?? 
        meta["withBenefits"] = true                               # ?? 
        meta["externalCare"] = true                               # ?? 
        meta["careAllocationFromYear"] = meta["startYear"]
        meta["favouriteSeed"] = floor(Int,time())
        meta["loadFromFile"] = false
        meta["numberClasses"] = 5                                 # ?? Socio-econimic classes
        meta["numCareLevels"] = 5
        meta["timeDiscountingRate"] = 0.035                       # ??
        
        # Description of the map and towns: 
        #   The space is represented by a 2-level grid.  At the higher level, 
        #   an mapGridYDimension x mapGridXDimension grid roughly represents 
        #   the UK map. Each cell in this high-level grid is composed by 
        #   a townGridDimension-grid, which represents the space at the lower level.
        meta["mapGridXDimension"] = 8
        meta["mapGridYDimension"] = 12    
        meta["townGridDimension"] = 5 * 5                          
        
        ## Description of houses 
        meta["numHouseClasses"] = 3                
        meta["houseClasses"] = ["small","medium","large"]
        meta["cdfHouseClasses"] = [ 0.6, 0.9, 5.0 ]               # comulative distribution function
        meta["shareClasses"] = [0.2, 0.23, 0.25, 0.22, 0.1]       # ?? Socio-economic classes?
        meta["classAdjustmentBeta"] = 3.0                         # ??
    

        #======================================
        Warning: in the following, original implementation
                 was conducted using 1-D arrays rather 
                 than 2D matrices 
        =#####################################

        # Relative population density of UK.  A density of 1.0 corresponds to 
        #   the cell with the highest density   
        meta["ukMap"] = [0.0 0.1 0.2 0.1 0.0 0.0 0.0 0.0;
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
    
        # ?? looks like deviation from the average 
        meta["ukClassBias"] = [0.0  -0.05 -0.05 -0.05  0.0   0.0  0.0  0.0;
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
        
        # ?? 
        meta["lha_1"] = [0.0    91.81  91.81  91.81  0.0    0.0    0.0    0.0;
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
        meta["lha_2"] = [0.0    110.72 110.72 110.72 0.0    0.0    0.0    0.0;
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
        meta["lha_3"] = [0.0    126.92 126.92 126.92 0.0    0.0    0.0    0.0;
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
        meta["lha_4"] = [0.0    160.38 160.38 160.38 0.0    0.0    0.0    0.0;
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
        
        meta["mapDensityModifier"] = 0.6                          # ??
        
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

        #= multiprocessing params
        meta["multiprocessing"] = false
        meta["numberProcessors"] = 10
        meta["debuggingMode"] = true
        =# 

        #=
        # Document all meta parameters in an (possibly existing) external file
        folder = "defaultSimFolder"
        if not os.path.exists(folder):
            os.makedirs(folder)
        filePath = folder + "/metaParameters.csv"
        c = m.copy()
        for key, value in c.iteritems():
            if not isinstance(value, list):
                c[key] = [value]
        with open(filePath, "wb") as f:
            csv.writer(f).writerow(c.keys())
            csv.writer(f).writerows(itertools.izip_longest(*c.values()))
        =#     

        nothing 
    end


    function doDeaths() end 
    function doAdoptions() end 
    function oneTransition_UCN() end
    function computeIncome() end 
    function updateWealthInd() end
    function jobMarket() end
    function computeAggregateSchedule() end 
    function startCareAllocation() end 
    function allocateWeeklyCare() end 
    function updateUnmetCare() end 
    function updateUnmetCareNeed() end 
    function doAgeTransition() end 
    function doSocialTransitions() end 
    function houseOwnership() end 
    function computeBenefits() end 
    function doBirths() end 
    function doDevorces() end 
    function doMarriages() end 
    function doMovingAround() end
    function selfPyramidUpdate() end
    function healthcareCost() end
    function doStats() end  

end # Module LoneParentsModel