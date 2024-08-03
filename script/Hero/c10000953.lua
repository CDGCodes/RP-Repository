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

    -- Special Summon from GY effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, id + 100)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
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
        local ct = Duel.GetMatchingGroupCount(s.atkfilter, tp, LOCATION_MZONE, 0, nil)
        local atk = 300 * ct
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

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        local tc = g:GetFirst()
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)

        -- Add effect to negate the monster's effects
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)

        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.thfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect, nil, e)
    if #tg > 0 then
        Duel.SendtoHand(tg, nil, REASON_EFFECT)
    end
end
