-- Matchstick
-- Created by ScareTheVoices
local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c)
    return c:IsFaceup() and c:IsRace(RACE_PYRO)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsOnField() and chkc:IsControler(1 - tp) and chkc:IsType(TYPE_SPELL + TYPE_TRAP)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsType, tp, 0, LOCATION_ONFIELD, 1, nil, TYPE_SPELL + TYPE_TRAP)
            and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsType, tp, 0, LOCATION_ONFIELD, 1, 1, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end
