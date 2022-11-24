export ClassBlock

export addClassRank!

mutable struct ClassBlock
    classRank :: Int
    parentClassRank :: Int
end

addClassRank!(class, n=1) = class.classRank += n
