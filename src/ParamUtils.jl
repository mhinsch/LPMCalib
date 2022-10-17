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

export fieldsAsArgs!, fieldsAsCmdl,  overrideParsCmdl!

using ArgParse
using REPL
using YAML

# TODO
# * use explicit types
# * use flag for Bool

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

"parse arrays of parseable types"
function Base.parse(::Type{T}, s::AbstractString) where {T<:AbstractArray}
	s1 = replace(s, r"[\[\]]"=>"")
	s2 = replace(s1, ','=>' ')
	s3 = split(s2)
	parse.(eltype(T), s3)
end


function overrideParsCmdl!(pars, args)
    fields = fieldnames(typeof(pars))

    for f in fields
        if args[f] != nothing
            setfield!(pars, f, args[f])
        end
    end
end


end
