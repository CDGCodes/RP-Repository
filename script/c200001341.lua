--Number C87: Empress of the Chaotic Night
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	c:EnableReviveLimit()
	Xyz.AddProcedure(c, nil, 9, 4, nil, nil, 4)
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
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(s.con)
	e2:SetCost(s.cost)
	e2:SetTarget(s.bptg)
	e2:SetOperation(s.bpop)
	c:RegisterEffect(e2, false, REGISTER_FLAG_DETACH_XMAT)
	--Set card nuke
	
	--ATK increase
	
end

s.xyz_number=87

function s.sumlimit(e, c, sump, sumtype, sumpos, targetp)
	return (sumpos&POS_FACEDOWN)>0
end

function s.con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 89516305)
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayChard(tp, 1, REASON_COST) end
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
