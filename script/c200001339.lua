--Number 108: Fire Destroyer of Hell Dragon
local s, id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 7, 2, nil, nil, 99)
	--send card from opponent's hand to GY
	local e1=Effect.CreateEffect(c)
	--e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	--e1:SetType(EFFECT_TYPE_FIELD)
	--e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	--e1:SetCondition(s.condition)
	--e1:SetTarget(s.target)
	--e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.xyz_number=108
function s.condition(e, tp, eg, ep, ev, re, r, rp)
	return true
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return false end
	Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, 1-tp, 1)
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
	if #g<1 then return end
	Duel.ShuffleHand(1-tp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local tc=g:RandomSelect(tp, 1, 1, nil)
	Duel.BreakEffect()
	Duel.SendtoGrave(tc, REASON_EFFECT)
end
