  --Malefic Eye of Timaeus
 local s, id=GetID()
 function s.initial_effect(c)
 	--Activate
 	local e1=Effect.CreateEffect(c)
 	e1:SetCategory(CATEGORY_REMOVE)
 	e1:SetType(EFFECT_TYPE_ACTIVATE)
 	e1:SetCode(EVENT_FREE_CHAIN)
 	e1:SetTarget(s.target)
 	e1:SetOperation(s.operation)
 	c:RegisterEffect(e1)
 end
 
 function s.filter(c)
 	return c:IsCode(27564031) and c:IsAbleToRemove()
 end
 function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
 	if chk==0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil) end
 	Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, LOCATION_DECK)
 end
 function s.operation(e, tp, eg, ep, ev, re, r, rp)
 	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
 	local g=Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
 	if #g>0 then
 		Duel.Remove(g, POS_FACEUP, REASON_COST)
 	end
 end
