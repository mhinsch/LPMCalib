function initializeLHA!(towns, pars)
    # this is stupid but at this point towns is not a matrix any more and since
    # in Julia the writing order of Matrix literals differs from their vectorisation
    # order, Vector literals for the lha pars would read as transposed
    lha = [vec(l) for l in pars.lha]
    for (i, t) in enumerate(towns)
        towns[i].lha = [ lha[l][i] for l in 1:4 ] 
    end
    
    nothing
end
