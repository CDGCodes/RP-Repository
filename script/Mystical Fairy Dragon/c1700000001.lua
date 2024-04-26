--Mystical Fairy Dragon
local s, id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunction(Card.IsCode, 25862681),1,1)
end