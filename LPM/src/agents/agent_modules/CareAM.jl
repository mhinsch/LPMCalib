module CareAM
    
export Care


@kwdef struct Care
    careNeedLevel :: Int = 0
    socialWork :: Int = 0
    childWork :: Int = 0
    wealthSpentOnCare :: Float64 = 0.0
end

end
