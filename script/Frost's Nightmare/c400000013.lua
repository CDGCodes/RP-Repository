--Tenebrum, Terror King Of Nightmares
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,400000011,400000012)
end