-- Red Pirate Dragon, Bartholomew
local s, id = GetID()

function s.initial_effect(c)
    -- Synchro Summon procedure
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_DRAGON), 1, 1, Synchro.NonTuner(Card.IsRace, RACE_DRAGON), 1, 99)

    -- Destroy cards upon Synchro Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Return to Extra Deck and search when it leaves the field
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1, id+100)
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

-- Destroy cards upon Synchro Summon
function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsOnField, tp, 0, LOCATION_ONFIELD, 1, nil) end
    local ct = e:GetHandler():GetMaterial():FilterCount(Card.IsRace, nil, RACE_DRAGON)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsOnField, tp, 0, LOCATION_ONFIELD, 0, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end

-- Return to Extra Deck and search target
function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND + CATEGORY_SEARCH, nil, 1, tp, LOCATION_DECK)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) ~= 0 then
        local g = Duel.SelectMatchingCard(tp, Card.IsRace, tp, LOCATION_DECK, 0, 1, 1, nil, RACE_DRAGON)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end
