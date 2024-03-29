--Number 108: Fire Destroyer of Hell Dragon
local s, id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 7, 2, nil, nil, 99)
	--send card from opponent's hand to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.xyz_number=108

function s.condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND) > 0
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, 1-tp, 1)
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetFieldGroup(tp, 0, LOCATION_HAND)
	if #g<1 then return end
	Duel.ShuffleHand(1-tp)
	local hg=g:RandomSelect(tp, 1, 1, nil)
	Duel.BreakEffect()
	Duel.SendtoGrave(hg, REASON_EFFECT)
	local tc = hg:GetFirst()
	if tc:IsMonster() then
		Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
		local opt=Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2), aux.Stringid(id, 3))
		if opt==0 then -- Opponent takes damage
			Duel.Damage(1-tp, tc:GetAttack(), REASON_EFFECT)
		elseif opt==1 then -- This card gains ATK
			local c=e:GetHandler()
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(tc:GetAttack())
			c:RegisterEffect(e2)
		end
	end
end

