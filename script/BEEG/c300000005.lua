--BEEG Goo LVL 4
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
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
end

function s.prval(e, re, r, rp)
	return (r&REASON_EFFECT+REASON_BATTLE)~=0
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(), REASON_COST)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end
function s.spfilter(c, e, tp)
	return c:IsCode(300000006) and c:IsCanBeSpecialSummoned(e, 0, tp, true, true)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil, e, tp) then return end
	Duel.Hint(HINT+SELECTMSG, tp, HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc, 0, tp, tp, true, true, POS_FACEUP)
		tc:CompleteProcedure()
	end
end
