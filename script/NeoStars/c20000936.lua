local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion materials
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17955766, 80344569)
    Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)

    -- Special Summon effects
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCondition(s.tdcon)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)

    -- End Phase effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.eptg)
    e2:SetOperation(s.epop)
    c:RegisterEffect(e2)
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

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local count = Duel.GetMatchingGroupCount(aux.AND(Card.IsAbleToDeck, aux.NOT(Card.IsPublic)), tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
        return count > 0
    end
    local g = Duel.GetMatchingGroup(aux.AND(Card.IsAbleToDeck, aux.NOT(Card.IsPublic)), tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, g:GetCount(), 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.AND(Card.IsAbleToDeck, aux.NOT(Card.IsPublic)), tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    local ct = Duel.SendtoDeck(g, nil, SEQ_DECKTOP, REASON_EFFECT)
    if ct > 0 then
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local atk = ct * 200
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end

function s.eptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck, tp, LOCATION_REMOVED + LOCATION_GRAVE, 0, 1, nil) end
    local g = Duel.SelectTarget(tp, Card.IsAbleToDeck, tp, LOCATION_REMOVED + LOCATION_GRAVE, 0, 1, 5, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, g:GetCount(), 0, 0)
end

function s.epop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
