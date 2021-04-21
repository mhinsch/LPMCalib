module Observation

export prefixes, @observe, printable

using MacroTools


import Base.print


prefixes(::Type{T}) where {T} = fieldnames(result_type(T))
printable(x, FS) = join(x, FS)


function print_header(output, stats)
	fn = fieldnames(stats)
	ft = fieldtypes(stats)

	for i in eachindex(fn)
		n = fn[i]
		if n == :FS || n == :NS || n == :LS
			continue
		end

		t = ft[i]
		if t <: NamedTuple
			header(output, t.names[2:end], stats.FS, stats.NS)
		else
			header(output, string(n), stats.FS, stats.NS)
		end
	end
end


function header(out, stat_type, name, sep = "\t", name_sep = "_")
	pref = prefixes(stat_type)
	n = length(pref)

	if n == 0
		print(out, name * sep)
		return
	end

	for p in pref
		print(out, p * name_sep * name * sep)
	end
end


function process_single!(name, expr, header_body, log_body, last)
	if last 
		push!(header_body, :(header(output, Nothing, $(esc(name)), "")))
		push!(log_body, :(print(output, printable($(esc(expr)), FS)...)))
	else
		push!(header_body, :(header(output, Nothing, $(esc(name)), FS)))
		push!(log_body, :(print(output, printable($(esc(expr)), FS)..., FS)))
	end
end


function process_aggregate!(var, collection, stats, header_body, log_body, islast)
	decl_code = []
	loop_code = []
	output_code = []

	lines = filter(l->typeof(l)!=LineNumberNode, stats.args)

	for i in eachindex(lines)
		line = lines[i]
		last = islast && i == length(lines)

		@capture(line, @stat(statname_String, stattypes__) <| expr_) ||
			error("expected:@stat(<NAME>, <STAT> {, <STAT>}) <| <EXPR>")

		tmp_name = gensym("tmp")
		push!(loop_code, :($tmp_name = $(esc(expr))))

		for j in eachindex(stattypes)
			last2 = last && j == length(stattypes)
			stattype = stattypes[j] 

			if last2
				push!(header_body, :(header(output, $(esc(stattype)), $(esc(statname)), "")))
			else
				push!(header_body, :(header(output, $(esc(stattype)), $(esc(statname)), FS)))
			end

			vname = gensym("stat")
			push!(decl_code, :($(esc(vname)) = $(esc(stattype))()))

			push!(loop_code, :($(esc(:add!))($(esc(vname)), $tmp_name)))

			if last2
				push!(output_code, :(print(output, printable($(esc(vname)), FS)...)))
			else
				push!(output_code, :(print(output, printable($(esc(vname)), FS)..., FS)))
			end
		end
	end

	append!(log_body, decl_code)
	push!(log_body, :(for $(esc(var)) in $(esc(collection)); $(loop_code...); end))
	append!(log_body, output_code)
end

# struct ObsName
#	FS :: String
#	NS :: String
#	LS :: String
#	cap :: @NamedTuple{accumulator:Tuple{MM, MV}, min::Float64, max::Float64, mean::Float64, var::Float64}
#	n_migrants :: Int
# end
#
# obs.cap.mean
# obs.cap.accumulator[1]


macro observe(fname, model, decl)
	if typeof(fname) != Symbol
		error("@observe expects a function name as 1st argument")
	end

	if typeof(model) != Symbol
		error("@observe expects a model name as 2nd argument")
	end

	if typeof(decl) != Expr || decl.head != :block
		error("@observe expects a declaration block as 3rd argument")
	end


	header_func_name = Symbol("print_header_" * String(fname))
	# use : in order to avoid additional block
	header_func = :(function $(esc(header_func_name))(output; FS="\t", LS="\n")
		end)
	header_body = header_func.args[2].args

	log_func_name = Symbol("print_stats_" * String(fname))
	log_func = :(function $(esc(log_func_name))(output, $(esc(model)); FS="\t", LS="\n", $(esc(:args))...)
		end)
	log_body = log_func.args[2].args


	syntax = "single or population stats declaration expected:\n" *
		"\t@for <NAME> in <EXPR> <BLOCK>" *
		"\t@show <NAME> <EXPR>"
	
	lines = filter(l->typeof(l)!=LineNumberNode, decl.args)
	for i in eachindex(lines)
		line = lines[i]
		last = i == length(lines)

		if typeof(line) != Expr || line.head != :macrocall
			error(syntax)
		end

		if line.args[1] == Symbol("@show")
			@capture(line, @show(name_String, expr_)) ||
				error("expecting: @show <NAME> <EXPR>")
			process_single!(name, expr, header_body, log_body, last)
		elseif line.args[1] == Symbol("@for")
			@capture(line, @for var_Symbol in expr_ begin block_ end) ||
				error("expecting: @for <NAME> in <EXPR> <BLOCK>")
			process_aggregate!(var, expr, block, header_body, log_body, last)
		else
			error(syntax)
		end
	end

	push!(header_body, :(print(output, LS)))
	push!(log_body, :(print(output, LS)))
	push!(log_body, :(flush(output)))

	ret = Expr(:block)
	push!(ret.args, header_func)
	push!(ret.args, log_func)

	ret
end

end	# module
