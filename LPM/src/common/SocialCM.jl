module SocialCM
    

using ChangeEvents

    
export changeStatus!
export ChangeStatus


struct ChangeStatus end


function changeStatus!(person, newStatus, pars)
    oldStatus = person.status
    person.status = newStatus
    trigger!(ChangeStatus(), person, oldStatus, pars)
end


end
