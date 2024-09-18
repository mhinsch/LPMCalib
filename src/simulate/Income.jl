module Income
    

using Utilities

using WorkAM, MaternityAM
using DemoHouse

export updateIncome!


function updatePersonIncome!(person, pars)
    if statusWorker(person)
        if isInMaternity(person)
            maternityIncome = person.income
            if monthsSinceBirth(person) == 0
                person.wage = 0
                maternityIncome = pars.maternityLeaveIncomeReduction * person.income
            elseif monthsSinceBirth(person) > 2
                maternityIncome = min(pars.minStatutoryMaternityPay, maternityIncome)
            end
            person.income = maternityIncome
        else
            person.income = person.wage * person.availableWorkingHours
            person.lastIncome = person.wage * pars.weeklyHours[person.careNeedLevel+1]
        end
    elseif statusRetired(person)
        person.income = person.pension
    else
        person.income = 0
    end
    
    person.disposableIncome = person.income
end


function updateIncome!(model, time, pars)
    year, month = date2yearsmonths(time)
    # Compute income from work based on last period job market and informal care
    for person in model.pop
        updatePersonIncome!(person, pars)
    end

    for house in Iterators.filter(isOccupied, model.houses)
        if month == 1
            #house.yearlyIncome = 0
            #house.yearlyDisposableIncome = 0
            #house.yearlyBenefits = 0
        end
        house.householdIncome = sum(x->x.income, house.occupants)
        house.incomePerCapita = house.householdIncome/length(house.occupants)
        #house.yearlyIncome += (house.householdIncome*52.0)/12
    end
        

    # Now, compute disposable income (i..e after taxes and benefits)
    # First, reduce by tax
    #totalTaxRevenue = 0
    #totalPensionRevenue = 0
    for person in Iterators.filter(x->x.income>0, model.pop)
        employeePensionContribution = 0
        # Pension Contributions
        if person.disposableIncome > 162.0
            if person.disposableIncome < 893.0
                employeePensionContribution = (person.disposableIncome - 162.0) * 0.12
            else
                employeePensionContribution = (893.0 - 162.0) * 0.12
                employeePensionContribution += (person.disposableIncome - 893.0) * 0.02
            end
        end
        person.disposableIncome -= employeePensionContribution
        #totalPensionRevenue += employeePensionContribution
        
        # Tax Revenues
        tax = 0
        residualIncome = person.disposableIncome
        for (i, taxb) in enumerate(pars.taxBrackets)
            if residualIncome > taxb
                taxable = residualIncome - taxb
                tax += taxable * pars.taxationRates[i]
                residualIncome -= taxable
            end
        end
        person.disposableIncome -= tax
        #totalTaxRevenue += tax
    end
        
    #push!(statePensionRevenue, totalPensionRevenue)
    #push!(stateTaxRevenue, totalTaxRevenue)
    
    # ...then add benefits
    for person in model.pop
        person.disposableIncome += person.benefits
        #person.yearlyBenefits = person.benefits * 52.0
        #push!(person.yearlyDisposableIncomes, person.disposableIncome * 4.35)
        #if length(person.yearlyDisposableIncomes) > 12
        #    deleteat!(person.yearlyDisposableIncomes, 1)
        #end
        #person.yearlyDisposableIncome = sum(person.yearlyDisposableIncomes)
        person.cumulativeIncome += person.disposableIncome
    end
    
    #for house in Iterators.filter(isOccupied, model.houses)
        #house.householdDisposableIncome = sum(x->x.disposableIncome, house.occupants)
        #house.benefits = sum(x->x.benefits, house.occupants)
        #house.yearlyDisposableIncome = house.householdDisposableIncome * 52.0
        #house.yearlyBenefits = house.benefits * 52.0
        #house.disposableIncomePerCapita = house.householdIncome/length(house.occupants)
    #end
    
    
    # Then, from the household income subtract the cost of formal child and social care
    #for house in Iterators.filter(isOccupied, model.houses)
    #    house.householdNetIncome = house.householdDisposableIncome-house.costFormalCare
    #    house.netIncomePerCapita = house.householdNetIncome/float(len(house.occupants))
    #end
    
    #for house in Iterators.filter(isOccupied, model.houses)
        #house.totalIncome = sum(x->x.totalIncome, house.occupants)
        # poverty line income not yet needed (required for care assignment in
        # original model)
        #house.povertyLineIncome = 0
        #=independentMembers = filter(x->!isDependent(x), house.occupants)
        if length(independentMembers) == 1
            independentPerson = independentMembers[1]
         #   if independentPerson.status == WorkStatus.worker
         #       house.povertyLineIncome = pars.singleWorker
         #   elseif independentPerson.status == WorkStatus.retired
         #       house.povertyLineIncome = pars.singlePensioner
         #   end
        elseif length(independentMembers) == 2
            independentPerson_1 = independentMembers[1]
            independentPerson_2 = independentMembers[2]
            if independentPerson_1.status == WorkStatus.worker == independentPerson_2.status
                house.povertyLineIncome = pars.marriedCouple
            elseif (independentPerson_1.status == WorkStatus.retired && 
                    independentPerson_2.status == WorkStatus.worker) || 
                (independentPerson_2.status == WorkStatus.retired && 
                    independentPerson_1.status == WorkStatus.worker)
                house.povertyLineIncome = pars.mixedCouple
            elseif independentPerson_1.status == WorkStatus.retired == independentPerson_2.status
                house.povertyLineIncome = pars.couplePensioners
            end
        end=#
        #nDependentMembers = count(isDependent, house.occupants)
        #house.povertyLineIncome += nDependentMembers * pars.additionalChild
    #end 
end


end
