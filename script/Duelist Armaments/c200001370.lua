--Duelist Armaments - Black Robe
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SPELL), 2, 2)
	c:SetSPSummonOnce(id)
end

function s.armfusfilter(c)
	return c:IsSetCard(0xFEDC) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end
