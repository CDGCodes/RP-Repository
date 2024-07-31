--Card Name: HEROic Exchange
local s, id = GetID()

function s.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.tgfilter(c, tp)
    return c:IsSetCard(0x8) and c:IsControler(tp) and c:IsAbleToGrave()
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        if chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) then
            return s.tgfilter(chkc, tp)
        elseif chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) then
            return s.spfilter(chkc, e, tp)
        end
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.tgfilter, tp, LOCATION_MZONE, 0, 1, nil, tp)
            and Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g1 = Duel.SelectTarget(tp, s.tgfilter, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g2 = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g1, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g2, 1, 0, 0)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc1 = g:GetFirst()
    local tc2 = g:GetNext()
    if not tc1 or not tc2 then return end
    if tc1:IsLocation(LOCATION_GRAVE) then tc1, tc2 = tc2, tc1 end
    if not (tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e)) then return end
    if Duel.SendtoGrave(tc1, REASON_EFFECT) ~= 0 then
        if Duel.SpecialSummon(tc2, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc2:RegisterEffect(e1)
        end
    end
end
