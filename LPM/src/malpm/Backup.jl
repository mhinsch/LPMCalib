#=

Unused code from translation phase subject to reuse 

=# 


function loadMetaParameters!(simulation::SocialSimulation) 
    
    meta = Dict()

    meta[:thePresent] = 2012
    # meta[:initialPop] = 500
   
    meta[:statsCollectFrom] = 1960
    meta[:policyStartYear] = 2020
    meta[:outputYear] = 2015
   

    #= not considered yet 
    meta[:verboseDebugging] = false
    meta[:singleRunGraphs] = false                           # ?? 
    meta[:withBenefits] = true                               # ?? 
    meta[:externalCare] = true                               # ?? 
    meta[:careAllocationFromYear] = simulation.properties[:startYear]   # meta[:startYear]
    meta[:favouriteSeed] = simulation.properties[:seed] 
    meta[:loadFromFile] = false
    meta[:numberClasses] = 5                                 # ?? Socio-econimic classes
    meta[:numCareLevels] = 5
    meta[:timeDiscountingRate] = 0.035                       # ??
    =# 

    # Description of the map and towns: 
    #   The space is represented by a 2-level grid.  At the higher level, 
    #   an mapGridYDimension x mapGridXDimension grid roughly represents 
    #   the UK map. Each cell in this high-level grid is composed by 
    #   a (townGridDimension x townGridDimension)-grid, which represents 
    #   the space at the lower level.
                      
    
    ## Description of houses
    #= not considered yet 
    meta[:numHouseClasses] = 3                
    meta[:houseClasses] = ["small","medium","large"]
    meta[:cdfHouseClasses] = [ 0.6, 0.9, 5.0 ]               # comulative distribution function
    meta[:shareClasses] = [0.2, 0.23, 0.25, 0.22, 0.1]       # ?? Socio-economic classes?
    meta[:classAdjustmentBeta] = 3.0                         # ??
    =#

    #======================================
    Warning: in the following, original implementation
             was conducted using 1-D arrays rather 
             than 2D matrices 
    =#####################################



   
    
    existingKeys = [key for key in keys(meta) if key in keys(simulation.properties)]
    if length(existingKeys) > 0 
        error("Attempting to initialize keys : $(existingKeys) more than once")
    end 

    merge!(simulation.properties,meta)  
end

"model parameters"
function loadModelParameters!(simulation::SocialSimulation)

    parameters = Dict() 

    #= not considered yet 
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
    
    #  weight of ratios for work shifts from hour 0 to hour 23
    #  first entry corresponds to 7 a.m   
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
    parameters["shiftBeta"] = 0.1                   #  for computing socio-index related quantity, cf. createShifts 
    parameters["dayBeta"] = 0.1                     #  for computing socio-index related quantity, cf. createShifts
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

    =# 

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



#=
"Create an empty population initially with no agents"
function createPopulation() 
    population = ABM{Person}()

    # ?? Brief descriptions of the numbers within the text file needed (not directly understandable in their pure format)

    # Data related to population income 
    # addProperty!(population,:unemployment_series,readArrayFromCSVFile("unemploymentrate.csv"))
    # addProperty!(population,:income_distribution,readArrayFromCSVFile("incomeDistribution.csv"))
    # addProperty!(population,:income_percentiles,readArrayFromCSVFile("incomePercentiles.csv"))
    # addProperty!(population,:wealth_distribution,readArrayFromCSVFile("wealthDistribution.csv"))

    # shifts = createShifts() 

    population
end
=# 

function initSimulationVariables(simulation::SocialSimulation) 

    #= not considered yet 
    variables = Dict()
    simulation.properties[:variables] = variables 
    
    looks more relevant to have something like theta

    simulation.variables = Dict()::Dict{Symbol,Any}
    
    simulation.outputs = Dict()::Dict{Symbol,Any}
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


"Create a 1000-vector of 7 hour work shifts"
function createShifts!(simulation::SocialSimulation) 

#= 
        allShifts = []
        
        # < 
        numShifts = [int(round(x)) for x in self.p['shiftsWeights']]
        # > [52, 66, 70, 71, 54, 63, 69, 65, 55, 35, 21, 16, 13, 12, ...] 24 elements 

        hours = []
        for hourIndex in range(len(numShifts)):
            hours.extend([hourIndex]*numShifts[hourIndex])
        # A large array of length 748, with 52 0s, 66 1s etc. 

        # seems that the function random.choices(population, weights=None, *, cum_weights=None, k=9000)
        # is more efficient   
        allHours = list(np.random.choice(hours, 9000))   
        # > a list of 9000 entries randomly generated from hours array

        # > Produce 1000 vectors of 8 hour shifts proportionally equivalent to the shiftsWieghts 
        shifts = []
        for i in range(1000):
            shift = []
            hour = np.random.choice(allHours)
            shift.append(hour)
            allHours.remove(hour)
            if hour == 0:
                nextHours = [23, 1]
            elif hour == 23:
                nextHours = [22, 0]
            else:
                nextHours = [hour-1, hour+1]
            weights = []
            for nextHour in nextHours:
                weights.append(float(len([x for x in allHours if x == nextHour])))
            if sum(weights) == 0:
                break
            probs = [x/sum(weights) for x in weights]
            nextHour = np.random.choice(nextHours, p = probs)
            if nextHours.index(nextHour) == 0:
                shift = [nextHour]+shift
            else:
                shift.append(nextHour)
            allHours.remove(nextHour)
            while len(shift) < 8:
                a = -1
                b = -1
                if shift[0] == 0:
                    a = 23
                else:
                    a = shift[0]-1
                if shift[-1] == 23:
                    b = 0
                else:
                    b = shift[-1]+1
                nextHours = [a,b]
                weights = [float(len([x for x in allHours if x == a])), float(len([x for x in allHours if x == b]))]
                if sum(weights) == 0:
                    break
                probs = [x/sum(weights) for x in weights]
                nextHour = np.random.choice(nextHours, p = probs)
                if nextHours.index(nextHour) == 0:
                    shift = [nextHour]+shift
                else:
                    shift.append(nextHour)
                allHours.remove(nextHour)
            shifts.append(shift)
            # pdb.set_trace()
    
        for shift in shifts:
            days = []
            weSocIndex = 0
            if np.random.random() < self.p['probSaturdayShift']:
                days.append(6)
                weSocIndex -= 1
            if np.random.random() < self.p['probSundayShift']:
                days.append(7)
                weSocIndex -= (1 + self.p['sundaySocialIndex'])
            if len(days) == 0:
                days = range(1, 6)
            elif len(days) == 1:
                days.extend(np.random.choice(range(1, 6), 4, replace=False))
            else:
                days.extend(np.random.choice(range(1, 6), 3, replace=False))
                
            startHour = (shift[0]+7)%24+1

            # compute socio index related quantity based on shift characteristics 
            socIndex = np.exp(self.p['shiftBeta']*self.p['shiftsWeights'][shift[0]]+self.p['dayBeta']*weSocIndex)
            
            newShift = Shift(days, startHour, shift[0], shift, socIndex)
            allShifts.append(newShift)
        
        return allShifts
=#

    nothing 

end 


#= 

self.allPeople = []
        self.livingPeople = []
        for i in range(int(initial)/2):
            ageMale = random.randint(minStartAge, maxStartAge)
            ageFemale = ageMale - random.randint(-2,5)
            if ( ageFemale < 24 ):
                ageFemale = 24
            birthYear = startYear - random.randint(minStartAge,maxStartAge)
            classes = [0, 1, 2, 3, 4]
            probClasses = [0.2, 0.35, 0.25, 0.15, 0.05]
            classRank = np.random.choice(classes, p = probClasses)
            
            workingTime = 0
            for i in range(int(ageMale)-int(workingAge[classRank])):
                workingTime *= workDiscountingTime
                workingTime += 1
            
            dKi = np.random.normal(0, wageVar)
            initialWage = incomeInitialLevels[classRank]*math.exp(dKi)
            dKf = np.random.normal(dKi, wageVar)
            finalWage = incomeFinalLevels[classRank]*math.exp(dKf)
            
            c = np.math.log(initialWage/finalWage)
            wage = finalWage*np.math.exp(c*np.math.exp(-1*incomeGrowthRate[classRank]*workingTime))
            income = wage*weeklyHours
            workExperience = workingTime
            tenure = np.random.randint(50)
            birthMonth = np.random.choice([x+1 for x in range(12)])
            newMan = Person(None, None,
                            birthYear, ageMale, 'male', None, None, classRank, classRank, wage, income, 0, initialWage, finalWage, workExperience, 'worker', True, tenure, birthMonth)
            
            workingTime = 0
            for i in range(int(ageFemale)-int(workingAge[classRank])):
                workingTime *= workDiscountingTime
                workingTime += 1
                
            dKi = np.random.normal(0, wageVar)
            initialWage = incomeInitialLevels[classRank]*math.exp(dKi)
            dKf = np.random.normal(dKi, wageVar)
            finalWage = incomeFinalLevels[classRank]*math.exp(dKf)
            
            c = np.math.log(initialWage/finalWage)
            wage = finalWage*np.math.exp(c*np.math.exp(-1*incomeGrowthRate[classRank]*workingTime))
            income = wage*weeklyHours
            workExperience = workingTime
            tenure = np.random.randint(50)
            birthMonth = np.random.choice([x+1 for x in range(12)])
            newWoman = Person(None, None,
                              birthYear, ageFemale, 'female', None, None, classRank, classRank, wage, income, 0, initialWage, finalWage, workExperience, 'worker', True, tenure, birthMonth)

            # newMan.status = 'independent adult'
            # newWoman.status = 'independent adult'
            
            newMan.partner = newWoman
            newWoman.partner = newMan
            
            self.allPeople.append(newMan)
            self.livingPeople.append(newMan)
            self.allPeople.append(newWoman)
            self.livingPeople.append(newWoman)

=# 


function loadData!(simulation::SocialSimulation)
    loadMetaParameters!(simulation)
    loadModelParameters!(simulation)
    initSimulationVariables(simulation)
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


#= 
def doOneMonth(self, policyFolder, dataMapFolder, dataHouseholdFolder, year, month, period):
    """Run one year of simulated time."""

    ##print "Sim Year: ", self.year, "OH count:", len(self.map.occupiedHouses), "H count:", len(self.map.allHouses)
    print 'Year: ' + str(year) + ' - Month: ' + str(month)
    # self.checkHouseholds(0)
    
    startYear = time.time()
    
    print 'Tot population: ' + str(len(self.pop.livingPeople))
    # print 'Doing fucntion 1...'
    
    self.computeClassShares()
    
    # print 'Doing doDeaths...'
  
    ###################   Do Deaths   #############################
    
    # self.checkIndependentAgents(0)
  
    self.doDeaths(policyFolder, month)
    
    # self.checkIndependentAgents(1)
    
    self.doAdoptions(policyFolder)
    
    # self.checkIndependentAgents(1)
    
    
    ###################   Do Care Transitions   ##########################
    
    # self.doCareTransitions()
    
    # print 'Doing fucntion 4...'
    
    
    self.doCareTransitions_UCN(policyFolder, month)
    
    # self.checkIndependentAgents(1.1)
    

    self.computeIncome(month)
    
    if month == 12:
        self.computeIncomeQuintileShares()
    
    self.updateWealth_Ind()
    
    
    # self.checkIncome(2)
    
    print 'Doing jobMarket...'
    
    self.jobMarket(year, month)
    # Here, people change job, find a job if unemployed and lose a job if employed.
    # The historical UK unemployment rate is the input.
    # Unmeployement rates are adjusted for age and SES.
    # Upon losing the job, a new unemplyed agent is assigned an 'unemployment duration' draw from the empirical distribution.
    # Unemployment duration is also age and SES specific.
    
    self.computeAggregateSchedule()
    
    # print 'Doing fucntion 9...'
    # self.checkIncome(3)
    
    
    # self.computeTax()
    

    # print 'Doing startCareAllocation...'

    self.startCareAllocation()
    
    if year >= self.p['careAllocationFromYear']:
        
        self.allocateWeeklyCare()
        
        # self.checkHouseholdsProvidingFormalCare()
    
    # print 'Doing fucntion 7...'
    # self.checkIncome(5)
    
    
    ##### Temporarily bypassing social care alloction
    
    ## self.allocateSocialCare_Ind()

    # print 'Doing fucntion 8...'

    self.updateUnmetCareNeed()
    
    self.doAgeTransitions(policyFolder, month)
    
    # self.checkIndependentAgents(1.2)
    
    
    self.doSocialTransition(policyFolder, month)
    
    
    # self.checkIndependentAgents(1.3)
    
    
    # Each year
    self.houseOwnership(year)
    
    
    # Compute benefits.
    # They increase the household income in the following period.
    if self.p['withBenefits'] == True:
        self.computeBenefits()
    
    # self.publicCareEntitlements()
    
    # print 'Doing fucntion 10...'
    
    # self.checkHouseholds(0)
    
    self.doBirths(policyFolder, month)
    
    # self.checkIndependentAgents(1.3)
    # print 'Doing fucntion 11...'

    
    
    
    
    # print 'Doing fucntion 12...'
    
    # self.updateWealth()
    
    
  
    # print 'Doing fucntion 13...'
    
    # self.doSocialTransition_TD()
    
    # self.checkIndependentAgents(2)
    
    # print 'Doing fucntion 14...'
    
    self.doDivorces(policyFolder, month)
    
    # self.checkIndependentAgents(3)
    
    self.doMarriages(policyFolder, month)
    
    
    # self.checkIndependentAgents(4)
    
    # print 'Doing fucntion 16...'
    print 'Doing doMovingAround...'
    
    self.doMovingAround(policyFolder)
    
    
    # self.checkIndependentAgents(5)
    
    # print 'Doing householdRelocation...'
    
    # self.householdRelocation(policyFolder)
    
    
    # print 'Doing fucntion 17...'
    
    self.pyramid.update(self.year, self.p['num5YearAgeClasses'], self.p['numCareLevels'],
                        self.p['pixelsInPopPyramid'], self.pop.livingPeople)
    
    
    # print 'Doing fucntion 18...'
    
    self.healthCareCost()
    
    self.doStats(policyFolder, dataMapFolder, dataHouseholdFolder, period)
    
    if (self.p['interactiveGraphics']):
        self.updateCanvas()
        
    endYear = time.time()
    
    print 'Year execution time: ' + str(endYear - startYear)     # ?? Looks rather like month execution time?

        
    # print 'Did doStats'
=# 

#=
def doDeaths(self, policyFolder, month):
    
preDeath = len(self.pop.livingPeople)

deaths = [0, 0, 0, 0, 0]
"""Consider the possibility of death for each person in the sim."""
for person in self.pop.livingPeople:
age = person.age

####     Death process with histroical data  after 1950   ##################
if self.year >= 1950:
    if age > 109:
        age = 109
    if person.sex == 'male':
        rawRate = self.death_male[age, self.year-1950]
    if person.sex == 'female':
        rawRate = self.death_female[age, self.year-1950]
        
    classPop = [x for x in self.pop.livingPeople if x.careNeedLevel == person.careNeedLevel]
    
    dieProb = self.deathProb(rawRate, person)
    
    person.lifeExpectancy = max(90-person.age, 3)
    # dieProb = self.deathProb_UCN(rawRate, person, person.averageShareUnmetNeed, classPop)

#############################################################################

    if np.random.random() < dieProb and np.random.choice([x+1 for x in range(12)]) == month:
        person.dead = True
        person.deadYear = self.year
        person.house.occupants.remove(person)
        if len(person.house.occupants) == 0:
            self.map.occupiedHouses.remove(person.house)
            if (self.p['interactiveGraphics']):
                self.canvas.itemconfig(person.house.icon, state='hidden')
        if person.partner != None:
            person.partner.partner = None
        if person.house == self.displayHouse:
            messageString = str(self.year) + ": #" + str(person.id) + " died aged " + str(age) + "." 
            self.textUpdateList.append(messageString)
            
            with open(os.path.join(policyFolder, "Log.csv"), "a") as file:
                writer = csv.writer(file, delimiter = ",", lineterminator='\r')
                writer.writerow([self.year, messageString])
    
else: 
    #######   Death process with made-up rates  ######################
    babyDieProb = 0.0
    if age < 1:
        babyDieProb = self.p['babyDieProb']
    if person.sex == 'male':
        ageDieProb = (math.exp(age/self.p['maleAgeScaling']))*self.p['maleAgeDieProb'] 
    else:
        ageDieProb = (math.exp(age/self.p['femaleAgeScaling']))* self.p['femaleAgeDieProb']
    rawRate = self.p['baseDieProb'] + babyDieProb + ageDieProb
    
    classPop = [x for x in self.pop.livingPeople if x.careNeedLevel == person.careNeedLevel]
    
    dieProb = self.deathProb(rawRate, person)
    
    person.lifeExpectancy = max(90-person.age, 5)
    #### Temporarily by-passing the effect of unmet care need   ######
    # dieProb = self.deathProb_UCN(rawRate, person.parentsClassRank, person.careNeedLevel, person.averageShareUnmetNeed, classPop)
    
    if np.random.random() < dieProb and np.random.choice([x+1 for x in range(12)]) == month:
        person.dead = True
        person.deadYear = self.year
        deaths[person.classRank] += 1
        person.house.occupants.remove(person)
        if len(person.house.occupants) == 0:
            self.map.occupiedHouses.remove(person.house)
            if (self.p['interactiveGraphics']):
                self.canvas.itemconfig(person.house.icon, state='hidden')
        if person.partner != None:
            person.partner.partner = None
        if person.house == self.displayHouse:
            messageString = str(self.year) + ": #" + str(person.id) + " died aged " + str(age) + "." 
            self.textUpdateList.append(messageString)
            
            with open(os.path.join(policyFolder, "Log.csv"), "a") as file:
                writer = csv.writer(file, delimiter = ",", lineterminator='\r')
                writer.writerow([self.year, messageString])
            
      
self.pop.livingPeople[:] = [x for x in self.pop.livingPeople if x.dead == False]

postDeath = len(self.pop.livingPeople)

print('the number of deaths is: ' + str(preDeath - postDeath))      
=# 


#= 

def deathProb(self, baseRate, person):  ##, shareUnmetNeed, classPop):
        
        classRank = person.classRank
        if person.status == 'child' or person.status == 'student':
            classRank = person.parentsClassRank
        
        if person.sex == 'male':
            mortalityBias = self.p['maleMortalityBias']
        else:
            mortalityBias = self.p['femaleMortalityBias']
        
        deathProb = baseRate
        
        a = 0
        for i in range(int(self.p['numberClasses'])):
            a += self.socialClassShares[i]*math.pow(mortalityBias, i)
            
        if a > 0:
            
            lowClassRate = baseRate/a
            
            classRate = lowClassRate*math.pow(mortalityBias, classRank)
            
            deathProb = classRate
           
            b = 0
            for i in range(int(self.p['numCareLevels'])):
                b += self.careNeedShares[classRank][i]*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - i)
                
            if b > 0:
                
                higherNeedRate = classRate/b
               
                deathProb = higherNeedRate*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - person.careNeedLevel) # deathProb
            
        # Add the effect of unmet care need on mortality rate for each care need level
        
        ##### Temporarily by-passing the effect of Unmet Care Need   #############
        
#        a = 0
#        for x in classPop:
#            a += math.pow(self.p['unmetCareNeedBias'], 1-x.averageShareUnmetNeed)
#        higherUnmetNeed = (classRate*len(classPop))/a
#        deathProb = higherUnmetNeed*math.pow(self.p['unmetCareNeedBias'], 1-shareUnmetNeed)            
=# 