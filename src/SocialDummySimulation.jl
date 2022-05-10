"""
Establishing an artificial dummy abm-based communities 
and implementing various simulations upon
"""

module SocialDummySimulation

    export loadData, initDummyABMs, runDummyExample  

    using SocialAgents, SocialABMs

    function loadData() 
        # load data 
        nothing 
    end 

    "Initialize elemantry ABMs"
    function initDummyABMs()
        # init Towns
         
        glasgow   = Town((10,10),"Glasgow") 
        edinbrugh = Town((11,12),"Edinbrugh")
        sterling  = Town((12,10),"Sterling") 
        aberdeen  = Town((20,12),"Aberdeen")
        towns = [aberdeen,edinbrugh,glasgow,sterling]

        # init Houses 

        numberOfHouses = 100 
        sizes = ["small","medium","big"]

        houses = House[] 
        for index in range(1,numberOfHouses)
            town = rand(towns)
            sz   = rand(sizes) 
            x,y  = rand(1:10),rand(1:10)
            push!(houses,House(town,(x,y),sz))
        end
        @show houses[1:10]
        # init Population 

        population = initDummyPopulation(houses) 
        @show population

        # init Households
        (towns,houses,population)
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