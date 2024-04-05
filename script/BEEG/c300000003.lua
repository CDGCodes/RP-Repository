 --BEEG Producer
 local s, id=GetID()
 function s.initial_effect(c)
 	--Special Summon
 	local e0=Effect.CreateEffect(c)
 	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
 	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
 	e0:SetProperty(EFFECT_FLAG_DELAY)
 	e0:SetCode(EVENT_TO_HAND)
 	e0:SetRange(LOCATION_HAND)
 	e0:SetCondition(s.spcon)
 	e0:SetOperation(s.spop)
 	c:RegisterEffect(e0)
 	local e1=Effect.CreateEffect(c)
 	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
 	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
 	e1:SetCode(EVENT_SUMMON_SUCCESS)
 	e1:SetRange(LOCATION_MZONE)
 	e1:SetCost(s.bgcst)
 	e1:SetOperation(s.bgop)
 	c:RegisterEffect(e1)
 	local e2=e1:Clone()
 	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
 	c:RegisterEffect(e2)
 	local e3=e1:Clone()
 	e3:SetCode(EVENT_FLIP)
 	c:RegisterEffect(e3)
 end
 
 function s.spcon(e, tp, eg, ep, ev, re, r, rp)
 	return (r&REASON_EFFECT)~=0
 end
 function s.spop(e, tp, eg, ep, ev, re, r, rp)
 	local c=e:GetHandler()
 	if not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then return false end
 	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
 end
 
 function s.bgcst(e, tp, eg, ep, ev, re, r, rp, chk)
 	local g=Duel.GetFieldGroup(tp, LOCATION_MZONE, 0)
 	local rg=Duel.GetReleaseGroup(tp)
 	if chk==0 then return (#g>0 or #rg>0) and g:FilterCount(Card.IsReleasable, nil)==#g end
 	Duel.Release(g, REASON_COST)
 end
 function s.bgfilter(c, e, tp)
 	return c:IsLevel(4) 
 	and c:IsSetCard(0x2334) 
 	and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
 end
 function s.bgop(e, tp, eg, ep, ev, re, r, rp)
 	if not Duel.IsExistingMatchingCard(s.bgfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 2, nil, e, tp) or not (Duel.GetLocationCount(tp, LOCATION_MZONE)>=2) then return end
 	local g=Duel.SelectMatchingCard(tp, s.bgfilter, tp, LOCATION_DECK+LOCATION_HAND, 0, 2, 2, nil, e, tp)
 	if #g>0 then
 		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
 	end
 end
