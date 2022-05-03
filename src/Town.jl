#=
Intuition: A town is composed of a variable population and a variable set of houses. Thus, it can be viewed as an ABM. 

Initially not sure if this concept shall remain. 
=# 

# export Town 

# ABM(House,Map,Properties)
# const Town = ABM()


function createTown()
    town = ABM(House) # House, map or grid, ... 

    town 
end 
#= 

Older implementation to be removed 

#
# Type Town extends the type Group 
# a collection of houses 
# 

export Town 

const Town = Group{House}

=# 