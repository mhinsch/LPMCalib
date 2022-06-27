"""
    An super type for example 

    The purpose is to provide type traits for overloading 
    functions that need to be overloaded, e.g. setup!(::AbstractSimulation,::ExampleType) 

    Main usage 

    struct ExampleName <: AbstractExample end

    import Simulations: setup!

    function setup!(sim::SimulationType;example::ExampleName) 
        # implementation, e.g. setup stepping functions 
    end 
"""

export AbstractExample, DummyExample

"A super type for all simulation examples"
abstract type AbstractExample end 

"Default dummy example type"
struct DummyExample <: AbstractExample end 