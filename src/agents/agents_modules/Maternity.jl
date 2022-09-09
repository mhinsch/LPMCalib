module Maternity

export MaternityBlock
export giveBirth!, stepMaternity!, resetMaternity!, isInMaternity, maternityDuration

mutable struct MaternityBlock
    maternityStatus :: Bool
    monthsSinceBirth :: Int
end

isInMaternity(mat) = mat.maternityStatus
maternityDuration(mat) = mat.monthsSinceBirth

function giveBirth!(mat)
    mat.maternityStatus = true
    mat.monthsSinceBirth = 0
end

function stepMaternity!(mat)
    mat.monthsSinceBirth += 1
end

function resetMaternity!(mat)
    mat.maternityStatus = false
    mat.monthsSinceBirth = 0
end

end # Maternity
