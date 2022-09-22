

function drawModel(model, offset, townSize, houseSize)
    for house in model.houses
        town_pos = house.town.pos
        # top left corner of town
        t_offset = offset[1] + (town_pos[1]-1) * townSize[1],
            offset[2] + (town_pos[2]-1) * townSize[2]
        
        # top left corner of house
        h_offset = t_offset[1] + (house.pos[1]-1) * houseSize[1],
            t_offset[2] + (house.pos[2]-1) * houseSize[2]
        
        col = isempty(house.occupants) ? RL.BLACK : RL.RED
        RL.DrawRectangleRec(RL.RayRectangle(h_offset..., houseSize...), col)
    end

    for town in model.towns
        t_offset = offset[1] + (town.pos[1]-1) * townSize[1],
            offset[2] + (town.pos[2]-1) * townSize[2]

        RL.DrawRectangleLinesEx(RL.RayRectangle(t_offset..., townSize...), 1.0, RL.GREEN)
    end
end
    
