--Number 108: Fire Destroyer of Hell Dragon
local s, id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 7, 2, nil, nil, 99)
	--send card from opponent's hand to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(aux.dxmcostgen(1,1,nil))
	e1:SetCondition(s.condition)
	--e1:SetTarget(s.target)
	--e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--multi destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.mtcon)
	--e3:SetOperation(s.mtop)
	c:RegisterEffect(e3)
end

s.xyz_number=108

function s.condition(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND) > 0
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

function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,5)
	local g=Duel.GetDecktopGroup(tp,5)
	local tt=g:FilterCount(Card.IsType,nil,TYPE_TUNER)
	local gt=g:FilterCount(Card.IsType,nil,TYPE_MONSTER)
	local ct=gt-tt
	Duel.ShuffleDeck(tp)
	if ct>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local f=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		local sg=f:Select(tp,ct,math.min(ct,#g),nil)
		local dmg = Duel.Destroy(sg,REASON_EFFECT)
		if dmg>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			e1:SetValue(dmg*500)
			c:RegisterEffect(e1)
		end
	end
end
