import Base.occursin 

"if a substr occurs as a substring in any element of string vector"
function occursin(substr::String,strvec::Vector{String})
    for str in strvec 
        !occursin(substr,str) ? nothing : return true  
    end   
    false
end

# Temporary solution 
!occursin("MultiAgents.jl",LOAD_PATH) ? push!(LOAD_PATH, "../MultiAgents.jl") : nothing 
!occursin("SomeUtil.jl",LOAD_PATH) ? push!(LOAD_PATH, "../SomeUtil.jl") : nothing 
!occursin("LoneParentsModel.jl",LOAD_PATH) ? push!(LOAD_PATH, "../LoneParentsModel.jl/src") : nothing 
