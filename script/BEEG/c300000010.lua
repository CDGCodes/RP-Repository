--BEEG Slime LVL 8
local s, id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetValue(s.prval)
	c:RegisterEffect(e1)
	--Pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e3)
	--Level Up
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	--Gain ATK
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetValue(s.value)
	c:RegisterEffect(e5)
	--Cannot Special Summon from Extra Deck
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e6:SetTargetRange(1, 0)
	e6:SetTarget(s.splimit)
	c:RegisterEffect(e6)
	--Burn
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e7:SetCategory(CATEGORY_DAMAGE)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(function(e) return e:GetHandler():IsReason(REASON_RELEASE) end)
	e7:SetTarget(s.btg)
	e7:SetOperation(s.bop)
	c:RegisterEffect(e7)
	--Draw
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_DRAW)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1)
	e8:SetTarget(s.drtg)
	e8:SetOperation(s.drop)
	c:RegisterEffect(e8)
end

function s.prval(e, re, r, rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(), REASON_COST)
end
function s.spfilter(c, e, tp)
	return c:IsCode(300000012) and c:IsCanBeSpecialSummoned(e, 0, tp, true, true)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, true, true, POS_FACEUP) then
		--Cannot activate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3302)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end

function s.value(e, c)
	return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_REMOVED, LOCATION_REMOVED)
end

function s.splimit(e, c)
	return c:IsLocation(LOCATION_EXTRA)
end

function s.btg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1-tp, 1)
end
function s.bop(e, tp, eg, ep, ev, re, r, rp)
	local p, d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.Damage(p, d, REASON_EFFECT)
end

function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp, 1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, 1)
end
function s.drop(e, tp, eg, ev, re, r, rp)
	local p,d=Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	if Duel.Draw(p, d, REASON_EFFECT)~=0 then
		local tc=Duel.GetOperatedGroup():GetFirst()
		Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
	end
end
