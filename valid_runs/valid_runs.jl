using CSV
using DataFrames


function gen_cmdl(post, row)
	# skip dist
	parnames = names(post)[2:end]

	values = row[2:end]

	@assert length(values) == length(parnames)

	replace.(parnames, "_" => "-")

	[ ["--$p", "$v"] for (p, v) in zip(parnames, values) ] |> Iterators.flatten
end


function run_random(post, prefix, seed)
	n_rows = nrow(post)

	par_row = post[rand(1:n_rows), :]

	cmdl = gen_cmdl(post, par_row)

	mkpath(prefix)
	cd(prefix) do
        run(`julia ../../../LPM/main.jl $cmdl --datadir ../../../LPM/data --analysisFile ../valid_runs/analysis.jl --seed $seed --startLogTime 2001//1 --endLogTime 2021//1`)
	end
end


const posterior = CSV.read("calib_latest.tsv", DataFrame)

if ! isinteractive()
    seed = ARGS[1]
    run_random(posterior, "run_$seed", seed)
end
