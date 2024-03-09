--Diamond Crystal Wing Synchro Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1, Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 1)
	--Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.imfilter)
	c:RegisterEffect(e1)
	--Gain ATK
	--Revive materials
	--Negate
end

function s.imcon(e)
	local c=e:GetHandler()
	local bc=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	return bc and ((bc==c and tc:IsLevelAbove(5)) or (tc==c and bc:IsLevelAbove(5)))
end

function s.imfilter(e, te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
