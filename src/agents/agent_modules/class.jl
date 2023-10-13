export addClassRank!

@kwdef struct Class
    classRank :: Int = 0
    parentClassRank :: Int = 0
end

addClassRank!(class, n=1) = class.classRank += n
