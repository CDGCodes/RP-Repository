--Duelist Armaments - Black Armor
local s, id=GetID()
function s.initial_effect(c)
    --Summon Restrictions
	c:SetUniqueOnField(1, 0, s.armfusfilter, LOCATION_MZONE, c)
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SPELL), 2, 3, nil, nil, nil, nil, false, s.xyzcheck)
	c:SetSPSummonOnce(id)
end

function s.armfusfilter(c)
	return c:IsSpell() and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_SYNCHRO)
end

function s.xyzfilter(c,xyz,tp)
	return c:IsCode(200001369)
end
function s.xyzcheck(g,tp,xyz)
	return g:IsExists(s.xyzfilter,1,nil,xyz,tp)
end