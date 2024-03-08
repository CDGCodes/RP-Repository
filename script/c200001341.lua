--Number C87: Empress of the Chaotic Night
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 9, 4)
	--cannot set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(aux.TRUE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTarget(s.sumlimit)
	c:RegisterEffect(e4)
	--BP Change
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id, 1))
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
	e5:SetCondition(s.con)
	e5:SetCost(s.cost)
	e5:SetTarget(s.bptg)
	e5:SetOperation(s.bpop)
	c:RegisterEffect(e5, false, REGISTER_FLAG_DETACH_XMAT)
	--Set card nuke
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id, 2))
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
	e6:SetCondition(s.con)
	e6:SetCost(s.cost)
	e6:SetTarget(s.settarget)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6, false, REGISTER_FLAG_DETACH_XMAT)
	--ATK increase
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id, 3))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
	e7:SetCondition(s.con)
	e7:SetCost(s.cost)
	e7:SetTarget(s.atktg)
	e7:SetOperation(s.atkop)
	c:RegisterEffect(e7, false, REGISTER_FLAG_DETACH_XMAT)
end

s.xyz_number=87

function s.sumlimit(e, c, sump, sumtype, sumpos, targetp)
	return (sumpos&POS_FACEDOWN)>0
end

function s.con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 89516305)
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
	Duel.Hint(HINT_OPSELECTED, 1-tp, e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.bpfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.bptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.bpfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.bpfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp, s.bpfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
end
function s.bpop(e, tp, eg, ev, re, r, rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE) end
end

function s.setfilter(c)
	return c:IsFacedown()
end
function s.settarget(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
	local g=Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
	Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)

end
function s.setop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.setfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
	Duel.Destroy(g, REASON_EFFECT)
end

function s.atkfilter(c)
	return c:IsFaceup()
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter, tp, LOCATION_MZONE, 0, 1, nil) end
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_MZONE, 0, nil)
	if #g==0 then return end
	local c=g:GetFirst()
	for c in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
