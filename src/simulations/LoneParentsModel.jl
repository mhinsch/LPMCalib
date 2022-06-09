"""
    just a list of [stepping] functions to operate a Multi ABM 
    design of function arguments and return values to be specified later
""" 

module LoneParentsModel

    export createPopulation, loadData!, setSimulationParameters

    using SocialAgents: Person
    using SocialABMs: SocialABM, setproperty! 
    using SocialSimulations: SocialSimulation, setproperty!
    using Utilities: read2DArray


    """
        set simulation paramters @return dictionary of symbols to values
    
        All information needed by the generic SocialSimulations.run! function
        is provided here
        
        @return dictionary of required simulation parameters 
    """
    function setSimulationParameters() 
        Dict(:numRepeats=>1,
             :startYear=>1860,
             :endYear=>2040,
             :seed=> floor(Int,time()))

        #= multiprocessing params
        meta["multiprocessing"] = false
        meta["numberProcessors"] = 10
        meta["debuggingMode"] = true
        =# 

        #= Graphical interface details
        meta["interactiveGraphics"] = false
        meta["delayTime"] = 0.0
        meta["screenWidth"] = 1300
        meta["screenHeight"] = 700
        meta["bgColour"] = "black"
        meta["mainFont"] = "Helvetica 18"
        meta["fontColour"] = "white"
        meta["dateX"] = 70
        meta["dateY"] = 20
        meta["popX"] = 70
        meta["popY"] = 50
        meta["pixelsInPopPyramid"] = 2000
        meta["careLevelColour"] = ["blue","green","yellow","orange","red"]
        # ?? number of colors = number of house classes x 2
        meta["houseSizeColour"] = ["blue","green","yellow","orange","red", "lightgrey"]
        meta["pixelsPerTown"] = 56
        meta["maxTextUpdateList"] = 22
        =# 
    end 


    "Create an empty population initially with no agents"
    function createPopulation() 
        population = SocialABM{Person}()

        # ?? Brief descriptions of the numbers within the text file needed (not directly understandable in their pure format)

        # Data related to population growth 
        # vvv attachData(...)
        setproperty!(population,:fert_data,read2DArray("../data/babyrate.txt.csv"))
        setproperty!(population,:death_female,read2DArray("../data/deathrate.fem.csv"))
        setproperty!(population,:death_male,read2DArray("../data/deathrate.male.csv"))

        # Data related to population income 
        # addProperty!(population,:unemployment_series,readArrayFromCSVFile("unemploymentrate.csv"))
        # addProperty!(population,:income_distribution,readArrayFromCSVFile("incomeDistribution.csv"))
        # addProperty!(population,:income_percentiles,readArrayFromCSVFile("incomePercentiles.csv"))
        # addProperty!(population,:wealth_distribution,readArrayFromCSVFile("wealthDistribution.csv"))

        # shifts = createShifts() 

        population
    end


    include("lpm/InitializeLPM.jl")

    function loadData!(simulation::SocialSimulation)
        loadMetaParameters!(simulation)
        loadModelParameters!(simulation)
        initSimulationVariables(simulation)
    end 



    function doDeaths() end 
    function doAdoptions() end 
    function oneTransition_UCN() end
    function computeIncome() end 
    function updateWealthInd() end
    function jobMarket() end
    function computeAggregateSchedule() end 
    function startCareAllocation() end 
    function allocateWeeklyCare() end 
    function updateUnmetCare() end 
    function updateUnmetCareNeed() end 
    function doAgeTransition() end 
    function doSocialTransitions() end 
    function houseOwnership() end 
    function computeBenefits() end 
    function doBirths() end 
    function doDevorces() end 
    function doMarriages() end 
    function doMovingAround() end
    function selfPyramidUpdate() end
    function healthcareCost() end
    function doStats() end  

end # Module LoneParentsModel

#= 
def doOneMonth(self, policyFolder, dataMapFolder, dataHouseholdFolder, year, month, period):
        """Run one year of simulated time."""

        ##print "Sim Year: ", self.year, "OH count:", len(self.map.occupiedHouses), "H count:", len(self.map.allHouses)
        print 'Year: ' + str(year) + ' - Month: ' + str(month)
        # self.checkHouseholds(0)
        
        startYear = time.time()
        
        print 'Tot population: ' + str(len(self.pop.livingPeople))
        # print 'Doing fucntion 1...'
        
        self.computeClassShares()
        
        # print 'Doing doDeaths...'
      
        ###################   Do Deaths   #############################
        
        # self.checkIndependentAgents(0)
      
        self.doDeaths(policyFolder, month)
        
        # self.checkIndependentAgents(1)
        
        self.doAdoptions(policyFolder)
        
        # self.checkIndependentAgents(1)
        
        
        ###################   Do Care Transitions   ##########################
        
        # self.doCareTransitions()
        
        # print 'Doing fucntion 4...'
        
        
        self.doCareTransitions_UCN(policyFolder, month)
        
        # self.checkIndependentAgents(1.1)
        

        self.computeIncome(month)
        
        if month == 12:
            self.computeIncomeQuintileShares()
        
        self.updateWealth_Ind()
        
        
        # self.checkIncome(2)
        
        print 'Doing jobMarket...'
        
        self.jobMarket(year, month)
        # Here, people change job, find a job if unemployed and lose a job if employed.
        # The historical UK unemployment rate is the input.
        # Unmeployement rates are adjusted for age and SES.
        # Upon losing the job, a new unemplyed agent is assigned an 'unemployment duration' draw from the empirical distribution.
        # Unemployment duration is also age and SES specific.
        
        self.computeAggregateSchedule()
        
        # print 'Doing fucntion 9...'
        # self.checkIncome(3)
        
        
        # self.computeTax()
        

        # print 'Doing startCareAllocation...'
 
        self.startCareAllocation()
        
        if year >= self.p['careAllocationFromYear']:
            
            self.allocateWeeklyCare()
            
            # self.checkHouseholdsProvidingFormalCare()
        
        # print 'Doing fucntion 7...'
        # self.checkIncome(5)
        
        
        ##### Temporarily bypassing social care alloction
        
        ## self.allocateSocialCare_Ind()
    
        # print 'Doing fucntion 8...'
    
        self.updateUnmetCareNeed()
        
        self.doAgeTransitions(policyFolder, month)
        
        # self.checkIndependentAgents(1.2)
        
        
        self.doSocialTransition(policyFolder, month)
        
        
        # self.checkIndependentAgents(1.3)
        
        
        # Each year
        self.houseOwnership(year)
        
        
        # Compute benefits.
        # They increase the household income in the following period.
        if self.p['withBenefits'] == True:
            self.computeBenefits()
        
        # self.publicCareEntitlements()
        
        # print 'Doing fucntion 10...'
        
        # self.checkHouseholds(0)
        
        self.doBirths(policyFolder, month)
        
        # self.checkIndependentAgents(1.3)
        # print 'Doing fucntion 11...'
  
        
        
        
        
        # print 'Doing fucntion 12...'
        
        # self.updateWealth()
        
        
      
        # print 'Doing fucntion 13...'
        
        # self.doSocialTransition_TD()
        
        # self.checkIndependentAgents(2)
        
        # print 'Doing fucntion 14...'
        
        self.doDivorces(policyFolder, month)
        
        # self.checkIndependentAgents(3)
        
        self.doMarriages(policyFolder, month)
        
        
        # self.checkIndependentAgents(4)
        
        # print 'Doing fucntion 16...'
        print 'Doing doMovingAround...'
        
        self.doMovingAround(policyFolder)
        
        
        # self.checkIndependentAgents(5)
        
        # print 'Doing householdRelocation...'
        
        # self.householdRelocation(policyFolder)
        
        
        # print 'Doing fucntion 17...'
        
        self.pyramid.update(self.year, self.p['num5YearAgeClasses'], self.p['numCareLevels'],
                            self.p['pixelsInPopPyramid'], self.pop.livingPeople)
        
        
        # print 'Doing fucntion 18...'
        
        self.healthCareCost()
        
        self.doStats(policyFolder, dataMapFolder, dataHouseholdFolder, period)
        
        if (self.p['interactiveGraphics']):
            self.updateCanvas()
            
        endYear = time.time()
        
        print 'Year execution time: ' + str(endYear - startYear)     # ?? Looks rather like month execution time?

            
        # print 'Did doStats'
=# 

#=
def doDeaths(self, policyFolder, month):
        
preDeath = len(self.pop.livingPeople)

deaths = [0, 0, 0, 0, 0]
"""Consider the possibility of death for each person in the sim."""
for person in self.pop.livingPeople:
    age = person.age
    
    ####     Death process with histroical data  after 1950   ##################
    if self.year >= 1950:
        if age > 109:
            age = 109
        if person.sex == 'male':
            rawRate = self.death_male[age, self.year-1950]
        if person.sex == 'female':
            rawRate = self.death_female[age, self.year-1950]
            
        classPop = [x for x in self.pop.livingPeople if x.careNeedLevel == person.careNeedLevel]
        
        dieProb = self.deathProb(rawRate, person)
        
        person.lifeExpectancy = max(90-person.age, 3)
        # dieProb = self.deathProb_UCN(rawRate, person, person.averageShareUnmetNeed, classPop)

    #############################################################################
    
        if np.random.random() < dieProb and np.random.choice([x+1 for x in range(12)]) == month:
            person.dead = True
            person.deadYear = self.year
            person.house.occupants.remove(person)
            if len(person.house.occupants) == 0:
                self.map.occupiedHouses.remove(person.house)
                if (self.p['interactiveGraphics']):
                    self.canvas.itemconfig(person.house.icon, state='hidden')
            if person.partner != None:
                person.partner.partner = None
            if person.house == self.displayHouse:
                messageString = str(self.year) + ": #" + str(person.id) + " died aged " + str(age) + "." 
                self.textUpdateList.append(messageString)
                
                with open(os.path.join(policyFolder, "Log.csv"), "a") as file:
                    writer = csv.writer(file, delimiter = ",", lineterminator='\r')
                    writer.writerow([self.year, messageString])
        
    else: 
        #######   Death process with made-up rates  ######################
        babyDieProb = 0.0
        if age < 1:
            babyDieProb = self.p['babyDieProb']
        if person.sex == 'male':
            ageDieProb = (math.exp(age/self.p['maleAgeScaling']))*self.p['maleAgeDieProb'] 
        else:
            ageDieProb = (math.exp(age/self.p['femaleAgeScaling']))* self.p['femaleAgeDieProb']
        rawRate = self.p['baseDieProb'] + babyDieProb + ageDieProb
        
        classPop = [x for x in self.pop.livingPeople if x.careNeedLevel == person.careNeedLevel]
        
        dieProb = self.deathProb(rawRate, person)
        
        person.lifeExpectancy = max(90-person.age, 5)
        #### Temporarily by-passing the effect of unmet care need   ######
        # dieProb = self.deathProb_UCN(rawRate, person.parentsClassRank, person.careNeedLevel, person.averageShareUnmetNeed, classPop)
        
        if np.random.random() < dieProb and np.random.choice([x+1 for x in range(12)]) == month:
            person.dead = True
            person.deadYear = self.year
            deaths[person.classRank] += 1
            person.house.occupants.remove(person)
            if len(person.house.occupants) == 0:
                self.map.occupiedHouses.remove(person.house)
                if (self.p['interactiveGraphics']):
                    self.canvas.itemconfig(person.house.icon, state='hidden')
            if person.partner != None:
                person.partner.partner = None
            if person.house == self.displayHouse:
                messageString = str(self.year) + ": #" + str(person.id) + " died aged " + str(age) + "." 
                self.textUpdateList.append(messageString)
                
                with open(os.path.join(policyFolder, "Log.csv"), "a") as file:
                    writer = csv.writer(file, delimiter = ",", lineterminator='\r')
                    writer.writerow([self.year, messageString])
                
          
self.pop.livingPeople[:] = [x for x in self.pop.livingPeople if x.dead == False]

postDeath = len(self.pop.livingPeople)

print('the number of deaths is: ' + str(preDeath - postDeath))      
=# 