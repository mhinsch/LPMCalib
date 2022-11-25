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

using Printf

using Raylib
const RL = Raylib

export Graph, add_value!, draw_graph, set_data!

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

function set_data!(graph::Graph, data; maxm = data[1], minm = data[1])
    graph.data = data
    graph.max = maxm == data[1] ? maximum(data) : maxm
    graph.min = minm == data[1] ? minimum(data) : minm
end
    

function draw_legend(value, x, y, fontsize, colour)
    text = @sprintf "%g" value
    RL.DrawText(text, x, y, fontsize, colour)
end


# draw graph to canvas
function draw_graph(x_0, y_0, width, height, graphs; 
        single_scale=true, labels=[], fontsize=15)
	if single_scale # draw all graphs to the same y scale
		max_all = mapreduce(g -> g.max, max, graphs) # find maximum of graphs[...].max
		min_all = mapreduce(g -> g.min, min, graphs)
	end

    width_legend = RL.MeasureText("00000000", fontsize)
    width_g = width - width_legend
    height_g = height - fontsize
    x_0_g = x_0 + width_legend

	for g in graphs
		g_max = single_scale ? max_all : g.max
		g_min = single_scale ? min_all : g.min

		# no x or y range, can't draw
		if g_max <= g_min || length(g.data) <= 1
			continue
		end

		x_scale = (width_g-1) / (length(g.data)-1)
		y_scale = (height_g-1) / (g_max - g_min)
		
		dxold = 1
		dyold = height_g - trunc(Int, (g.data[1]-g_min) * y_scale ) 

        for (i,dat) in enumerate(g.data)
			dx = trunc(Int, (i-1) * x_scale) + 1
			dy = height_g - trunc(Int, (dat-g_min) * y_scale) 
			RL.DrawLine(x_0_g+dxold, y_0+dyold, x_0_g+dx, y_0+dy, g.colour)
			dxold, dyold = dx, dy
		end
	end

    if single_scale
        draw_legend(min_all, x_0, y_0 + height, fontsize, graphs[1].colour)
        draw_legend(max_all, x_0, y_0, fontsize, graphs[1].colour)
    else
        yoffs = y_0 + height - fontsize * length(graphs)
        for (i, g) in enumerate(graphs)
            draw_legend(g.min, x_0, yoffs + (i-1) * fontsize, fontsize, g.colour)
            draw_legend(g.max, x_0, y_0 + (i-1) * fontsize, fontsize, g.colour)
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

    lx = x_0 + width - w

    for (i, l) in enumerate(labels)
        RL.DrawText(l, lx, (i-1)*fontsize, fontsize, graphs[i].colour)
    end

end


end
