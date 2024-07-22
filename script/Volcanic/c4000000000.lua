-- Matchstick (Enhanced Effect)
-- Created by ScareTheVoices
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckReleaseGroup(tp, Card.IsType, 1, nil, TYPE_MONSTER) end
    local g = Duel.SelectReleaseGroup(tp, Card.IsType, 1, 1, nil, TYPE_MONSTER)
    Duel.Release(g, REASON_COST)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, TYPE_SPELL + TYPE_TRAP) end
    local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil, TYPE_SPELL + TYPE_TRAP)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
    -- Destroy a Pyro monster you control
    local pyroMonsters = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_MZONE, LOCATION_MZONE, nil, TYPE_MONSTER)
    if #pyroMonsters > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        local selectedMonster = pyroMonsters:Select(tp, 1, 1, nil)
        Duel.Destroy(selectedMonster, REASON_EFFECT)
    end
end
