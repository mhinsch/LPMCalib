# this is a super simplistic relative import macro
# npot needed right now, but kept for potential future use
#"temporarily prepend `path` to `LOAD_PATH`, while executing `args`" 
#macro in(path, args...)
#    quote
#    pushfirst!($(esc(:LOAD_PATH)), joinpath(@__DIR__, $path))
#    $(args...)
#    popfirst!($(esc(:LOAD_PATH)))
#    end
#end


function addToLoadPath!(paths...)
    for path in paths
        if ! (path in LOAD_PATH)
            push!(LOAD_PATH, path)
        end
    end
end

