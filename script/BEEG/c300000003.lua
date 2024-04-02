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
 end
 
 function s.spcon(e, tp, eg, ep, ev, re, r, rp)
 	return (r&REASON_EFFECT)~=0
 end
 function s.operation(e, tp, eg, ep, ev, re, r, rp)
 	local c=e:GetHandler()
 	if not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then return false
 	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
 end
