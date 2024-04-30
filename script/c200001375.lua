--The Great Deck Vacuum
local s, id=GetID()
function s.initial_effect(c)
    --Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
    --Succ
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true
    local og=Duel.GetOverlayCount(tp, 0, 1)
    if #og>0 then
        Duel.SendtoDeck(og, tp, -2, REASON_COST)
    end
    local g=Duel.GetMatchingGroup(aux.True, tp, 0, LOCATION_ALL, nil)
    if #g>0 then
        Duel.SendtoDeck(g, tp, -2, REASON_COST)
    end
end
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, 1-tp, 1)
end
function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end