"""
    just a list of [stepping] functions to operate a Multi ABM 
    design of function arguments and return values to be specified later
""" 

module LoneParentsModel

    export createPopulation, loadData!, loadSimulationParameters

    import SocialAgents: Person
    import SocialABMs: SocialABM 
    import SocialSimulations: SocialSimulation, setProperty!

    "Create an empty population initially with no agents"
    function createPopulation() 
        population = SocialABM{Person}()
    end

    function loadData!(simulation::SocialSimulation)
        loadMetaParameters!(simulation)
        loadModelParameters!(simulation)
        initSimulationVariables(simulation)
    end 

#=============================================
Simulation and model parameters initialization
=#############################################

    "set simulation paramters @return dictionary of symbols to values"
    function setSimulationParameters() 
        Dict(:numRepeats=>1,
             :startYear=>1860,
             :endYear=>2040,
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

    function loadMetaParameters!(simulation::SocialSimulation) 
       
        meta = Dict()

        simulation.properties[:meta] = meta 

        meta["thePresent"] = 2012
        meta["initialPop"] = 500
       
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
        meta["careAllocationFromYear"] = simulation.properties[:startYear]   # meta["startYear"]
        meta["favouriteSeed"] = simulation.properties[:seed] 
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

    "model parameters"
    function loadModelParameters!(simulation::SocialSimulation)

        parameters = Dict() 

        simulation.properties[:parameters] = parameters

         # Public Finances Parameters
        parameters["taxBrackets"] = [663, 228, 0]             # ?? Normalized numbers?
        parameters["taxationRates"] = [0.4, 0.2, 0.0]         # Standard taxation rates propertional to income
    
        parameters["statePension"] = 164.35
        parameters["minContributionPeriods"] = 35*12
        parameters["employeePensionContribution"] = 0.04
        parameters["employerPensionContribution"] = 0.03     
        parameters["statePensionContribution"] = 0.01
        parameters["pensionReturnRate"] = 0.05/12.0
        parameters["wealthToPoundReduction"] = 250.0          # ?? 
    
        # SES-version parameters
        parameters["maleMortalityBias"] = 0.8                
        parameters["femaleMortalityBias"] = 0.85
        parameters["careNeedBias"] = 0.9   
        parameters["unmetCareNeedBias"] = 0.5  
        parameters["fertilityBias"] = 0.9                
    
        # Income-related parameters: 
        # - WorkingAge: The ages of young agents deciding to start working
        # - pensionWage: ?? 
        parameters["workingAge"] = [16, 18, 20, 22, 24]      
        parameters["pensionWage"] = [5.0, 7.0, 10.0, 13.0, 18.0] # [0.64, 0.89, 1.27, 1.66, 2.29] #  
    
        # Salry parameters 
        #   ?? vector parameters correspond to each SES level
        parameters["incomeInitialLevels"] = [5.0, 7.0, 9.0, 11.0, 14.0] #[0.64, 0.89, 1.15, 1.40, 1.78] #  
        parameters["incomeFinalLevels"] = [10.0, 15.0, 22.0, 33.0, 50.0] #[1.27, 1.91, 2.80, 4.21, 6.37] #  
        parameters["incomeGrowthRate"] = [0.4/12.0, 0.35/12.0, 0.35/12.0, 0.3/12.0, 0.25/12.0]
        parameters["wageVar"] = 0.1                           
        parameters["workDiscountingTime"] = 1.0
        parameters["weeklyHours"] = [40.0, 20.0, 0.0, 0.0, 0.0] 
        parameters["maternityLeaveDuration"] = 9              # Months 
    
        # Care transition params
        parameters["unmetNeedExponent"] = 1.0
        parameters["careBias"] = 0.9
        parameters["careTransitionRate"] = 0.7
    
        # Care params
        parameters["priceSocialCare"] = 17.0                  # ?? Pounds / hour
        parameters["priceChildCare"] = 6.0
        parameters["quantumCare"] = 4                         # Hours 
    
        # Child Care params
        parameters["childCareDemand"] = 7*24 # 56 #48         # ?? Hours / Week
        parameters["maxFormalChildCare"] = 48                 # Hours 
        parameters["ageTeenagers"] = 13
        parameters["zeroYearCare"] = 80.0 
        parameters["priorityAgeThreshold"] = 8
        parameters["ageCareBeta"] = 0.5
        parameters["ageDeltaExp"] = 1.0
        parameters["supplyWeightExp"] = 0.5
        parameters["socialCareBeta"] = 0.1
        parameters["careDeltaExp"] = 0.5
        parameters["incomeCareFactor"] = 0.2
    
        # Public Child Care Provision Parameters
        ##############################################
        # 1st policy: The alpha-policy targeting
        #             Government contributes from 20% to 80% of the child care cost by
        #             a working family up to 2000 pounds per child per year 
        parameters["childCareTaxFreeRate"] = 0.2
        parameters["maxPublicContribution"] = 2000.0         
        # ??  Which policy 
        parameters["childcareTaxFreeCap"] = floor(Int,
                    (parameters["maxPublicContribution"]/52.0)/
                            (parameters["priceChildCare"]*parameters["childCareTaxFreeRate"]))
        parameters["maxHouseholdIncomeChildCareSupport"] = 300.0
    
        parameters["freeChildCareHoursToddlers"] = 12
        parameters["freeChildCareHoursPreSchool_NWP"] = 12
        parameters["freeChildCareHoursPreSchool_WF"] = 24
    
        parameters["nurseriesOpeningTimes"] = [8, 18]
        
        ##############################################
        # 2nd policy: The beta policy targeting
        #             increasing the the number of free child care from 20 to 32 hours/ week 
        #             or 1040 hours / years for every child aged 3 or 4
        parameters["freeChildCareHoursSchool"] = 32
    
        # ?? 
        parameters["publicChildCare"] = [[1]*10+[0]*14, [1]*10+[0]*14, [1]*10+[0]*14, [1]*10+[0]*14, [1]*10+[0]*14, [0]*24, [0]*24]
    
        # Public Social Care Provision Parameters
        parameters["taxBreakRate"] = 0.0
    
        ##############################################
        # 4th policy: The theta-policy
        #             A new scheme to make the goverment contribute to the cost of 
        #             of social care by 50% (currently no such scheme exists)
        parameters["socialCareTaxFreeRate"] = 0.0

        ##########################################
        # 3rd policy: The gamma policy
        #             Glocal authorities pay the full social care cost of people with 
        #             a critical level of social care need (care need level 4) 
        #             with savings of less than £14,250.  If their savings are between this lower bound 
        #             and £23,250, the person receiving the social care will contribute 
        #             a pound for every £250 of savings to the weekly cost.
        parameters["publicCareNeedLevel"] = 3 # 5
        #############################################
    
        parameters["publicCareAgeLimit"] = 0 # 1000
        parameters["minWealthMeansTest"] = 14250.0
        parameters["maxWealthMeansTest"] = 23250.0
        parameters["partialContributionRate"] = 0.5           # ??
        parameters["minimumIncomeGuarantee"] = 189.0          # ?? unit?
    
        parameters["distanceExp"] = 0.5                       # ?? 
        parameters["networkExp"] = 0.4                        # ??
    
        # ?? 
        parameters["incomeCareParam"] = 0.00005 # 0.0001
        parameters["wealthCareParam"] = 0.0000004 # 0.00000005
    
        # ?? 
        parameters["betaInformalCare"] = 1.2
        parameters["betaFormalCare"] = 1.0
        parameters["shareFinancialWealth"] = 0.3
        parameters["formalCareDiscountFactor"] = 0.5
    
        # Social Transition params
        # ?? Units?
        parameters["educationCosts"] = [0.0, 100.0, 150.0, 200.0] #[0.0, 12.74, 19.12, 25.49] # 
        parameters["eduWageSensitivity"] = 0.4 # 0.2
        parameters["eduRankSensitivity"] = 4.0 # 3.0
        parameters["costantIncomeParam"] = 20.0 # 20.0
        parameters["costantEduParam"] = 4.0 #  5.0
        parameters["careEducationParam"] = 0.5 # 0.4
        
        # Alternative Social Transition function
        parameters["incomeBeta"] = 0.01
        parameters["careBeta"] = 0.01
        parameters["probIncomeCare"] = 0.002
    
    
        #    parameters["retiredSupply_C"] = [24.0, 12.0, 6.0, 2.0] # [56.0, 28.0, 16.0, 8.0]
        #    parameters["unemployedSupply_C"] = [20.0, 10.0, 6.0, 2.0]
        #    parameters["employedSupply_C"] = [[16.0, 8.0, 4.0, 2.0], [24.0, 12.0, 6.0, 2.0]] # [16.0, 12.0, 8.0, 4.0]
        #    parameters["studentSupply_C"] = [[8.0, 4.0, 2.0, 0.0], [12.0, 6.0, 2.0, 0.0]] # [16.0, 8.0, 4.0, 0.0]
        #    parameters["teenagerSupply_C"] = [4.0, 0.0, 0.0, 0.0]
    
        # For retired, add reduction by age
        #    parameters["retiredSupply_S"] = [10.0, 8.0, 4.0, 2.0] # [56.0, 28.0, 16.0, 8.0]
        #    parameters["unemployedSupply_S"] = [8.0, 6.0, 4.0, 2.0]
        #    parameters["employedSupply_S"] = [[6.0, 4.0, 2.0, 0.0], [8.0, 6.0, 4.0, 2.0]] # [16.0, 12.0, 8.0, 4.0]
        #    parameters["studentSupply_S"] = [[4.0, 2.0, 0.0, 0.0], [6.0, 4.0, 2.0, 0.0]] # [16.0, 8.0, 4.0, 0.0]
    
        # Max daily supplies by distance and weekdays/weekend
        # ?? Units
        parameters["dailyRetiredSupply"] = [12, 12] # [56.0, 28.0, 16.0, 8.0]
        parameters["dailyUnemployedSupply"] = [12, 12]
        parameters["dailyEmployedSupply"] = [6, 12] # [16.0, 12.0, 8.0, 4.0]
        parameters["dailyStudentSupply"] = [4, 8] # [16.0, 8.0, 4.0, 0.0]
        parameters["dailyTeenagerSupply"] = [2, 4]
        parameters["dailyNewMotherSupply"] = [4, 4]
        
        # Max weekly supply
        parameters["weeklyRetiredSupply"] = [60, 30, 16, 8] # [56.0, 28.0, 16.0, 8.0]
        parameters["weeklyUnemployedSupply"] = [48, 24, 12, 6]
        parameters["weeklyEmployedSupply"] = [32, 16, 8, 4] # [16.0, 12.0, 8.0, 4.0]
        parameters["weeklyStudentSupply"] = [24, 12, 6, 2] # [16.0, 8.0, 4.0, 0.0]
        parameters["weeklyTeenagerSupply"] = [10, 0, 0, 0]
        parameters["weeklyNewMotherSupply"] = [28, 0, 0, 0]
    
    
        # Marriages params
    
        # Unmer Need params
        parameters["unmetCareNeedDiscountParam"] = 0.5
        parameters["shareUnmetNeedDiscountParam"] = 0.5
    
        # Hospitalisation costs params
        parameters["hospitalizationParam"] = 0.5
        parameters["needLevelParam"] = 2.0
        parameters["unmetSocialCareParam"] = 2.0
        parameters["costHospitalizationPerDay"] = 400         # ?? Unit? 
    
        # Priced growth  #####
        parameters["wageGrowthRate"] = 1.0 # 1.01338 # 

        # Mortality statistics
        parameters["baseDieProb"] = 0.0001
        parameters["babyDieProb"] = 0.005
        parameters["maleAgeScaling"] = 14.0
        parameters["maleAgeDieProb"] = 0.00021
        parameters["femaleAgeScaling"] = 15.5
        parameters["femaleAgeDieProb"] = 0.00019
        parameters["num5YearAgeClasses"] = 28

        # Transitions to care statistics
        parameters["baseCareProb"] = 0.0002
        parameters["personCareProb"] = 0.0008
        ##parameters["maleAgeCareProb"] = 0.0008
        parameters["maleAgeCareScaling"] = 18.0
        ##parameters["femaleAgeCareProb"] = 0.0008
        parameters["femaleAgeCareScaling"] = 19.0
        parameters["cdfCareTransition"] = [ 0.7, 0.9, 0.95, 1.0 ]
        parameters["careLevelNames"] = ["none","low","moderate","substantial", "critical"]
        # ?? / Week? 
        parameters["careDemandInHours"] = [ 0.0, 14.0, 28.0, 56.0, 84.0] # [ 0.0, 8.0, 16.0, 30.0, 80.0 ] #[ 0.0, 12.0, 24.0, 48.0, 96.0 ]
        parameters["probFlexibleNeed"] = 0.5
    
        parameters["careActivities"] = ["morning", "bedtime", "miscellaneous"]
        parameters["probHelpWithMeals"] = [0.12, 0.25, 0.5, 1.0]
        parameters["activitiesHours"] = [[8, 9], [12, 13], [18, 19], [21, 22]]
        parameters["nightSupervisionHours"] = [23, 24, 1, 2, 3, 4, 5, 6]
    
        # Cost of care for tax burden
        parameters["hourlyCostOfCare"] = 20.0                 # ?? Pounds? 

        # Fertility statistics
        parameters["growingPopBirthProb"] = 0.215
        parameters["steadyPopBirthProb"] = 0.13
        parameters["transitionYear"] = 1965
        parameters["minPregnancyAge"] = 17
        parameters["maxPregnancyAge"] = 42

        # Class and employment statistics
        parameters["numOccupationClasses"] = 3
        parameters["occupationClasses"] = ["lower","intermediate","higher"]
        parameters["cdfOccupationClasses"] = [ 0.6, 0.9, 1.0 ]

        # Age transition statistics
        parameters["ageOfAdulthood"] = 16
        parameters["ageOfRetirement"] = 65
        parameters["probOutOfTownStudent"] = 0.5
    
        # Job market parameters
        parameters["minTenure"] = 6
        parameters["monthlyTurnOver"] = 0.01
        parameters["unemploymentClassBias"] = 0.75
        parameters["unemploymentAgeBias"] = [1.0, 0.55, 0.35, 0.25, 0.2, 0.2]
        parameters["numberAgeBands"] = 6
        parameters["meanLayOffsRate"] = 0.005
        parameters["probationPeriod"] = 3
        parameters["layOffsBeta"] = 0.1
        parameters["initialHour24h"] = 8
        parameters["shiftDuration"] = 8
    
        # Poverty Line income parameters
        # ?? Units? 
        parameters["singleWorker"] = 250.0
        parameters["marriedCouple"] = 400.0
        parameters["singlePensioner"] = 190.0
        parameters["couplePensioners"] = 320.0
        parameters["mixedCouple"] = 360.0
        parameters["additionalChild"] = 65.0
    
        #    parameters["shiftsWeights"] = [51.0, 51.34, 48.23, 43.29, 37.72, 33.61, 28.42, 22.47, 16.65, 11.64, 8.52, 6.77, 
        #                         5.5, 4.66, 4.18, 4.66, 6.86, 11.58, 17.81, 24.5, 31.34, 36.29, 41.96, 47.43]
        #   ?? 
        parameters["shiftsWeights"] = [51.80, 66.10, 70.10, 71.40, 54.10, 63.40, 68.60, 65.00, 54.70, 35.00, 20.70, 15.70,
                                       13.00, 11.50, 9.10, 6.80, 4.60, 3.80, 3.20, 3.00, 4.60, 6.70, 13.90, 28.80]

    
        #    parameters["shiftsWeights"] = [1000.0, 1000.34, 100.23, 80.0, 80.0, 33.61, 28.42, 22.47, 16.65, 11.64, 8.52, 6.77, 
        #                         5.5, 4.66, 4.18, 4.66, 6.86, 11.58, 17.81, 24.5, 31.34, 300.29, 600.96, 700.43]
    
        # parameters["shiftsWeights"] = [51.0, 51.34, 48.23] + [0]*21 ## Debugging check
    
        parameters["probSaturdayShift"] = 0.2  ### Debugging value
        parameters["probSundayShift"] = 0.1  ### Debugging value
    
        parameters["shareAppointmentsRetired"] = 0.1
        parameters["shareAppointmentsUnemployed"] = 0.2
        parameters["shareAppointmentsWorkers"] = 0.0    #  0.05  ### Debugging value
        parameters["shareAppointmentsStudents"] = 0.1
    
        parameters["sundaySocialIndex"] = 0.5
        parameters["shiftBeta"] = 0.1
        parameters["dayBeta"] = 0.1
        parameters["unemploymentBeta"] = 1.0
        parameters["maleUDS"] = [0.07, 0.11, 0.12, 0.07, 0.07, 0.06, 0.12, 0.06, 0.08, 0.04]
        parameters["femaleUDS"] = [0.12, 0.12, 0.12, 0.08, 0.07, 0.08, 0.12, 0.06, 0.06, 0.03]

        # House ownership
        parameters["ownershipProbExp"] = 0.1
        parameters["incomeOwnershipShares"] = [0.2, 0.4, 0.5, 0.57, 0.63, 0.67, 0.71, 0.75, 0.79, 0.83]
        parameters["ageOwnershipShares"] = [0.12, 0.44, 0.61, 0.71, 0.77, 0.79]
        parameters["ageRanges"] = [24, 34, 44, 54, 64]
        parameters["ageBiases"] = [1.0, 3.67, 5.0, 5.9, 6.4, 6.6]
    
        #### UC benefits
        #  Standard allowance
        # ?? 
        # Below is a typing error which can easily leads to non-easy-to-catch mistakes  
        # It is therefore recommended to rather use set & get with dictionaries 
        parameters["sigleBelow25"] = (257.33*12)/52.0         
        parameters["single25Plus"] = (324.84*12)/52.0
        parameters["coupleBelow25"] = ((403.93*12)/52.0)/2.0
        parameters["couple25Plus"] = ((509.91*12)/52.0)/2.0
        # Extra-amount for children
        parameters["eaChildren"] = (237.08*12)/52.0
        parameters["eaDisabledChildren"] = [(128.89*12)/52.0, (402.41*12)/52.0]
        parameters["childCareHelpRate"] = 0.85
        parameters["childCareHelpRateMax"] = [(646.35*12)/52.0, (1108.04*12)/52.0]
        # Extra-amount for disability or health condition
        parameters["lcfwComponent"] = (343.63*12)/52.0
        parameters["carersComponent"] = (163.73*12)/52.0
        # UC reductions
        parameters["incomeReduction"] = 0.63
        parameters["workAllowanceHS"] = (293.0*12)/52.0
        parameters["workAllowanceNoHS"] = (515.0*12)/52.0
        parameters["capitalLowThreshold"] = 6000.0
        parameters["capitalHighThreshold"] = 16000.0
        parameters["savingUCRate"] = 250
        parameters["capitalIncome"] = 4.35
        parameters["maternityLeaveIncomeReduction"] = 0.9
        parameters["minStatutoryMaternityPay"] = 151.97
    
        # Child Benefit
        parameters["childBenefitIncomeThreshold"] = 50000.0
        parameters["firstChildBenefit"] = 21.15
        parameters["otherChildrenBenefit"] = 14.0

        ### Disability benefits:
        # DLA
        parameters["careDLA"] = [23.70, 60.00, 89.60]
        parameters["mobilityDLA"] = [23.70, 62.55]
        # PIP
        parameters["carePIP"] = [60.00, 89.60]
        parameters["mobilityPIP"] = [23.70, 62.55]
        # Attendance allowance
        parameters["careAA"] = [60.00, 89.60]
        # Carers" Allowance
        parameters["carersAllowance"] = 67.60 # Over 16 and care for 35 hours per week (5 hours per week)
    
        ### Pension Credit
        parameters["singlePC"] = 177.10 # Top-up
        parameters["couplePC"] = 270.30 # Top-up
        parameters["wealthAllowancePC"] = 10000.0
        parameters["savingIncomeRatePC"] = 500
        parameters["disabilityComponentPC"] = 67.30
        parameters["caringComponentPC"] = 37.70
        parameters["childComponentPC"] = 54.60
        parameters["disabledChildComponent"] = [29.66, 92.54]
        parameters["housingBenefitWealthThreshold"] = 16000.0
    
    
        ## Marriage and divorce statistics (partnerships really)
        parameters["incomeMarriageParam"] = 0.025
        parameters["betaGeoExp"] = 2.0
        parameters["studentFactorParam"] = 0.5
        parameters["betaSocExp"] = 2.0
        parameters["rankGenderBias"] = 0.5
        parameters["deltageProb"] =  [0.0, 0.1, 0.25, 0.4, 0.2, 0.05]
        parameters["bridesChildrenExp"] = 0.5
        parameters["manWithChildrenBias"] = 0.9
        parameters["maleMarriageMultiplier"] = 1.4
        parameters["notWorkingMarriageBias"] = 0.5

        parameters["basicFemaleMarriageProb"] = 0.25
        parameters["femaleMarriageModifierByDecade"] = [ 0.0, 0.5, 1.0, 1.0, 1.0, 0.6, 0.5, 0.4, 0.1, 0.01, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        parameters["basicMaleMarriageProb"] =  0.8 
        parameters["maleMarriageModifierByDecade"] = [ 0.0, 0.16, 0.5, 1.0, 0.8, 0.7, 0.66, 0.5, 0.4, 0.2, 0.1, 0.05, 0.01, 0.0, 0.0, 0.0 ]
        parameters["basicDivorceRate"] = 0.06 # 0.1
        parameters["variableDivorce"] = 0.06 # 0.1
        parameters["divorceModifierByDecade"] = [ 0.0, 1.0, 0.9, 0.5, 0.4, 0.2, 0.1, 0.03, 0.01, 0.001, 0.001, 0.001, 0.0, 0.0, 0.0, 0.0 ]
        parameters["divorceBias"] = 0.9
        parameters["probChildrenWithFather"] = 0.1
    
        ## Leaving home and moving around statistics
        parameters["probApartWillMoveTogether"] = 1.0 # 0.3
        parameters["coupleMovesToExistingHousehold"] = 0.0 # 0.3
        parameters["basicProbAdultMoveOut"] = 0.22
        parameters["probAdultMoveOutModifierByDecade"] = [ 0.0, 0.2, 1.0, 0.6, 0.3, 0.15, 0.03, 0.03, 0.01, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        parameters["basicProbSingleMove"] = 0.05
        parameters["probSingleMoveModifierByDecade"] = [ 0.0, 1.0, 1.0, 0.8, 0.4, 0.06, 0.04, 0.02, 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        parameters["basicProbFamilyMove"] = 0.03
        parameters["probFamilyMoveModifierByDecade"] = [ 0.0, 0.5, 0.8, 0.5, 0.2, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 ]
        parameters["agingParentsMoveInWithKids"] = 0.1
        parameters["variableMoveBack"] = 0.1
    
        # Relocation Parameters
        parameters["careAttractionExp"] = 0.002
        parameters["networkDistanceParam"] = 0.5
        parameters["relativeRentExp"] = 0.01
        parameters["rentExp"] = 0.01
        parameters["sesShareExp"] = 1.0
        parameters["knaExp"] = 0.001
        parameters["yearsInTownBeta"] = 0.5
        parameters["scalingFactor"] = 0.8
        parameters["relocationCostBeta"] = 0.5
    
    
        parameters["relocationCostParam"] = 0.5
        parameters["supportNetworkBeta"] = 0.1
    
        parameters["incomeRelocationBeta"] = 0.0002
        parameters["baseRelocationRate"] = 0.1
    
        # parameters["supportNetworkBeta"] = 0.1
        # parameters["incomeRelocationBeta"] = 0.0002
        # parameters["baseRelocationRate"] = 0.1

    
        #= 

        folder = "defaultSimFolder"
        if not os.path.exists(folder):
            os.makedirs(folder)
        filePath = folder + "/defaultParameters.csv"
        c = p.copy()
        for key, value in c.iteritems():
            if not isinstance(value, list):
                c[key] = [value]
        with open(filePath, "wb") as f:
            csv.writer(f).writerow(c.keys())
            csv.writer(f).writerows(itertools.izip_longest(*c.values()))
        
        =# 

        nothing

    end


    function initSimulationVariables(simulation::SocialSimulation) 

        #= 
        variables = Dict()
        simulation.properties[:variables] = variables 
        
        looks more relevant to have something like theta

        simulation.variables = Dict()::Dict{Symbola,Any} 
        =# 
        
        #= To translate 

  



        self.dataMap = ['town_x', 'town_y', 'x', 'y', 'size', 'unmetNeed'] 
        
        self.dataPyramid = ['year', 'Class Age 0', 'Class Age 1', 'Class Age 2', 'Class Age 3', 'Class Age 4', 'Class Age 5', 'Class Age 6', 'Class Age 7',
                            'Class Age 8', 'Class Age 9', 'Class Age 10', 'Class Age 11', 'Class Age 12', 'Class Age 13', 'Class Age 14', 'Class Age 15',
                            'Class Age 16', 'Class Age 17', 'Class Age 18', 'Class Age 19', 'Class Age 20', 'Class Age 21', 'Class Age 22', 'Class Age 23', 
                            'Class Age 24']
        
        self.houseData = ['year', 'House name', 'size']
        
        self.householdData = ['ID', 'Sex', 'Age', 'Health']
        
        self.log = ['year', 'message']
        
        self.Outputs = ['year', 'month', 'period', 'currentPop', 'popFromStart', 'numHouseholds', 'averageHouseholdSize', 'marriageTally', 
                        'marriagePropNow', 'divorceTally', 'shareSingleParents', 'shareFemaleSingleParent', 
                        'taxPayers', 'taxBurden', 'familyCareRatio', 'employmentRate', 'shareWorkingHours', 
                        'publicSocialCare', 'costPublicSocialCare', 'sharePublicSocialCare', 'costTaxFreeSocialCare', 
                        'publicChildCare', 'costPublicChildCare', 'sharePublicChildCare', 'costTaxFreeChildCare', 
                        'totalTaxRevenue', 'totalPensionRevenue', 'pensionExpenditure', 'totalHospitalizationCost', 
                        'classShare_1', 'classShare_2', 'classShare_3', 'classShare_4', 'classShare_5', 'totalInformalChildCare', 
                        'formalChildCare', 'totalUnmetChildCareNeed', 'childcareIncomeShare', 'shareInformalChildCare', 'shareCareGivers', 
                        'ratioFemaleMaleCarers', 'shareMaleCarers', 'shareFemaleCarers', 'ratioWage', 'ratioIncome', 
                        'shareFamilyCarer', 'share_over20Hours_FamilyCarers', 'numSocialCarers', 'averageHoursOfCare', 'share_40to64_carers', 
                        'share_over65_carers', 'share_10PlusHours_over70', 'totalSocialCareNeed', 
                        'totalInformalSocialCare', 'totalFormalSocialCare', 'totalUnmetSocialCareNeed', 
                        'totalSocialCare', 'share_InformalSocialCare', 'share_UnmetSocialCareNeed', 'totalOWSC', 'shareOWSC', 'totalCostOWSC', 
                        'singleHousehold_UC', 'coupleHousehold_UC', 'incomePerCapita_Single', 'incomePerCapita_Couple',
                        'q1_socialCareNeed', 'q1_informalSocialCare', 'q1_formalSocialCare', 'q1_unmetSocialCareNeed', 'q1_outOfWorkSocialCare',
                        'q2_socialCareNeed', 'q2_informalSocialCare', 'q2_formalSocialCare', 'q2_unmetSocialCareNeed', 'q2_outOfWorkSocialCare',
                        'q3_socialCareNeed', 'q3_informalSocialCare', 'q3_formalSocialCare', 'q3_unmetSocialCareNeed', 'q3_outOfWorkSocialCare',
                        'q4_socialCareNeed', 'q4_informalSocialCare', 'q4_formalSocialCare', 'q4_unmetSocialCareNeed', 'q4_outOfWorkSocialCare',
                        'q5_socialCareNeed', 'q5_informalSocialCare', 'q5_formalSocialCare', 'q5_unmetSocialCareNeed', 'q5_outOfWorkSocialCare',
                        'grossDomesticProduct', 'publicCareToGDP', 'onhUnmetChildcareNeed', 'medianChildCareNeedONH',
                        'totalHoursOffWork', 'indIQ1', 'indIQ2', 'indIQ3', 'indIQ4', 'indIQ5', 'origIQ1', 'origIQ2', 'origIQ3', 'origIQ4', 'origIQ5', 
                        'dispIQ1', 'dispIQ2', 'dispIQ3', 'dispIQ4', 'dispIQ5', 'netIQ1', 'netIQ2', 'netIQ3', 'netIQ4', 'etIQ5', 'shareSES_1', 
                        'shareSES_2', 'shareSES_3', 'shareSES_4', 'shareSES_5', 'internalChildCare', 'internalSocialCare', 'externalChildCare', 
                        'externalSocialCare', 'shareInternalCare', 'aggregateChildBenefits', 'aggregateDisabledChildrenBenefits', 'aggregatePIP', 
                        'aggregateAttendanceAllowance', 'aggregateCarersAllowance', 'aggregateUC', 'aggregateHousingElement', 
                        'aggregatePensionCredit', 'totalBenefits', 'benefitsIncomeShare']
        
        self.outputData = pd.DataFrame()
        # Save initial parametrs into Scenario folder
        self.folder = folder + '/Scenario_' + str(scenario)
        if not os.path.exists(self.folder):
            os.makedirs(self.folder)
        filePath = self.folder + '/scenarioParameters.csv'
        c = params.copy()
        for key, value in c.iteritems():
            if not isinstance(value, list):
                c[key] = [value]
        with open(filePath, "wb") as f:
            csv.writer(f).writerow(c.keys())
            csv.writer(f).writerows(itertools.izip_longest(*c.values()))
        
        
        ####  SES variables   #####
        self.socialClassShares = []
        self.careNeedShares = []
        self.householdIncomes = []
        self.individualIncomes = []
        self.incomeFrequencies = []
        self.sesPops = []
        self.sesPopsShares = []
        self.hiredPeople = []
        ## Statistical tallies
        self.times = []
        self.pops = []
        self.avgHouseholdSize = []
        self.marriageTally = 0
        self.numMarriages = []
        self.divorceTally = 0
        self.numDivorces = []
        self.totalCareDemand = []
        self.totalCareSupply = []
        self.informalSocialCareSupply = 0
        self.totalHospitalizationCost = 0
        self.hospitalizationCost = []
        self.numTaxpayers = []
        self.totalUnmetNeed = []
        self.totalChildCareNeed = 0
        self.totalSocialCareNeed = 0
        self.totalUnmetCareNeed = 0
        self.totalUnmetChildCareNeed = 0
        self.totalUnmetSocialCareNeed = 0
        self.internalChildCare = 0
        self.internalSocialCare = 0
        self.externalChildCare = 0
        self.externalSocialCare = 0
        self.shareUnmetNeed = []
        self.totalFamilyCare = []
        self.inHouseInformalCare = 0
        self.totalTaxBurden = []
        self.marriageProp = []
        self.shareLoneParents = []
        self.shareFemaleLoneParents = []
        self.employmentRate = []
        self.shareWorkingHours = []
        self.publicCareProvision = []
        
        self.householdsWithFormalChildCare = []
        self.periodFormalCare = False
        self.totalFormalCare = 0
        self.previousTotalFormalCare = 0
        
        self.publicSocialCare = 0
        self.costPublicSocialCare = 0
        self.grossDomesticProduct = 0
        self.costTaxFreeSocialCare = 0
        self.costTaxFreeChildCare = 0
        self.costPublicChildCare = 0
        self.publicChildCare = 0
        self.sharePublicSocialCare = 0
        self.sharePublicChildCare = 0
        self.stateTaxRevenue = []
        self.totalTaxRevenue = 0
        self.statePensionRevenue = []
        self.totalPensionRevenue = 0
        self.statePensionExpenditure = []
        self.pensionExpenditure = 0
        self.aggregateChildBenefits = 0
        self.aggregateDisabledChildrenBenefits = 0
        self.aggregatePIP = 0
        self.aggregateAttendanceAllowance = 0
        self.aggregateCarersAllowance = 0
        self.aggregateUC = 0
        self.aggregateHousingElement = 0
        self.aggregatePensionCredit = 0
        
        self.onhUnmetChildcareNeed = 0
        self.medianChildCareNeedONH = 0
        self.totalHoursOffWork = 0
        self.allCareSlots = []
        ## Counters and storage
        self.year = self.p['startYear']
        self.pyramid = PopPyramid(self.p['num5YearAgeClasses'],
                                  self.p['numCareLevels'])
        self.textUpdateList = []
        
        self.socialCareNetwork = nx.DiGraph()

        self.aggregateSchedule = [0]*24
        # if self.p['interactiveGraphics']:
        # self.window = Tkinter.Tk()
        # self.canvas = Tkinter.Canvas(self.window,
        #                        width=self.p['screenWidth'],
        #                        height=self.p['screenHeight'],
        #                        background=self.p['bgColour']) 

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