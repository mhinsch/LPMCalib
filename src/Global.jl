"""
    Set of all global variables and types shared among modules 

"""

module Global

    # Types 
    export Gender 
    export AbstractExample, DummyExample

    # Constants 
    export USEAGENTSJL, SimulationFolderPrefix

    # list of types 

    "Gender type enumeration"
    @enum Gender unknown female male 

    """
        A super type for example 

        The purpose is to provide type traits for overloading 
        functions that need to be overloaded, e.g. setup!(::AbstractSimulation,::ExampleType) 

        Main usage 

        struct ExampleName <: AbstractExample end

        import Simulations: setup!

        function setup!(sim::SimulationType;example::ExampleName) 
            # implementation, e.g. setup stepping functions 
        end 
    """

    "A super type for all simulation examples"
    abstract type AbstractExample end 

    "Default dummy example type"
    struct DummyExample <: AbstractExample end 

    # list of global variables

    "whether the package Agents.jl shall be used" 
    const USEAGENTSJL = false      # Still not employed / implemented 

    "Folder in which simulation results are stored"
    const SimulationFolderPrefix = "Simulations_Folder"
    
    # timeStamp ... 

end