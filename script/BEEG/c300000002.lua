 --BEEG Security
 local s, id=GetID()
 function s.initial_effect(c)
 	local e0=Effect.CreateEffect(c)
 	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
 	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
 	e0:SetCode(EVENT_SUMMON_SUCCESS)
 	e0:SetOperation(s.op)
 	c:RegisterEffect(e0)
 end
 
 function s.filter(c)
 	return c:IsMonster() and c:IsSetCard(0x2334) and c:IsAbleToHand()
 end
 function s.op(e, tp, eg, ep, ev, re, r, rp)
 	local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_DECK, 0, nil)
 	if #g<2 then return end
 	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
 	local sg=g:Select(tp, 2, 2, nil)
 	Duel.SendtoHand(sg, nil, REASON_EFFECT)
 	Duel.ConfirmCards(1-tp, sg)
 end
