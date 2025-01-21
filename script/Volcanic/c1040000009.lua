-- Volcanic End Dragon
local s, id = GetID()
function s.initial_effect(c)
    -- Special Summon Condition
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, s.ffilter1, s.ffilter1, s.ffilter2)
    Fusion.AddContactProc(c, s.contactfil, s.contactop, true)

    -- Inflict Damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.damcon)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)

    -- Increase ATK and DEF
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.atkcost)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Return to Extra Deck
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCost(s.retcost)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

function s.ffilter1(c)
    return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER)
end

function s.ffilter2(c)
    return c:IsSetCard(0xb9) and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsFaceup()
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(s.ffilter1, tp, LOCATION_ONFIELD, 0, nil)
        + Duel.GetMatchingGroup(s.ffilter2, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL + REASON_FUSION)
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsControler, 1, nil, tp) and eg:IsExists(Card.IsAttribute, 1, nil, ATTRIBUTE_FIRE)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    local ct = eg:FilterCount(Card.IsControler, nil, tp)
    Duel.Damage(1 - tp, ct * 500, REASON_EFFECT)
end

function s.atkcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.costfilter, tp, LOCATION_HAND, 0, 2, nil) end
    Duel.DiscardHand(tp, s.costfilter, 2, 2, REASON_COST + REASON_DISCARD)
end

function s.costfilter(c)
    return c:IsRace(RACE_PYRO) and c:IsDiscardable()
end

function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
    end
end

function s.retcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.retfilter, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, 3, nil) end
    local g = Duel.SelectMatchingCard(tp, s.retfilter, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, 3, 3, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.retfilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PYRO) and not c:IsCode(1040000009)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
