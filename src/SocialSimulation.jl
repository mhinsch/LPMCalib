"Functionalities for simulating Social Mulit-ABMs"
module SocialSimulation

    export loadData, initDummyABMs, runDummyExample  

    using SocialABMs

    function loadData() 
        # load data 
        nothing 
    end 

    "Initialize elemantry ABMs"
    function initDummyABMs()
        # init Houses 
        
        # init Towns

        # init Population 
        population = initDummyPopulation() 
        @show population

        # init Households
        (population,)
    end 

    "execute agent and model stepping functions"  
    function runDummyExample() 
        nothing 
    end 

    #=
    just a list of [stepping] functions to operate a Multi ABM 
    design of function arguments and return values to be specified later
    =# 

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

end # SocialSimulation 