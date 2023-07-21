struct Link{T}
    t1 :: T
    t2 :: T
end


function kinshipNetwork(filter, house, model, pars)
    LinkT = Link{typeof(house)}
    conns = Vector{LinkT}()

    function checkAndAdd!(h)
        if h != house && filter(h)
            push!(conns, LinkT(house, h))
        end
    end
    
    for person in house.occupants
        if !isSingle(person) 
            checkAndAdd!(person.partner.pos)
        end
        
        for child in person.children
            checkAndAdd!(child.pos)
        end
        
        f = person.father 
        if !isUndefined(f) 
            checkAndAdd!(f.pos)
        end
        
        m = person.mother 
        if !isUndefined(m) 
            checkAndAdd!(m.pos)
        end
    end
    
    conns
end
