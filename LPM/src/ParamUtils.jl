#   Copyright (C) 2020 Martin Hinsch <hinsch.martin@gmail.com>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.



module ParamUtils

export fieldsAsArgs!, fieldsAsCmdl,  overrideParsCmdl!, parFromYaml, parToYaml

using ArgParse
using REPL


"add all fields of a type to the command line syntax"
function fieldsAsArgs!(arg_settings, t :: Type)
	fieldns = fieldnames(t)
	fieldts = fieldtypes(t)
        for (fn, ft) in zip(fieldns, fieldts)
		fdoc =  REPL.stripmd(REPL.fielddoc(t, fn))
		add_arg_table!(arg_settings, ["--" * String(fn)], Dict(:help => fdoc, :arg_type => ft))
	end
end


"generate command line arguments from an object"
function fieldsAsCmdl(o, ignore = [])
	fields = fieldnames(typeof(o))
	res = ""
	for f in fields
		if string(f) in ignore
			continue
		end
		farg = replace(string(f), "_" => "-")
		value = replace(string(getfield(o, f)), " " => "")
		res *= " --" * farg * " " * value
	end

	res
end

"set fields in pars to values in args, if provided"
function overrideParsCmdl!(pars, args)
    fields = fieldnames(typeof(pars))

    for f in fields
        if args[f] != nothing
            setfield!(pars, f, args[f])
        end
    end
end


"convert value to type T"
asType(::Type{T}, value) where{T} = value
asType(::Type{T}, value::AbstractString) where {T} = parse(T, value)
# matrizes come back as [ "1 2 ; 3 4" ]
asType(::Type{Array{T, 2}}, value::Vector{String}) where {T<:Number} = 
    parse(Array{T, 2}, value)
asType(::Type{String}, value::AbstractString) = value

# For some reason Julia can *write* Rational, but not read it...
"parse Rational from an AbstractString"
function Base.parse(::Type{Rational{T}}, s::AbstractString) where {T}
    nums = split(s, "//")
    Rational{T}(parse(T, nums[1]), parse(T, nums[2]))
end

function Base.parse(::Type{Array{T, 2}}, value::Vector{String}) where {T<:Number}
    # matrizes come back as [ "1 2 ; 3 4" ]
    str = value[1]
    lines = split(str, ";")

    data = T[]

    for line in lines
        for el in split(line)
            push!(data, parse(T, el))
        end
    end

    # transform into matrix
    # there's probably an easier way, but this works and it's used only once
    # per simulation run anyway
    reshape(data, :, length(lines)) |> permutedims
end

# This is effectively a setfield replacement that allows for type coercion.
# We need this, as the representation of some built-in types (e.g. Rational)
# is understood as generic String by YAML, so we can't simply assign these fields when
# reading a YAML file. setValue pipes the assignment through asValue which converts
# a value of type A to type B (the field type in this case), but defaults to identity.
# We simply overload asValue for A==AbstractString and any B that is not recognised
# by YAML.
"set value of a struct's field while allowing for type coercion overloads"
setValue!(str, fname, value) = setfield!(str, fname, 
                                         asType(fieldtype(typeof(str), fname), value))

"Read an object of type `ptype` stored as `name` in dict `yaml`."
function parFromYaml(yaml, ptype, name)
    # generate default object
    par = ptype()

    # type not in file, so use default values
    if !haskey(yaml, name)
        return par
    end

    pyaml = yaml[name]

    for f in fieldnames(ptype)
        if !haskey(pyaml, f)
            # all fields have to be set (or none)
            error("Field $f required in parameter $(name)!")
        end

        # use setValue, so that e.g. Rational can be converted from String
        setValue!(par, f, pyaml[f])
    end

    par
end


"generate dict from dict from `par`"
function parToYaml(par)
    dict = Dict{Symbol, Any}()
    for n in fieldnames(typeof(par))
        dict[n] = getfield(par, n)
    end

    dict
end

# TODO not sure if this is still needed
"parse arrays of parseable types"
function Base.parse(::Type{T}, s::AbstractString) where {T<:AbstractArray}
	s1 = replace(s, r"[\[\]]"=>"")
	s2 = replace(s1, ','=>' ')
	s3 = split(s2)
	parse.(eltype(T), s3)
end


end
