--Tenebrum, Terror King Of Nightmares
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,400000011,400000012)

	--Invunrability
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
		e1:SetValue(s.prval)
	c:RegisterEffect(e1)
end

--Invunrability
function s.prval(e, re, r, rp)
	return (r&REASON_BATTLE)~=0
end