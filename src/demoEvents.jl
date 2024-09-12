#= Handle event subscriptions =#



using ChangeEvents
using SocialCM
using Age, Death, Dependencies, TasksCare 


function ChangeEvents.trigger!(c::ChangeAge1Yr, args...)
    process!(c, DependenciesT(), args...)
    process!(c, SocialT(), args...)
    process!(c, TasksCareT(), args...)
end


function ChangeEvents.trigger!(c::ChangeStatus, args...)
    process!(c, TasksCareT(), args...)
end


function ChangeEvents.trigger!(c::ChangeDeath, args...)
    process!(c, TasksCareT(), args...)
    process!(c, DependenciesT(), args...)
end
