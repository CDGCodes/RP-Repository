-- Red Pirate Dragon, Bartholomew
local s, id = GetID()
function s.initial_effect(c)
    -- Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_TUNER), 1, 1, Synchro.NonTunerEx(Card.IsRace, RACE_DRAGON), 1, 99)

    -- Destroy cards on Synchro Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- Return to Extra Deck and add Dragon to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.tdcon)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    -- Once per turn clause
    e1:SetCountLimit(1, id)
    e2:SetCountLimit(1, id + 1)
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ct = e:GetHandler():GetMaterial():FilterCount(aux.FilterBoolFunctionEx(Card.IsNonTuner), nil)
    if chk == 0 then return ct > 0 end
    local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, ct, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetHandler():GetMaterial():FilterCount(aux.FilterBoolFunctionEx(Card.IsNonTuner), nil)
    local dg = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
    if #dg == 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local des = dg:Select(tp, ct, ct, nil)
    Duel.Destroy(des, REASON_EFFECT)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE) or (rp == tp and c:IsReason(REASON_EFFECT))
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToExtra() end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToExtra() then
        if Duel.SendtoDeck(c, nil, 2, REASON_EFFECT) ~= 0 and c:IsLocation(LOCATION_EXTRA) then
            local g = Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_DECK, 0, nil, RACE_DRAGON)
            if #g > 0 and Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
                Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
                local sg = g:Select(tp, 1, 1, nil)
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end
