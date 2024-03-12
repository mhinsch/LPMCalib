using  Parameters
export MapPars, PopulationPars, DivorcePars, WorkPars, ModelPars


"Parameters describing map properties"
@with_kw mutable struct MapPars 
    mapDensityModifier::Float64 = 0.6   # for allocating houses in towns 
    mapGridXDimension::Int      = 8
    mapGridYDimension::Int      = 12
    townGridDimension::Int      = 25
    map::Matrix{Float64}     = [ 0.0 0.1 0.2 0.1 0.0 0.0 0.0 0.0;
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
                                    # Relative population density of UK.  
                                    #   A density of 1.0 corresponds to 
                                    #   the cell with the highest density 
end # UKMapPars
   
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
    =#
    
"Parameters for housing benefits."
@with_kw mutable struct BenefitMapPars
    #
    # Local house allowances for houses with 1,2,3 and 4-bed room houses 
    lha :: Vector{Matrix{Float64}} = [
                    [0.0    91.81  91.81  91.81  0.0    0.0    0.0    0.0;
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
                     0.0    104.89 96.98  0.0    0.0    0.0    0.0    0.0],
    
                    [0.0    110.72 110.72 110.72 0.0    0.0    0.0    0.0;
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
                     0.0    132.32 122.36 0.0    0.0    0.0    0.0    0.0],
    
                    [0.0    126.92 126.92 126.92 0.0    0.0    0.0    0.0;
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
                     0.0    151.50 145.43 0.0    0.0    0.0    0.0    0.0],
    
                    [0.0    160.38 160.38 160.38 0.0    0.0    0.0    0.0;
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
                     0.0    185.29 182.45 0.0    0.0    0.0    0.0    0.0]]
    
end                   


"Parameters related to population setup and dynamics"
@with_kw mutable struct PopulationPars
    startTime :: Rational{Int}  	= 1920
    finishTime :: Rational{Int} 	= 2040 
    initialPop::Int                 = 5000    # Number of females or males  in the initial population
    initialPMales :: Float64		= 0.477   # from 1921 census
    # a population of males to be randomly generated in the 
    # range of minStartAge - maxStartAge
    maxStartAge::Int                = 45  
    minStartAge::Int                = 25  

    startBabySurplus::Int           = 100
    startProbMarried::Float64       = 0.8
    startProbOrphan::Float64        = 0.01

    baseDieProb::Float64            = 0.0001 
    babyDieProb::Float64            = 0.005 
    femaleAgeDieProb::Float64       = 0.00019   
    femaleAgeScaling::Float64       = 15.5 
    femaleMortalityBias::Float64    = 0.85  
    maleAgeDieProb::Float64         = 0.00021 
    maleAgeScaling::Float64         = 14.0 
    maleMortalityBias::Float64      = 0.8 

    cumProbClasses::Vector{Float64} = cumsum([0.2, 0.2, 0.2, 0.2, 0.2])
#    cumProbClasses::Vector{Float64} = cumsum([0.2, 0.35, 0.25, 0.15, 0.05])
end # PopulationPars 


"Parameters related to reproduction"
@with_kw mutable struct BirthPars
    fertilityBias::Float64          =  0.9
    prevChildFertBias::Float64      =  0.9
    growingPopBirthProb::Float64    =  0.215
    maxPregnancyAge::Int            =  50
    minPregnancyAge::Int            =  16
end 


"Parameters related to work and education"
@with_kw mutable struct WorkPars
    maternityLeaveDuration :: Rational{Int}  = 9//12
    ageTeenagers :: Int                 = 13
    ageOfAdulthood :: Int               = 16
    ageOfIndependence :: Int			= 18
    ageOfRetirement :: Int              = 65
    minContributionPeriods :: Int       = 12 * 35
    wageVar :: Float64                  = 0.2
    incomeInitialLevels :: Vector{Float64} = [6.0, 8.0, 10.0, 12.0, 15.0]
    finalIncomeMu :: Vector{Float64} = [2.5, 2.8, 3.2, 3.7, 4.5]
    finalIncomeSigma :: Vector{Float64} = [0.25, 0.3, 0.35, 0.4, 0.5]
    #incomeFinalLevels :: Vector{Float64} = [12.0, 16.0, 25.0, 40.0, 60.0]
    incomeGrowthRate :: Vector{Float64} = [0.4/12.0, 0.35/12.0, 0.3/12.0, 0.25/12.0, 0.2/12.0]
    "specific ages at which people can stop studying and start working"
    startWorkingAge :: Vector{Int}           = [16, 18, 20, 22, 24]
    "working hours by care requirement"
    weeklyHours :: Vector{Float64}      = [40.0, 20.0, 10.0, 0.0, 0.0]
    constantIncomeParam :: Float64      = 50.0
    constantEduParam :: Float64         = 4.0
    eduWageSensitivity :: Float64       = 0.1
    eduRankSensitivity :: Float64       = 4.0
    careEducationParam :: Float64       = 0.0
    workDiscountingTime :: Float64      = 1.0
    moveOutProb :: Float64				= 0.1
    numberAgeBands :: Int				= 6
    taxBrackets :: Vector{Int} = [663, 228, 0]
    taxationRates :: Vector{Float64} = [0.4, 0.2, 0.0]
    unemploymentAgeBias :: Vector{Float64} = [1.0, 0.55, 0.35, 0.25, 0.2, 0.2]
    unemploymentClassBias :: Float64	= 0.75
    shareFinancialWealth :: Float64		= 0.3
    pensionReturnRate :: Float64		= 0.05/12
    shiftsWeights :: Vector{Float64}	= [51.80, 66.10, 70.10, 71.40, 54.10, 63.40, 68.60, 65.00, 
        54.70, 35.00, 20.70, 15.70, 13.00, 11.50, 9.10, 6.80, 4.60, 3.80, 3.20, 3.00, 4.60, 6.70, 
        13.90, 28.80]
    probSaturdayShift :: Float64		= 0.2
    probSundayShift :: Float64			= 0.1
    sundaySocialIndex :: Float64		= 0.5
    shiftBeta :: Float64				= 0.1
    dayBeta :: Float64					= 0.1
    probationPeriod :: Int				= 3
    
    hireRate :: Float64					= log(1/(1-0.25)) # expected mean unempl time == 4 months
end


# work pars for the old ratios job market model
@with_kw mutable struct RMWorkPars
    maleUDS :: Vector{Float64}			= [0.07, 0.11, 0.12, 0.07, 0.07, 0.06, 0.12, 0.06, 0.08, 0.04]
    femaleUDS :: Vector{Float64}		= [0.12, 0.12, 0.12, 0.08, 0.07, 0.08, 0.12, 0.06, 0.06, 0.03]
    
    unemploymentBeta :: Float64			= 1.0
    layOffsBeta :: Float64				= 0.1
    meanLayOffsRate :: Float64			= 0.005
end

"Parameters for benefits."
@with_kw mutable struct BenefitPars
    childBenefitIncomeThreshold :: Float64 = 50000
    firstChildBenefit :: Float64 = 21.15
    otherChildrenBenefit :: Float64 = 14.0
    
    careDLA :: Vector{Float64} = [23.70, 60.00, 89.60]
    mobilityDLA :: Vector{Float64} = [23.70, 62.55]
    carePIP :: Vector{Float64} = [60.00, 89.60]
    mobilityPIP :: Vector{Float64} = [23.70, 62.55]
    careAA :: Vector{Float64} = [60.00, 89.60]
    carersAllowance :: Float64 = 67.60
    
    capitalHighThreshold :: Float64 = 16000.0
    capitalLowThreshold :: Float64 = 6000.0
    capitalIncome :: Float64 = 4.35
    savingUCRate :: Float64 = 250
    workAllowanceHS :: Float64 = (293.0*12)/52.0
    workAllowanceNoHS :: Float64 = (515.0*12)/52.0    
    incomeReduction :: Float64 = 0.63
    singleBelow25 :: Float64 = (257.33*12)/52.0
    single25Plus :: Float64 = (324.84*12)/52.0
    coupleBelow25 :: Float64 = ((403.93*12)/52.0)/2.0
    couple25Plus :: Float64 = ((509.91*12)/52.0)/2.0
    eaChildren :: Float64 = (237.08*12)/52.0
    eaDisabledChildren :: Vector{Float64} = [(128.89*12)/52.0, (402.41*12)/52.0]
    lcfwComponent :: Float64 = (343.63*12)/52.0
    carersComponent :: Float64  = (163.73*12)/52.0
    
    singlePC :: Float64 = 177.10 # Top-up
    couplePC :: Float64 = 270.30 # Top-up
    wealthAllowancePC :: Float64 = 10000.0
    savingIncomeRatePC :: Float64 = 500
    disabilityComponentPC :: Float64 = 67.30
    caringComponentPC :: Float64 = 37.70
    childComponentPC :: Float64 = 54.60
    disabledChildComponent :: Vector{Float64} = [29.66, 92.54]
    housingBenefitWealthThreshold :: Float64 = 16000.0
end

"Divorce"
@with_kw mutable struct DivorcePars
    basicDivorceRate :: Float64             = 0.06
    divorceModifierByDecade :: Vector{Float64}   = [0.0, 1.0, 0.9, 0.5, 0.4, 0.2, 0.1, 0.03, 0.01, 0.001, 0.001, 0.001, 0.0, 0.0, 0.0, 0.0] 
    probChildrenWithFather  :: Float64      = 0.1
    thePresent :: Int                       = 2012
    variableDivorce :: Float64              = 0.06
    divorceBias :: Float64                  = 0.9
end 


"Marriage"
@with_kw mutable struct MarriagePars
    basicMaleMarriageProb :: Float64            = 0.7
    maleMarriageModifierByDecade :: Vector{Float64} = [ 0.0, 0.16, 0.5, 1.0, 0.8, 0.7, 0.66, 0.5, 0.4, 0.2, 0.1, 0.05, 0.01, 0.0, 0.0, 0.0 ]
    notWorkingMarriageBias :: Float64           = 0.5
    manWithChildrenBias :: Float64              = 0.9
    probApartWillMoveTogether :: Float64        = 1.0
    couplesMoveToExistingHousehold :: Float64   = 0.0
    "effect of distance on marriage prob."
    betaGeoExp :: Float64                       = 0.2
    studentFactorParam :: Float64               = 0.5
    "effect of class diff on marriage prob."
    betaSocExp :: Float64                       = 2.0
    rankGenderBias :: Float64                   = 0.5
    "prob dist of age difference"
    modeAgeDiff	:: Float64						= 2.0
    maleOlderFactor :: Float64					= 0.1
    maleYoungerFactor :: Float64				= 0.3
    bridesChildrenExp :: Float64                = 0.5
end

"Social care"
@with_kw mutable struct CarePars
    numCareLevels :: Int						= 5
    careBias :: Float64							= 0.9
    careNeedBias :: Float64 					= 0.9
    femaleAgeCareScaling :: Float64				= 19.0
    maleAgeCareScaling :: Float64				= 18.0
    personCareProb :: Float64					= 0.0008
    baseCareProb :: Float64						= 0.0002
    "care demand dependent on need level"
    careDemandInHours :: Vector{Int}			= [ 0, 14, 28, 56, 84 ]
    careTransitionRate :: Float64				= 0.7
    zeroYearCare :: Int							= 80
    childCareDemand :: Int						= 168
    freeChildCareHoursPreSchool :: Int			= 24
    freeChildCareHoursSchool :: Int				= 32
    "weekly care supply for child, teenager, student, worker, retired, unemployed"
    careSupplyByStatus :: Vector{Int}			= [ 0, 10, 24, 32, 60, 48 ]
    careQuantum :: Int							= 2
end

"Care tasks"
@with_kw mutable struct TaskCarePars
    "how often to iterate care distribution"
    nIterCareDist :: Int						= 3
    stopBabyCareAge :: Int						= 1
    stopChildCareAge :: Int						= 13
    babyCarePerDay :: Int						= 14
    childCarePerDay :: Int						= 14
    socialCareDemandPerDay :: Vector{Int}		= [ 0, 2, 4, 8, 12 ]
    careSupplyMaternity :: Int					= 98
    "effect of task importance on acceptance probability"
    acceptProbPolarity :: Float64				= 2
    "Care weight by relatedness and type. Relatedness (carer is): child, parent, partner, sibling, other. Type: child care, social care."
    careWeightRelated :: Matrix{Float64}		= [ Inf 0.5; 1.0 1.0; Inf 1.0; 0.8 0.5; 0.5 0.2 ]
    "Care weight by (spatial) distance in order: same house, same town, otherwise."
    careWeightDistance :: Vector{Float64}		= [1.0, 0.5, 0.1]
end

"housing"
@with_kw mutable struct HousingPars
    ownershipProbExp :: Float64 = 0.1
    incomeOwnershipShares :: Vector{Float64} = [0.2, 0.4, 0.5, 0.57, 0.63, 0.67, 0.71, 0.75, 0.79, 0.83]
    ageOwnershipShares :: Vector{Float64} = [0.12, 0.44, 0.61, 0.71, 0.77, 0.79]
    HOAgeRanges :: Vector{Float64} = [24, 34, 44, 54, 64]
    HOAgeBiases :: Vector{Float64} = [1.0, 3.67, 5.0, 5.9, 6.4, 6.6]
end



"Data files"
@with_kw mutable struct DataPars
    datadir     :: String = "data"
    iniAgeFName :: String = "age_pyramid_1921_5y.csv"
    pre51FertFName :: String = "birthrate_early.csv"
    fertFName   :: String = "babyrate.txt.csv"
    pre51DeathsFName :: String = "deathrates_early.csv"
    deathFFName :: String = "deathrate.fem.csv"
    deathMFName :: String = "deathrate.male.csv"
    unemplFName :: String = "unemploymentrate.csv"
    wealthFName :: String = "wealthDistribution.csv"
end



struct ModelPars 
    mappars     ::  MapPars
    lhapars		:: BenefitMapPars
    poppars     ::  PopulationPars
    birthpars   ::  BirthPars
    workpars    ::  WorkPars
    benefitpars :: BenefitPars
    divorcepars ::  DivorcePars 
    marriagepars :: MarriagePars
    carepars :: CarePars
    taskcarepars :: TaskCarePars
    housingpars :: HousingPars
    datapars    :: DataPars
end 


ModelPars() = ModelPars(MapPars(), BenefitMapPars(), PopulationPars(), BirthPars(), WorkPars(), 
              BenefitPars(), DivorcePars(), MarriagePars(), CarePars(), TaskCarePars(), HousingPars(), 
              DataPars())

