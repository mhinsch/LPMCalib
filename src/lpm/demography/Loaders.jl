module Loaders 

using  Parameters
export UKMapPars, UKPopulationPars, UKDemographyPars
export loadUKDemographyPars

@with_kw mutable struct UKMapPars 
    mapDensityModifier::Float64 = 0.6   # for allocating houses in towns 
    mapGridXDimension::Int      = 8
    mapGridYDimension::Int      = 12
    townGridDimension::Int      = 25
    ukMap::Array{Float64,2}     = [ 0.0 0.1 0.2 0.1 0.0 0.0 0.0 0.0;
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
    
@with_kw mutable struct UKPopulationPars
    baseDieProb::Float64            = 0.0001 
    babyDieProb::Float64            = 0.005 
    femaleAgeDieProb::Float64       = 0.00019   
    femaleAgeScaling::Float64       = 15.5 
    femaleMortalityBias::Float64    = 0.85  
    initialPop::Int                 = 50    # Number of females or males  in the initial population
    maleAgeDieProb::Float64         = 0.00021 
    maleAgeScaling::Float64         = 14.0 
    maleMortalityBias::Float64      = 0.8 
    # a population of males to be randomly generated in the 
    # range of minStartAge - maxStartAge
    maxStartAge::Int                = 45  
    minStartAge::Int                = 25  
end # UKPopulationPars 

@with_kw mutable struct UKBirthPars
    fertilityBias::Float64          =  0.9
    growingPopBirthProb::Float64    =  0.215
    maxPregnancyAge::Int            =  42
    minPregnancyAge::Int            =  17
end 

mutable struct UKDemographyPars 
    mappars::UKMapPars
    poppars::UKPopulationPars
    birthpars::UKBirthPars
end 

function loadUKDemographyPars() 
    # Model parameters 
    ukmapPars   = UKMapPars()
    ukpopPars   = UKPopulationPars() 
    ukbirthPars = UKBirthPars() 

    UKDemographyPars(ukmapPars,ukpopPars,ukbirthPars)
end 



end # Loaders 