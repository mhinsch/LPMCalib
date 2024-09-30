module BenefitsAM
    

export Benefits


@kwdef struct Benefits
    benefits :: Float64 = 0.0
    highestDisabilityBenefits :: Bool = false
    ucBenefits :: Bool = false
    guaranteeCredit :: Bool = false
end


end
