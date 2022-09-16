module Maternity

export MaternityBlock
export startMaternity!, stepMaternity!, endMaternity!, isInMaternity, maternityDuration

mutable struct MaternityBlock
    maternityStatus :: Bool
    monthsSinceBirth :: Int
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

end # Maternity
