# LoneParentsModel.jl
A modular agent-based model of the UK with a focus on public health research. Aspects that are modelled at least to some degree include

- demographic effects including real birth and death rates
- labour market
- wealth and income distributions
- benefits
- social and child care


## Running the model

Use

```
julia main.jl
```

or


```
julia mainGui.jl
```

to run the console or GUI version of the model respectively.

Standard Unix-style command line arguments are supported to set parameters and affect program behaviour. Run `julia main.jl --help` to see a list of supported options.


## Internals

### Code organisation

The top level directory should ideally only contain code that is specific to running the model, displaying the gui or extracting data.

#### `src`

All *semantic* code, that is, code that affects model behaviour should be here.

Data types that represent entities in the model as well as "shallow" (in the sense that functionality and implementation are obvious) functions to manipulate them are defined in `agents`.

Model processes are defined in `setup` (things that happen once before the model starts), `simulate` (things that happen while the model runs) and `common` (functionality that is used by both, setup and simulation).

Definitions of specific models can have their own subdirectory in `src`.

#### `lib`

Supporting infrastructure.


### Modularity

I have attempted to make the model code as modular as possible by splitting agent types as well as model processes into combinable and extendable units. In any programming language there is a point where increasing modularity starts incurring runtime costs and modularity of simulation code in Julia is still a pretty new field as far as I know. This is therefore a best attempt and compromises were unavoidable.

#### Agents

`agents/agents_modules` contains definitions of simple agent building blocks implemented as Julia modules. The definitions are as barebones as possible and only include the absolute minimum of functions required to modify them.

A concrete agent type to be used in a specific model is then defined in its own Julia module in `agents`, for example `agents/DemoPerson`. Agent modules are pulled in via `using` and the concrete agent type is constructed using the `@composite` macro (from `CompositeStructs.jl`).

The module also defines its own utility functions. As a rule of thumb, functions should be defined in the agent type module if a) they do something simple, b) their *semantic* effect is obvious or easily understood and c) they contain a large proportion of infrastructure or bookkeeping. The idea is to strike a balance between keeping the main model code free from trivial utility functions and having no "interesting" behaviour in the agent definition.

Note that agent modules and concrete agent definitions both only export functionality that is defined in the respective modules (as they should). It might therefore be necessary for model or analysis code to load agent modules.

#### Processes

True modularity is substantially more difficult to achieve for processes than for agents as any non-trivial model will have interactions between otherwise distinct processes. I think the goal of being able to add a new process to the model without having to touch any of the existing code is not achievable (at least not without significant run-time costs), but I have tried to reduce dependencies to a minimum.

All processes that happen during the model run time are part of a transition. Transitions modify the state of the simulated world and can (mostly) be executed in any order. One time step in a concrete model corresponds to running a defined set of transitions in a defined order. Many transitions (for example birth or age) are even more formalised and consist of an update function and a filter function where the update function is applied to a filtered subset of the population.

Interactions between processes are implemented via an event/subscription system. As a motivational example it is easy to imagine that an increase in an agent's age has effects in all kinds of contexts, e.g. for family status, education/work etc. The simplest and most straightforward way to implement these effects would be to simply add them directly to the age transition. The problem with this is that now every time a new process is added to (or, indeed, removed from) the model that depends on age, the code for the age transition itself needs to be changed which is not only annoying, but also makes it very difficult to keep the age transition as an independent module. With the event system I implemented, every process that makes changes that might have effects somewhere else defines an event type instead (a simple empty struct is sufficient) and then calls the `trigger!` function to make other processes aware of the change (see `src/simulate/Age.jl`). A process that is interested in an event implements a simple tag type and a method of the `process!` function (see `src/simulate/Dependencies.jl`). A concrete model then only needs to define the subscriptions that tie events and processing functions together (`src/demoEvents.jl`). For now this has to be done manually but the system is so formalised that it would be easy to implement a macro that would make subscription a simple declarative list.


#### Parameters

The way model parameters are implemented remains largely unchanged from the very first versions of the model and is in dire need of an overhaul.

All model parameters are top-level members of a struct and have defined default values (using `@with_kw`). These structs are defined in a model-specific directory (`src/demography`) and correspond to rough categories (map, population, divorce, etc...). This was an early attempt at modularisation but unfortunately these categories do not have any kind of reliable relationship with the model modules defined in `src/simulate`. Ideally there would be a way for each model module to define the parameters it requires and to then stitch those together into the model parameter object. It's not entirely clear, however, how best to deal with e.g. overlaps or tree-like dependencies (modules A and B both require parameters defined by C).


### Caching

Quite a few processes in the model depend on population properties that can be quite expensive to calculate. Since transitions are for modularity reasons defined as operations on individuals where possible and since multiple processes might require access to the same population properties it makes sense to pre-calcaulate them and store them globally. There is no infrastructure for caching but the implementations follow a set of conventions. Transitions that implement caching provide a type `<Name>Cache` that contains the necessary data structures and a function `<name>PreCalc!(model, pars)` that prepares the cache from the current state of the model. All cache objects of a model are direct parts of the `Model` type and named `<name>Cache`. In the main model loop all caching functions are called before any transitions are called.
