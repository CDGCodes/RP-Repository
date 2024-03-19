--Five-Headed Thunder Dragon
local s, id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c, true, true, aux.FilterBoolFunctionEx(Card.IsRace, RACE_THUNDER), 5)
	--Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.imcon)
	e1:SetValue(s.imfilter)
	c:RegisterEffect(e1)
	--ATK/DEF up
	local e2=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(5)
	e1:SetCost(s.adcost)
	e1:SetOperation(s.adop)
	c:RegisterEffect(e2)
end

function s.imcon(e)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.imfilter(e, te)
	return te:GetOwner()~=e:GetOwner()
end

function s.adfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c)
end
function s.adcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.adfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, s.adfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.adop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
