export ClassBlock

export addClassRank!

mutable struct ClassBlock
    classRank :: Int
end

addClassRank!(class, n) = class.classRank += 1
