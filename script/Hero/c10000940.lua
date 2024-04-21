local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon condition from hand
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Quick effect to Special Summon Fusion Monster ignoring conditions
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_END_PHASE)
    e2:SetCountLimit(1)
    e2:SetCost(s.fuscost)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x8), tp, LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_GRAVE, 0, 1, nil)
end

function s.filter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x6008) and c:IsAbleToDeck() and not c:IsCode(id)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local tg = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SendtoDeck(tg, nil, 2, REASON_COST)
end

function s.banfilter(c)
    return c:IsSetCard(0x8) and c:IsAbleToRemoveAsCost() and not c:IsCode(id)
end

function s.fuscost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.banfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
    local g = Duel.SelectMatchingCard(tp, s.banfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.fustg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
        and Duel.IsExistingTarget(Card.IsType, tp, LOCATION_GRAVE, 0, 1, nil, TYPE_FUSION) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, Card.IsType, tp, LOCATION_GRAVE, 0, 1, 1, nil, TYPE_FUSION)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.fusop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL+1, tp, tp, false, false, POS_FACEUP) ~= 0 then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            local e3 = Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e3)
            local e4 = Effect.CreateEffect(e:GetHandler())
            e4:SetType(EFFECT_TYPE_FIELD)
            e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e4:SetTargetRange(1, 0)
            e4:SetTarget(s.sumlimit)
            e4:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e4, tp)
        end
    end
end

function s.sumlimit(e, c, sumtype, tp)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x6008)
end
