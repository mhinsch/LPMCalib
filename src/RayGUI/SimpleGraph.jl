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



module SimpleGraph

using Raylib
const RL = Raylib

export Graph, add_value!, draw_graph

### super simplistic graph implementation

mutable struct Graph{T}
	data :: Vector{T}
	max :: T
	min :: T
	colour :: RL.RayColor
end

Graph{T}(col) where {T} = Graph{T}([], typemin(T), typemax(T), col)

function add_value!(graph::Graph, value)
	push!(graph.data, value)
	value > graph.max ? (graph.max = value) : (value < graph.min ? (graph.min = value) : value)
end


# draw graph to canvas
function draw_graph(x0, y0, xsize, ysize, graphs; 
        single_scale=true, labels=[], fontsize=15)
	if single_scale # draw all graphs to the same scale
		max_all = mapreduce(g -> g.max, max, graphs) # find maximum of graphs[...].max
		min_all = mapreduce(g -> g.min, min, graphs)
	end

	for g in graphs
		g_max = single_scale ? max_all : g.max
		g_min = single_scale ? min_all : g.min

		# no x or y range, can't draw
		if g_max <= g_min || length(g.data) <= 1
			continue
		end

		x_scale = (xsize-1) / (length(g.data)-1)
		y_scale = (ysize-1) / (g_max - g_min)
		
		dxold = 1
		dyold = ysize - trunc(Int, (g.data[1]-g_min) * y_scale ) 

        for (i,dat) in enumerate(g.data)
			dx = trunc(Int, (i-1) * x_scale) + 1
			dy = ysize - trunc(Int, (dat-g_min) * y_scale) 
			RL.DrawLine(x0+dxold, y0+dyold, x0+dx, y0+dy, g.colour)
			dxold, dyold = dx, dy
		end
	end

    if isempty(labels)
        return nothing
    end

    @assert length(labels) == length(graphs)

    w = 0
    for l in labels
        w = max(w, RL.MeasureText(l*" ", fontsize))
    end

    lx = x0 + xsize - w

    for (i, l) in enumerate(labels)
        RL.DrawText(l, lx, i*fontsize, fontsize, graphs[i].colour)
    end

end


end
