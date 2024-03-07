--Number 108: Fire Destroyer of Hell Dragon
local s, id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 7, 2, nil, nil, 99)
end
