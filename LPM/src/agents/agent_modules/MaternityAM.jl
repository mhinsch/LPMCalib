module MaternityAM
    
export Maternity
export startMaternity!, stepMaternity!, endMaternity!, isInMaternity, maternityDuration

@kwdef struct Maternity
    maternityStatus :: Bool = false
    monthsSinceBirth :: Int = 0
end

isInMaternity(mat) = mat.maternityStatus
maternityDuration(mat) = mat.monthsSinceBirth

function startMaternity!(mat)
    mat.maternityStatus = true
    mat.monthsSinceBirth = 0
end

function stepMaternity!(mat)
    mat.monthsSinceBirth += 1
end

function endMaternity!(mat)
    mat.maternityStatus = false
    mat.monthsSinceBirth = 0
end

end
