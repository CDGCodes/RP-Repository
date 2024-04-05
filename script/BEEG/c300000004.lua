--BEEG Sucker
local s, id=GetID()
function s.initial_effect(c)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.drcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end

function s.drfilter(c, e, tp)
	return c:IsAbleToRemoveAsCost() end
end
function s.drcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drfilter, tp, LOCATION_MZONE, 0, 1, nil, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp, s.drfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.drtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp, 1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end
function s.drop(e, tp, eg, ep, ev, re, r, rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
