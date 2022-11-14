using Distributions
using Statistics

# one point in parameter space
mutable struct Particle
    params :: Vector{Float64}
    # distance to data
    dist :: Float64
end


function limit(params, priors)
    [max(minimum(d), min(maximum(d), p)) for (p, d) in zip(params, priors)]
end


# default remover, removes set proportion of particles
struct PropRemover
	p_rem :: Float64
end

function premove!(premover::PropRemover, particles; verbose=false)
	rem = floor(Int, premover.p_rem * length(particles))

	verbose && println("removing $rem of $(length(particles))")
	# remove worst particles
	sort!(particles, by=p->p.dist)
	resize!(particles, length(particles)-rem)
end


struct OwnCreator{PVEC}
	scale_noise :: Bool
	alpha :: Float64
	priors :: PVEC
	sigma :: Vector{Float64}
end
	
function pcreate(pcreator::OwnCreator, particles, pop_size; verbose=false)
	if pcreator.scale_noise
		std_dev = [std([p.params[i] for p in particles]) for i in eachindex(particles[1].params)]
		verbose && println("stdd: ", join(std_dev, ", "))
		n_sigma = pcreator.sigma .* std_dev
	else
		n_sigma = pcreator.sigma
	end
	
	noise = Normal.(0, n_sigma)
	
	s = particles[end].dist + particles[1].dist
	weights = cumsum([(s - p.dist)^pcreator.alpha for p in particles])
	sel = Uniform(0, weights[end])

	new_particles = Particle[]
	
	for i in 1:pop_size
		anc = particles[searchsortedfirst(weights, rand(sel))]
		params = anc.params .+ rand.(noise)
		params = limit(params, pcreator.priors)
		push!(new_particles, Particle(params, Inf))
	end

	new_particles
end

# setup particles
function abc_init(pcreator, pop_size)	
    [Particle(map(rand, pcreator.priors), Inf) for i in 1:pop_size]
end

# run one set of particles
function abc_simulate!(particles, dist_func; parallel = false)
	if parallel
		Threads.@threads for p in particles
			p.dist = dist_func(p.params)
		end        
	else
		for p in particles
			p.dist = dist_func(p.params)
		end        
	end

	particles
end

# add new particles, simulate, add to population
function abc_iter!(particles, dist_func, pop_size, premover, pcreator; 
	verbose = false, parallel = false)

	if ! isempty(particles)
		premove!(premover, particles; verbose)
		
		verbose && println("distance: ", particles[1].dist, " ", particles[end].dist)
		
		new_particles = pcreate(pcreator, particles, pop_size; verbose)
	else
		new_particles = abc_init(pcreator, pop_size)
	end

	verbose && println("simulating $(length(new_particles)) new particles...")
	
	abc_simulate!(new_particles, dist_func; parallel)

	# add new particles to old ones
	append!(particles, new_particles)
end

# run a full abc
function abc(dist_func, pop_size, n_iters, premover, pcreator; 
        verbose = false, parallel = false)

    particles = Particle[]
    
	for i in 1:n_iters
		abc_iter!(particles, dist_func, pop_size, premover, pcreator; verbose, parallel)
    end

	particles
end
