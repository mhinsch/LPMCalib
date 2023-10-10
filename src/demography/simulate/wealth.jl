
using StatsBase
using Distributions


"Set individual wealth (depending on income and care expenses)."
function updateWealth!(pop, wealthPercentiles, pars)
    # Only workers: retired are assigned a wealth at the end of their working life 
    # (which they consume thereafter)
    earningPop = [x for x in pop if x.cumulativeIncome > 0]
    
    assignWealthByIncPercentile!(earningPop, wealthPercentiles, pars)
    
    # calculate financial wealth from overall wealth
    # people without wage (== pensioners) only consume financial wealth
    for person in pop
        # Update financial wealth
        if person.wage > 0
            person.financialWealth = person.wealth * pars.shareFinancialWealth
        else
            @assert person.wage == 0
            person.financialWealth -= person.wealthSpentOnCare
            person.financialWealth = max(person.financialWealth, 0.0)
            
            # passive income on wealth
            if person.cumulativeIncome > 0
                person.financialWealth = person.financialWealth * (1 + pars.pensionReturnRate)
            end
        end
    end
    
    nothing
end
