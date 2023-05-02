struct Link{T}
    t1 :: T
    t2 :: T
end


function kinshipNetwork(filter, house, model, pars, make_unique=false)
    LinkT = Link{typeof(house)}
    conns = Vector{LinkT}()

    function checkAndAdd!(h)
        if h != house && filter(h)
            push!(conns, LinkT(house, h))
        end
    end
    
    for person in house.occupants
        if !isSingle(person) 
            checkAndAdd!(person.pos)
        end
        
        for child in children(person)
            checkAndAdd!(child.pos)
        end
        
        f = father(person) 
        if f != nothing 
            checkAndAdd!(f.pos)
        end
        
        m = mother(person) 
        if m != nothing 
            checkAndAdd!(m.pos)
        end
    end
    
    if make_unique
        sort!(conns)
        unique!(conns)
    end
    
    conns
end
