"Implements the UK benefits system."



module Benefits
    

using Utilities

using BasicInfoAM, KinshipAM, WorkAM, DependenciesAM, DemoPerson


export computeBenefits!


# Debug benefit allocation process
function computeBenefits!(pop, pars)
    
    # Reset counters
    for agent in pop
        agent.benefits = 0
        agent.highestDisabilityBenefits = false
        agent.ucBenefits = false
    end
    
    childBenefits!(pop, pars)
    
    disabilityBenefits!(pop, pars)
    
    universalCredit!(pop, pars)
    
    pensionCredit!(pop, pars)
end


function childBenefits!(pop, pars)
    for parent in Iterators.filter(hasDependents, pop)
        nDeps = length(parent.dependents)
        if nDeps > 0
            totChildBenefit = 0
            if isSingle(parent)
                if parent.income < pars.childBenefitIncomeThreshold
                    totChildBenefit = pars.firstChildBenefit
                    totChildBenefit += pars.otherChildrenBenefit * (nDeps-1)
                end
            else
                if parent.income < pars.childBenefitIncomeThreshold || 
                        parent.partner.income < pars.childBenefitIncomeThreshold
                    totChildBenefit = pars.firstChildBenefit/2
                    totChildBenefit += pars.otherChildrenBenefit * (nDeps-1)/2
                end
            end
            parent.benefits += totChildBenefit
        end
    end
end


function disabilityBenefits!(pop, pars)
    for child in Iterators.filter(x->x.age<16 && x.careNeedLevel>0, pop)
        disabledChildBenefit = pars.careDLA[floor(Int, child.careNeedLevel/2) + 1] + 
            pars.mobilityDLA[floor(Int, (child.careNeedLevel+1)/2)]
        child.benefits += disabledChildBenefit
        child.highestDisabilityBenefits = child.careNeedLevel > 3
    end
        
    ## PIP
    for agent in Iterators.filter(x->16<=x.age<pars.ageOfRetirement && x.careNeedLevel>0, pop)
        disabledAdultBenefit = pars.carePIP[floor(Int, (agent.careNeedLevel+1)/2)]
        if agent.careNeedLevel > 1
            disabledAdultBenefit += pars.mobilityPIP[floor(Int, agent.careNeedLevel/2)]
        end
        
        agent.highestDisabilityBenefits = agent.careNeedLevel > 2
        agent.benefits += disabledAdultBenefit
    end
            
    ## Attendance Allowance
    for agent in Iterators.filter(x->x.age>=pars.ageOfRetirement && x.careNeedLevel>2, pop)
        disabledPensionerBenefit = 0
        if agent.careNeedLevel == 3
            disabledPensionerBenefit = pars.careAA[1]
        else
            disabledPensionerBenefit = pars.careAA[2]
        end
        agent.benefits += disabledPensionerBenefit
    end
        
    ## Carers' Allowance
    for agent in Iterators.filter(x->x.socialWork >= 35, pop)
        agent.benefits += pars.carersAllowance
    end
end


function isUCEligibleAdult(agent, pars)
    18<=agent.age<pars.ageOfRetirement && 
        (statusWorker(agent) || statusUnemployed(agent))            
end


function isUCEligibleStudent(agent, pars)
    statusStudent(agent) && (
        hasDependents(agent) ||
        agent.age >= pars.ageOfRetirement ||
        (!isSingle(agent) && agent.partner.ucBenefits) ||
        agent.careNeedLevel > 0 ) 
end


function isUCEligibleYoung(agent, pars)
    16<=agent.age<18 && (
        (statusStudent(agent) && isUndefined(agent.father) && isUndefined(agent.mother)) ||
        agent.socialWork >= 35 ||
        hasOwnChildrenAtHome(agent) )
end


function universalCredit!(pop, pars)
    # Condition 1: age between 18 and 64
    # Condition 2: low income or unemployed
    # Condition 3: Savings less than 16000
    
    for agent in Iterators.filter(x->isUCEligibleAdult(x, pars), pop)
        computeUC!(agent, pars)
    end
    
    # need to do that afterwards, so that partners have been processed
    for agent in Iterators.filter(x->isUCEligibleStudent(x, pars) || isUCEligibleYoung(x, pars), pop) 
        computeUC!(agent, pars)
    end
    
    # Housing element (for renters): LHA rate based on household composition (number of rooms).
    # 1 room for each of the following:
    # The household's head and partner
    # Any other person over 16, as long as they aren't living with you as your tenant
    # Two children under 16 of the same gender
    # Two children under 10
    # Any other child under 16
    for agent in Iterators.filter(x->x.ucBenefits && !x.pos.ownedByOccupants && !isDependent(x), pop)
        if isSingle(agent) || !agent.partner.ucBenefits
            agent.benefits += agent.pos.town.lha[computeMaxRooms(agent.pos, pars)]
        else
            agent.benefits += agent.pos.town.lha[computeMaxRooms(agent.pos, pars)]/2.0
        end
    end
end


nDependents(house) = count(x -> x.age<16 || (x.age<20&&x.status==WorkStatus.student), house.occupants)
            
nMildlyDisabledDependents(house) = count(x -> (x.age<16 || (x.age<20&&x.status==WorkStatus.student)) &&
    x.careNeedLevel > 0 && !x.highestDisabilityBenefits, house.occupants)

nCritDisabledDependents(house) = count(x -> (x.age<16 || (x.age<20&&x.status==WorkStatus.student)) &&
    x.highestDisabilityBenefits, house.occupants)
    
    
function computeUC!(agent, pars)
    totalWealth = agent.financialWealth + (isSingle(agent) ? 0 : agent.partner.financialWealth)
    # no UC above wealth threshold
    if totalWealth >= pars.capitalHighThreshold
        return nothing
    end
    
    totalIncome = agent.income + (isSingle(agent) ? 0 : agent.partner.income)
    
    ucIncome = totalIncome + pars.capitalIncome *
        max(0.0, floor(Int, (agent.financialWealth-pars.capitalLowThreshold)/pars.savingUCRate))
        
    nUCDeps = nDependents(agent.pos)
        
    # TODO! dependence needs to be done properly
    if (!isDependent(agent) && nUCDeps > 0) || agent.careNeedLevel > 0
        if ! agent.pos.ownedByOccupants # Assuming the agent will get the Housing Cost element
            ucIncome = max(ucIncome-pars.workAllowanceHS, 0.0)
        else
            ucIncome = max(ucIncome-pars.workAllowanceNoHS, 0.0)
        end
    end
    
    ucReduction = ucIncome * pars.incomeReduction
    benefit = 0
    if isSingle(agent)
        if agent.age < 25
            benefit = max(pars.singleBelow25-ucReduction, 0.0)
        else
            benefit = max(pars.single25Plus-ucReduction, 0.0)
        end
    else
        if agent.age < 25 && agent.partner.age < 25
            benefit = max(pars.coupleBelow25-ucReduction, 0.0)/2.0
        else
            benefit = max(pars.couple25Plus-ucReduction, 0.0)/2.0
        end
    end
    
    if benefit > 0
        agent.ucBenefits = true
    end
    agent.benefits += benefit
    
    # Extra for children
    numChildBenefits = min(nUCDeps, 2)
    benefit = pars.eaChildren * numChildBenefits
    agent.benefits += benefit/(isSingle(agent) ? 1.0 : 2.0)
    if benefit > 0
        agent.ucBenefits = true
    end
    
    # Extra for disabled children
    nMildlyDisabledUCDeps = nMildlyDisabledDependents(agent.pos)
        
    totalDisabledChildBenefits = pars.eaDisabledChildren[1] * nMildlyDisabledUCDeps
    agent.benefits += totalDisabledChildBenefits/(isSingle(agent) ? 1.0 : 2.0)
    if totalDisabledChildBenefits > 0
        agent.ucBenefits = true
    end
        
    nCritDisabledUCDeps = nCritDisabledDependents(agent.pos)
    totalDisabledChildBenefits = pars.eaDisabledChildren[2] * nCritDisabledUCDeps
    agent.benefits += totalDisabledChildBenefits/(isSingle(agent) ? 1.0 : 2.0)
    if totalDisabledChildBenefits > 0
        agent.ucBenefits = true
    end
    
    # Extra for disability
    if agent.careNeedLevel > 1
        agent.benefits += pars.lcfwComponent # limited capability for work and related activity
        agent.ucBenefits = true
    end
        
    # Extra for social work
    if agent.socialWork > 35
        agent.benefits += pars.carersComponent
        agent.ucBenefits = true
    end
    
    nothing
end    
    

function pensionCredit!(pop, pars)
    # Condition 1: 65 or older (both, if a couple)
    for agent in Iterators.filter(x->x.age>=pars.ageOfRetirement, pop)
        agent.guaranteeCredit = false
        if isSingle(agent)
            benefitIncome = agent.income + 
                max(0.0, floor((agent.financialWealth-pars.wealthAllowancePC)/pars.savingIncomeRatePC))
            agent.benefits += max(pars.singlePC-benefitIncome, 0)
            if max(pars.singlePC-benefitIncome, 0) > 0
                agent.guaranteeCredit = true
            end
        elseif agent.partner.age >= pars.ageOfRetirement
            totalIncome = agent.income + agent.partner.income
            totalWealth = agent.financialWealth + agent.partner.financialWealth
            aggregateBenefitIncome = totalIncome + 
                max(0.0, floor((totalWealth-pars.wealthAllowancePC)/pars.savingIncomeRatePC))
            agent.benefits += max(pars.couplePC-aggregateBenefitIncome, 0)/2.0
            if max(pars.couplePC-aggregateBenefitIncome, 0)/2.0 > 0
                agent.guaranteeCredit = true
            end
        end
        
        ## Severe disability extra
        if agent.careNeedLevel > 2
            agent.benefits += pars.disabilityComponentPC
            agent.guaranteeCredit = true
        end
        if agent.socialWork >= 35
            agent.benefits += pars.caringComponentPC
            agent.guaranteeCredit = true
        end
        
        if !isDependent(agent)
            nDeps = nDependents(agent.pos)
            if nDeps > 0
                totalChildBenefit = pars.childComponentPC * nDeps
                if !isSingle(agent) && agent.partner.age >= pars.ageOfRetirement
                    totalChildBenefit /= 2.0
                end
                agent.benefits += totalChildBenefit
                agent.guaranteeCredit = true
                
                # Disabled children
                nMildlyDisabledDeps = nMildlyDisabledDependents(agent.pos)
                totalDisabledChildBenefits = pars.disabledChildComponent[1] * nMildlyDisabledDeps
                if !isSingle(agent) && agent.partner.age >= pars.ageOfRetirement
                    totalDisabledChildBenefits /= 2.0
                end
                agent.benefits += totalDisabledChildBenefits
                agent.guaranteeCredit = true
                
                nCritDisabledDeps = nCritDisabledDependents(agent.pos)
                totalDisabledChildBenefits = pars.disabledChildComponent[2] * nCritDisabledDeps
                if !isSingle(agent) && agent.partner.age >= pars.ageOfRetirement
                    totalDisabledChildBenefits /= 2.0
                end
                agent.benefits += totalDisabledChildBenefits
                agent.guaranteeCredit = true
            end
        end
       
        # Housing benefit (for renters): LHA rate based on household composition (number of rooms).
        if !isDependent(agent) && !agent.pos.ownedByOccupants
            if isSingle(agent)
                if agent.financialWealth < pars.housingBenefitWealthThreshold || agent.guaranteeCredit
                    agent.benefits += agent.pos.town.lha[computeMaxRooms(agent.pos, pars)]
                end
            elseif agent.partner.age >= pars.ageOfRetirement
                totalWealth = agent.financialWealth+agent.partner.financialWealth
                if totalWealth < pars.housingBenefitWealthThreshold || agent.guaranteeCredit
                    agent.benefits += agent.pos.town.lha[computeMaxRooms(agent.pos, pars)]/2.0
                end
            end
        end
     end
end    


function computeMaxRooms(house, pars)
    allowedRooms = 0
    nMaleTeens = 0
    nFemaleTeens = 0
    nChildren = 0
    nCouples = 0
    for occ in house.occupants
        if !isSingle(occ) && livingTogether(occ, occ.partner)
            nCouples += 1
        end
        
        if occ.age >= 16 
            allowedRooms += 1
        elseif occ.age >= 10
            isMale(occ) ? nMaleTeens += 1 : nFemaleTeens += 1
        else
            nChildren += 1
        end
    end    
    
    allowedRooms -= nCouples ÷ 2
    allowedRooms += ceil(Int, nMaleTeens / 2)
    allowedRooms += ceil(Int, nFemaleTeens / 2)
    allowedRooms += ceil(Int, nChildren / 2)
    
    min(4, allowedRooms)
end

end
