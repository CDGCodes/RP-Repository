 --Quintet Magician Girl
 local s, id=GetID()
 function s.initial_effect(c)
 	--Fusion Restriction
 	c:EnableReviveLimit()
 	Fusion.AddProcMixRep(c, true, true, aux.FilterBoolFunctionEx(Card.IsRace, RACE_SPELLCASTER), 3, 5)
 	local e0=Effect.CreateEffect(c)
 	e0:SetType(EFFECT_TYPE_SINGLE)
 	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
 	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
 	e0:SetValue(aux.fuslimit)
 	c:RegisterEffect(e0)
 	--Return to hand
 	local e1=Effect.CreateEffect(c)
 	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
 	e1:SetCategory(CATEGORY_TOHAND)
 	e1:SetCountLimit(1, id, 0)
 	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
 	e1:SetCondition(s.bnccon)
 	e1:SetTarget(s.bnctgt)
 	e1:SetOperation(s.bncop)
 	c:RegisterEffect(e1)
 	--Special Summon
 	local e2=Effect.CreateEffect(c)
 	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
 	e2:SetCode(EVENT_DESTROYED)
 	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
 	e2:SetCountLimit(1, id, 1)
 	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
 	e2:SetCondition(s.sumcon)
 	e2:SetTarget(s.sumtgt)
 	e2:SetOperation(s.sumop)
 	c:RegisterEffect(e2)
 end
 
 function s.bnccon(e, tp, eg, ep, ev, re, r, rp)
 	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
 end
 function s.bnctgt(e, tp, eg, ep, ev, re, r, rp, chk)
 	local ct=e:GetHandler():GetMaterialCount()
 	if chkc then return chkc:IsOnField() end
 	if chk==0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) and ct>0 end
 	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
 	local g=Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
 	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
 end
 function s.bncop(e, tp, eg, ep, ev, re, r, rp)
 	local g=Duel.GetTargetCards(e)
 	Duel.SendtoHand(g, nil, REASON_EFFECT)
 end
 
 function s.sumcon(e, tp, eg, ep, ev, re, r, rp)
 	local c=e:GetHandler()
 	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
 end
 function s.sumfilter(c)
 	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned()
 end
 function s.sumtgt(e, tp, eg, ep, ev, re, r, rp, chk)
 	local c=e:GetHandler()
 	local ct=c:GetMaterialCount()
 	if chk==0 then return c:IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and ct>0 and Duel.IsExistingMatchingCard(s.sumfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
 	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_GRAVE)
 end
 function s.sumop(e, tp, eg, ep, ev, re, r, rp)
 	local c=e:GetHandler()
 	local ct=c:GetMaterialCount()
 	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
 	local g=Duel.SelectMatchingCard(tp, s.sumfilter, tp, LOCATION_GRAVE, 0, 1, ct, nil)
 	if #g>0 then
 		local gc=g:GetFirst()
 		for gc in aux.Next(g) do
 			Duel.SpecialSummonStep(gc, 0, tp, tp, false, false, POS_FACEUP)
 		end
 		Duel.SpecialSummonComplete()
 	end
 end
