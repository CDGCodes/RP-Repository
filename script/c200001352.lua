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
 	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
 	e1:SetCondition(s.bnccon)
 	e1:SetTarget(s.bnctgt)
 	e1:SetOperation(s.bncop)
 	c:RegisterEffect(e1)
 	--Special Summon
 end
 
 function s.bnccon(e, tp, eg, ep, ev, re, r, rp)
 	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
 end
 function s.bnctgt(e, tp, eg, ep, ev, re, r, rp, chk)
 	local ct=e:GetHandler():GetMaterialCount()
 	if chkc then return chkc:IsOnField() end
 	if chk==0 then return Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) and ct>0 end
 	Duel.Hint(HINTSELECTMSG, tp, HINTMSG_DESTROY)
 	local g=Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
 	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
 end
 function s.bncop(e, tp, eg, ep, ev, re, r, rp)
 	local g=Duel.GetTargetCards(e)
 	Duel.SendtoHand(g, nil, REASON_EFFECT)
 end
