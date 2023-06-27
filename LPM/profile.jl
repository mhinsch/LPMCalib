using ProfileView

include("mainHelpers.jl")
include("analysis.jl")

const simPars, pars = loadParameters(ARGS)

const model = setupModel(pars)
 
t = Rational(pars.poppars.startTime)

function run_until(t_end)
    while true
        global model, t, pars, simPars
        stepModel!(model, t, pars)
        t += simPars.dt
        if t >= t_end
            break
        end
    end
end   


function run_steps(n)
    for i in 1:n
        global model, t, pars, simPars
        stepModel!(model, t, pars)
    end
end
