function initializeLHA!(towns, pars)
    for y in 1:size(towns)[1], x in 1:size(towns)[2]
        towns[y, x].lha = [pars.lha[1][y,x], 
            pars.lha[2][y,x],
            pars.lha[3][y,x],
            pars.lha[4][y,x]]
    end
    
    nothing
end
