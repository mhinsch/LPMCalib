module SocialSimulation


    function execute() 
        
        loadData() 

        initABMs()
        
        # After a Multi ABM has been initialized run the simulation 

        run() 

        nothing 
    end 

    function loadData() 
        # load data 

        nothing 
    end 

    function initABMs()
        # init Population 

        # init Households 

        nothing 
    end 

    function run() 
        # execute agent and model stepping functions  

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