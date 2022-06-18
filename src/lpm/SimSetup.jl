module SimSetup


export loadSimulationParameters 


"""
set simulation paramters @return dictionary of symbols to values

All information needed by the generic SocialSimulations.run! function
is provided here

@return dictionary of required simulation parameters 
"""
function loadSimulationParameters() 
    Dict(:numRepeats=>1,
        :startTime=>1860,
        :finishTime=>2040,
        :dt=>1//12,
        :seed=> floor(Int,time()))
end 


end # SimSetup 