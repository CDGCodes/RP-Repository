-- Elemental HERO Nimbus Neos
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion Summon Procedure
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17732278, 54959865)
    Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)

    -- Special Summon from Extra Deck effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY + CATEGORY_RECOVER + CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.negateTarget)
    e1:SetOperation(s.negateOperation)
    c:RegisterEffect(e1)
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end

function s.negateTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local handCount = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) + Duel.GetFieldGroupCount(tp, LOCATION_HAND, 1)
        local limit = math.min(handCount, 5)
        return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) and limit > 0
    end
    local handCount = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) + Duel.GetFieldGroupCount(tp, LOCATION_HAND, 1)
    local limit = math.min(handCount, 5)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, limit, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE + CATEGORY_DESTROY + CATEGORY_RECOVER + CATEGORY_DRAW, g, #g, 0, 0)
    return true
end

function s.negateOperation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect, nil, e)
    local ct = Duel.Destroy(g, REASON_EFFECT)
    if ct > 0 then
        Duel.Recover(tp, ct * 500, REASON_EFFECT)
        Duel.Draw(tp, 1, REASON_EFFECT)  -- Draw 1 card as part of the same effect
    end
end
