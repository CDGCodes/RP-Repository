--Raiden, Hand of the Twlightsworn
local s, id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0x38), 1, 1, nil, nil)
end