using MiniObserve

@observe Data model begin
    @record "N"     Int     length(model.pop)

    @for house in model.houses begin
        @stat("hh_size", MeanVarAcc{Float64}) <| Float64(length(house.occupants))
    end
end
