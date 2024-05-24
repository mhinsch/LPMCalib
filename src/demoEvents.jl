using ChangeEvents
using Age
using Dependencies
using TasksCare
using Social


function ChangeEvents.trigger!(c::ChangeAge1Yr, args...)
    process!(c, DependenciesT(), args...)
    process!(c, SocialT(), args...)
    process!(c, TasksCareT(), args...)
end


function ChangeEvents.trigger!(c::ChangeStatus, args...)
    process!(c, TasksCareT(), args...)
end
