
# export Household 

# ABM(Person,HouseNetworks,properties)
# const Household = ABM()

#= 

Older specification to be removed 

import SocialAgents: Person

export Household

"Household: group of persons associated with a particular house."
const Household = Group{Person}

# A specific constructor that verify all persons in a household are related or associated
# with a particular house

=# 