--Malefic Fang of Critias
local s, id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.target)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end

function s.malfilter(c)
	return c:IsSetCard(0x23) and c:IsAbleToDeck()
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp, 1) and Duel.IsExistingMatchingCard(s.malfilter, tp, LOCATION_GRAVE, 0, 3, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 3, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.op(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.malfilter), tp, LOCATION_GRAVE, 0, nil)
	if #g<3 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
	local sg=g:Select(tp, 3, 3, nil)
	Duel.SendtoDeck(sg, nil, 0, REASON_EFFECT)
	local og=Duel.GetOperatedGroup()
	if og:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=og:FilterCount(Card.IsLocation, nil, LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		Duel.Draw(tp, 1, REASON_EFFECT)
	end
end
