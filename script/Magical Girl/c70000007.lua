local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x6942))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	
		local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetValue(s.indct)
	e3:SetTarget(function(_,c) return c:IsMonster() and c:IsSetCard(0x6942) and c:IsFaceup() end)
	c:RegisterEffect(e3)
	
end

function s.atkfilter(c)
	return c:IsSetCard(0x6942)
end
function s.atkval(e, c)
	return Duel.GetMatchingGroupCount(s.atkfilter, e:GetHandlerPlayer(), LOCATION_MZONE, 0, nil, nil)*200
end

function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end