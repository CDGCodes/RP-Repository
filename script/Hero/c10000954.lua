-- Malevolent Darkstorm
local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- ATK gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.atktg)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Shuffle into deck and draw effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 100)
    e3:SetCondition(s.drawcon)
    e3:SetTarget(s.drawtg)
    e3:SetOperation(s.drawop)
    c:RegisterEffect(e3)

    -- Add back to hand effect
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end

function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.atkfilter, tp, LOCATION_MZONE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local g = Duel.GetMatchingGroup(s.atkfilter, tp, LOCATION_GRAVE, 0, nil)
        local atk = g:GetClassCount(Card.GetCode) * 300
        if atk > 0 then
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end

function s.atkfilter(c)
    return c:IsSetCard(0x8) and c:IsFaceup()
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.drawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.todeckfilter, tp, LOCATION_GRAVE, 0, nil)
    if #g > 0 then
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end

function s.todeckfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_FUSION) and c:IsAbleToDeck()
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.banishfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.SelectMatchingCard(tp, s.banishfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end
end

function s.banishfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
