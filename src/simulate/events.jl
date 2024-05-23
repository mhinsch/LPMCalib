using Age
using Dependencies
using TasksCareT
using Social


function trigger!(c::ChangeAge1Yr, args...)
    process!(c, DependenciesT(), args...)
    process!(c, SocialT(), args...)
    process!(c, TasksCareT(), args...)
end


function trigger!(c::ChangeStatus, args...)
    process!(c, TasksCareT(), args...)
end
