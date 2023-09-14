# Debugg benefit allocation process
function computeBenefits!(pop, pars)
    
    # Reset counters
    for agent in pop.people
        agent.benefits = 0
        agent.highestDisabilityBenefits = False
        agent.ucBenefits = False
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
                if parent.income < pars.childBenefitIncomeThreshold:
                    totChildBenefit = pars.firstChildBenefit
                    totChildBenefit += pars.otherChildrenBenefit * (nDeps-1)
                end
            else
                if parent.income < pars.childBenefitIncomeThreshold || 
                        parent.partner.income < pars.childBenefitIncomeThreshold
                    totChildBenefit = pars.firstChildBenefit/2
                    totChildBenefit += pars.otherChildrenBenefit * (nDeps-1)/2
                end
            parent.benefits += totChildBenefit
        end
    end
end


function disabilityBenefits(pop, pars)
    for child in Iterators.filter(x->x.age<16 && x.careNeedLevel>0, pop)
        disabledChildBenefit = pars.careDLA[floor(Int, child.careNeedLevel/2)] + 
            pars.mobilityDLA[floor(Int, (child.careNeedLevel-1)/2)]
        child.benefits += disabledChildBenefit
        child.highestDisabilityBenefits = child.careNeedLevel > 3
    end
        
    ## PIP
    for agent in Iterators.filter(x->16<=x.age<pars.ageOfRetirement && x.careNeedLevel>0, pop)
        disabledAdultBenefit = pars.carePIP[floor(Int, (agent.careNeedLevel-1)/2)]
        if agent.careNeedLevel > 1
            disabledAdultBenefit + pars.mibilityPIP[floor(Int, (agent.careNeedLevel-2)/2)]
        end
        
        agent.highestDisabilityBenefits = agent.careNeedLevel > 2
        agent.benefits += disabledAdultBenefit
    end
            
    ## Attendance Allowance
    for agent in Iterators.filter(x->x.age>=pars.ageOfRetirement && x.careNeedLevel>2, pop)
        disabledPensionerBenefit = 0
        if agent.careNeedLevel == 3:
            disabledPensionerBenefit = pars.careAA[0]
        else:
            disabledPensionerBenefit = pars.careAA[1]
        agent.benefits += disabledPensionerBenefit
        self.aggregateAttendanceAllowance += disabledPensionerBenefit
        
    ## Carers' Allowance
    fullTimeCarers = [x for x in self.pop.livingPeople if x.socialWork >= 35]
    for agent in fullTimeCarers:
        agent.benefits += pars.carersAllowance
        self.aggregateCarersAllowance += pars.carersAllowance
    
    print 'Total disabled children benefits: ' + str(self.aggregateDisabledChildrenBenefits)
    print 'Total disabled adults benefits: ' + str(self.aggregatePIP)
    print 'Total disabled retired benefits: ' + str(self.aggregateAttendanceAllowance)
    print 'Total disabled carers benefits: ' + str(self.aggregateCarersAllowance)
    

def universalCredit(self):
    print 'Work in progress....'
    self.aggregateUC = 0
    self.aggregateHousingElement = 0
    # Condition 1: age between 18 and 64
    # Condition 2: low income or unemployed
    # Condition 3: Savings less than 16000
    ucAgeBand = [x for x in self.pop.livingPeople if x.age >= 18 and x.age < pars.ageOfRetirement]
    ucPopulation = [x for x in ucAgeBand if x.status == 'worker' or x.status == 'unemployed']
    
    for agent in ucPopulation:
        self.computeUC(agent)
                
    students = [x for x in ucAgeBand if x.status == 'student']
    studentWithChildren = [x for x in students if len([y for y in x.children if x.house == y.house]) > 0]
    pensionersStudents = [x for x in students if x.age >= pars.ageOfRetirement and x not in studentWithChildren]
    allStudents = studentWithChildren+pensionersStudents
    studentsWithUCPartner = [x for x in students if x.partner != None and x.partner.ucBenefits == True and x not in allStudents]
    allStudents += studentsWithUCPartner
    disabledStudents = [x for x in students if x.careNeedLevel > 0 and x not in allStudents]
    allStudents += disabledStudents
    
    for student in allStudents:
        self.computeUC(student)
    
    under18s = [x for x in self.pop.livingPeople if x.age >= 16 and x.age < 18 and x not in allStudents]
    loneStudents = [x for x in under18s if x.status == 'student' and x.mother.dead == True and x.father.dead == True]
    caringUnder18s = [x for x in under18s if x.socialWork >= 35 and x not in loneStudents]
    allUnder18s = caringUnder18s+loneStudents
    under18sWitChild = [x for x in under18s if x.independentStatus == True and len([y for y in x.children if x.house == y.house]) > 0 and x not in allUnder18s]
    allUnder18s += under18sWitChild
    
    for under18 in allUnder18s:
        self.computeUC(under18)
    
    print 'Total Universal Credit: ' + str(self.aggregateUC)
    
    # Housing element (for renters): LHA rate based on household composition (number of rooms).
    # 1 room for each of the following:
    # The household's head and partner
    # Any other person over 16, as long as they aren't living with you as your tenant
    # Two children under 16 of the same gender
    # Two children under 10
    # Any other child under 16
    ucRecipients = [x for x in self.pop.livingPeople if x.ucBenefits == True]
    rentingRecipients = [x for x in ucRecipients if x.independentStatus == True and x.house.ownedByOccupants == False]
    for agent in rentingRecipients:
        if agent.partner == None or agent.partner.ucBenefits == False:
            agent.benefits += agent.house.town.LHA[self.computeMaxRooms([agent]) - 1]
            self.aggregateHousingElement += agent.house.town.LHA[self.computeMaxRooms([agent]) - 1]
        else:
            agent.benefits += agent.house.town.LHA[self.computeMaxRooms([agent, agent.partner]) - 1]/2.0
            self.aggregateHousingElement += agent.house.town.LHA[self.computeMaxRooms([agent, agent.partner]) - 1]/2.0
            

def computeUC(self, agent):
    if agent.partner == None:
        if agent.financialWealth < pars.capitalHighThreshold:
            ucIncome = agent.income + max(math.floor((agent.financialWealth-pars.capitalLowThreshold)/pars.savingUCRate), 0.0)*pars.capitalIncome
            youngMembers = [x for x in agent.house.occupants if x.age < 16 or (x.age < 20 and x.status == 'student')]
            if (agent.independentStatus == True and len(youngMembers) > 0) or agent.careNeedLevel > 0:
                if agent.house.ownedByOccupants == False: # Assuming the agent will get the Housing Cost element
                    ucIncome = max(ucIncome-pars.workAllowanceHS, 0.0)
                else:
                    ucIncome = max(ucIncome-pars.workAllowanceNoHS, 0.0)
            ucReduction = ucIncome*pars.incomeReduction
            benefit = 0
            if agent.age < 25:
                benefit = max(pars.sigleBelow25-ucReduction, 0.0)
                if benefit > 0:
                    agent.ucBenefits = True
            else:
                benefit = max(pars.single25Plus-ucReduction, 0.0)
                if benefit > 0:
                    agent.ucBenefits = True
            agent.benefits += benefit
            self.aggregateUC += benefit
            
            # Extra for children
            dependentMembers = [x for x in agent.house.occupants if x.age < 16 or (x.age < 20 and x.status == 'student')]
            numChildBenefits = min(len(dependentMembers), 2)
            benefit = pars.eaChildren*numChildBenefits
            agent.benefits += benefit
            self.aggregateUC += benefit
            if benefit > 0:
                agent.ucBenefits = True
            
            # Extra for disabled children
            mildlyDisabledDependent = [x for x in dependentMembers if x.careNeedLevel > 0 and x.highestDisabilityBenefits == False]
            totalDisabledChildBenefits = pars.eaDisabledChildren[0]*float(len(mildlyDisabledDependent))
            agent.benefits += totalDisabledChildBenefits
            self.aggregateUC += totalDisabledChildBenefits
            if totalDisabledChildBenefits > 0:
                agent.ucBenefits = True
                
            criticallyDisabledDependent = [x for x in dependentMembers if x.highestDisabilityBenefits == True]
            totalDisabledChildBenefits = pars.eaDisabledChildren[1]*float(len(criticallyDisabledDependent))
            agent.benefits += totalDisabledChildBenefits
            self.aggregateUC += totalDisabledChildBenefits
            if totalDisabledChildBenefits > 0:
                agent.ucBenefits = True
            
            # Extra for disability
            if agent.careNeedLevel > 1:
                agent.benefits += pars.lcfwComponent # limited capability for work and work-related activity
                self.aggregateUC += pars.lcfwComponent
                agent.ucBenefits = True
                
            # Extra for social work
            if agent.socialWork > 35:
                agent.benefits += pars.carersComponent
                self.aggregateUC += pars.carersComponent
                agent.ucBenefits = True
    else:
        totalWealth = agent.financialWealth+agent.partner.financialWealth
        if totalWealth < pars.capitalHighThreshold:
            totalIncome = agent.income + agent.partner.income
            ucIncome = totalIncome + max(math.floor((totalWealth-pars.capitalLowThreshold)/pars.savingUCRate), 0.0)*pars.capitalIncome
            youngMembers = [x for x in agent.house.occupants if x.age < 16 or (x.age < 20 and x.status == 'student')]
            if (agent.independentStatus == True and len(youngMembers) > 0) or agent.careNeedLevel > 0:
                if agent.house.ownedByOccupants == False: # Assuming the agent will get the Housing Cost element
                    ucIncome = max(ucIncome-pars.workAllowanceHS, 0.0)
                else:
                    ucIncome = max(ucIncome-pars.workAllowanceNoHS, 0.0)
            ucReduction = ucIncome*pars.incomeReduction
            benefit = 0
            if agent.age < 25 and agent.partner.age < 25:
                benefit = max(pars.coupleBelow25-ucReduction, 0.0)/2.0
                if benefit > 0:
                    agent.ucBenefits = True
            else:
                benefit = max(pars.couple25Plus-ucReduction, 0.0)/2.0
                if benefit > 0:
                    agent.ucBenefits = True
            agent.benefits += benefit
            self.aggregateUC += benefit
            # Extra for children
            dependentMembers = [x for x in agent.house.occupants if x.age < 16 or (x.age < 20 and x.status == 'student')]
            numChildBenefits = min(len(dependentMembers), 2)
            benefit = pars.eaChildren*numChildBenefits
            agent.benefits += benefit/2.0
            self.aggregateUC += benefit/2.0
            if benefit > 0:
                agent.ucBenefits = True
            
            # Extra for disabled children
            mildlyDisabledDependent = [x for x in dependentMembers if x.careNeedLevel > 0 and x.highestDisabilityBenefits == False]
            totalDisabledChildBenefits = pars.eaDisabledChildren[0]*float(len(mildlyDisabledDependent))
            agent.benefits += totalDisabledChildBenefits/2.0
            self.aggregateUC += totalDisabledChildBenefits/2.0
            if totalDisabledChildBenefits > 0:
                agent.ucBenefits = True
                
            criticallyDisabledDependent = [x for x in dependentMembers if x.highestDisabilityBenefits == True]
            totalDisabledChildBenefits = pars.eaDisabledChildren[1]*float(len(criticallyDisabledDependent))
            agent.benefits += totalDisabledChildBenefits/2.0
            self.aggregateUC += totalDisabledChildBenefits/2.0
            
            if totalDisabledChildBenefits > 0:
                agent.ucBenefits = True
            
            # Extra for disability
            if agent.careNeedLevel > 1:
                agent.benefits += pars.lcfwComponent # limited capability for work and work-related activity
                self.aggregateUC += pars.lcfwComponent
                agent.ucBenefits = True
                
            # Extra for social work
            if agent.socialWork > 35:
                agent.benefits += pars.carersComponent
                self.aggregateUC += pars.carersComponent
                agent.ucBenefits = True
    
    
def pensionCredit(self):
    print 'Work in progress....'
    self.aggregatePensionCredit = 0
    # Condition 1: 65 or older (both, if a couple)
    pensioners = [x for x in self.pop.livingPeople if x.age >= pars.ageOfRetirement]
    for agent in pensioners:
        agent.guaranteeCredit = False
        agent.houseBenefit = False
        if agent.partner == None:
            benefitIncome = agent.income + max(math.floor((agent.financialWealth-pars.wealthAllowancePC)/pars.savingIncomeRatePC), 0.0)
            agent.benefits += max(pars.singlePC-benefitIncome, 0)
            self.aggregatePensionCredit += max(pars.singlePC-benefitIncome, 0)
            if max(pars.singlePC-benefitIncome, 0) > 0:
                agent.guaranteeCredit = True
        elif agent.partner.age >= pars.ageOfRetirement:
            totalIncome = agent.income+agent.partner.income
            totalWealth = agent.financialWealth+agent.partner.financialWealth
            aggregateBenefitIncome = totalIncome + max(math.floor((totalWealth-pars.wealthAllowancePC)/pars.savingIncomeRatePC), 0.0)
            agent.benefits += max(pars.couplePC-aggregateBenefitIncome, 0)/2.0
            self.aggregatePensionCredit += max(pars.couplePC-aggregateBenefitIncome, 0)/2.0
            if max(pars.couplePC-aggregateBenefitIncome, 0)/2.0 > 0:
                agent.guaranteeCredit = True
        ## Severe disability extra
        if agent.careNeedLevel > 2:
            agent.benefits += pars.disabilityComponentPC
            self.aggregatePensionCredit += pars.disabilityComponentPC
            agent.guaranteeCredit = True
        if agent.socialWork >= 35:
            agent.benefits += pars.caringComponentPC
            self.aggregatePensionCredit += pars.caringComponentPC
            agent.guaranteeCredit = True
        if agent.independentStatus == True:
            dependentMembers = [x for x in agent.house.occupants if x.age < 16 or (x.age < 20 and x.status == 'student')]
            if len(dependentMembers) > 0:
                totalChildBenefit = pars.childComponentPC*float(len(dependentMembers))
                if agent.partner == None:
                    agent.benefits += totalChildBenefit
                    self.aggregatePensionCredit += totalChildBenefit
                    agent.guaranteeCredit = True
                elif agent.partner.age >= pars.ageOfRetirement:
                    agent.benefits += totalChildBenefit/2.0
                    self.aggregatePensionCredit += totalChildBenefit/2.0
                    agent.guaranteeCredit = True
                # Disabled children
                mildlyDisabledDependent = [x for x in dependentMembers if x.careNeedLevel > 0 and x.highestDisabilityBenefits == False]
                totalDisabledChildBenefits = pars.disabledChildComponent[0]*float(len(mildlyDisabledDependent))
                if agent.partner == None:
                    agent.benefits += totalDisabledChildBenefits
                    self.aggregatePensionCredit += totalDisabledChildBenefits
                    agent.guaranteeCredit = True
                elif agent.partner.age >= pars.ageOfRetirement:
                    agent.benefits += totalDisabledChildBenefits/2.0
                    self.aggregatePensionCredit += totalDisabledChildBenefits/2.0
                    agent.guaranteeCredit = True
                criticallyDisabledDependent = [x for x in dependentMembers if x.highestDisabilityBenefits == True]
                totalDisabledChildBenefits = pars.disabledChildComponent[1]*float(len(criticallyDisabledDependent))
                if agent.partner == None:
                    agent.benefits += totalDisabledChildBenefits
                    self.aggregatePensionCredit += totalDisabledChildBenefits
                    agent.guaranteeCredit = True
                elif agent.partner.age >= pars.ageOfRetirement:
                    agent.benefits += totalDisabledChildBenefits/2.0
                    self.aggregatePensionCredit += totalDisabledChildBenefits/2.0
                    agent.guaranteeCredit = True
    # Housing benefit (for renters): LHA rate based on household composition (number of rooms).
    # 1 room for each of the following:
    # The household's head and partner
    # Any other person over 16, as long as they aren't living with you as your tenant
    # Two children under 16 of the same gender
    # Two children under 10
    # Any other child under 16
    for agent in [x for x in pensioners if x.independentStatus == True and x.house.ownedByOccupants == False]:
        if agent.partner == None:
            if agent.financialWealth < pars.housingBenefitWealthThreshold or agent.guaranteeCredit == True:
                agent.benefits += agent.house.town.LHA[self.computeMaxRooms([agent]) - 1]
                self.aggregateHousingElement += agent.house.town.LHA[self.computeMaxRooms([agent]) - 1]
        elif agent.partner.age >= pars.ageOfRetirement:
            totalWealth = agent.financialWealth+agent.partner.financialWealth
            if totalWealth < pars.housingBenefitWealthThreshold or agent.guaranteeCredit == True:
                agent.benefits += agent.house.town.LHA[self.computeMaxRooms([agent, agent.partner]) - 1]/2.0
                self.aggregateHousingElement += agent.house.town.LHA[self.computeMaxRooms([agent, agent.partner]) - 1]/2.0
                
    print 'Total pension credit: ' + str(self.aggregatePensionCredit)
    print 'Total housing element: ' + str(self.aggregateHousingElement)
    
    
def computeMaxRooms(self, agents):
    allowedRooms = 1
    house = agents[0].house
    residualMembers = [x for x in house.occupants if x not in agents]
    over16 = [x for x in residualMembers if x.age >= 16]
    allowedRooms += len(over16)
    residualMembers = [x for x in residualMembers if x not in over16]
    maleTeenagers = [x for x in residualMembers if x.age >= 10 and x.age < 16 and x.sex == 'male']
    additionalRooms = int(float(len(maleTeenagers))/2.0)
    allowedRooms += additionalRooms
    allocatedMaleTeenagers = maleTeenagers[:additionalRooms*2]
    residualMembers = [x for x in residualMembers if x not in allocatedMaleTeenagers]
    femaleTeenagers = [x for x in residualMembers if x.age >= 10 and x.age < 16 and x.sex == 'female']
    additionalRooms = int(float(len(femaleTeenagers))/2.0)
    allowedRooms += additionalRooms
    allocatedFemaleTeenagers = femaleTeenagers[:additionalRooms*2]
    residualMembers = [x for x in residualMembers if x not in allocatedFemaleTeenagers]
    under10 = [x for x in residualMembers if x.age < 10]
    additionalRooms = int(float(len(under10))/2.0)
    allowedRooms += additionalRooms
    allocatedUnder10s = under10[:additionalRooms*2]
    residualMembers = [x for x in residualMembers if x not in allocatedUnder10s]
    allowedRooms += len(residualMembers)
    if allowedRooms > 4:
        allowedRooms = 4
    return allowedRooms

