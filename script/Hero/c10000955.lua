local s, id = GetID()

function s.initial_effect(c)
    -- Must be Special Summoned with "Mask Change"
    c:EnableReviveLimit()
    aux.AddMaskedEff(c, s.mfilter, MASKED_SPELL_EFFECT)

    -- Banish on summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetCondition(s.banishcon)
    e1:SetTarget(s.banishtg)
    e1:SetOperation(s.banishop)
    c:RegisterEffect(e1)

    -- Negate attack and banish
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.negatecon)
    e2:SetOperation(s.negateop)
    c:RegisterEffect(e2)

    -- ATK Boost
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)
end

-- Must be Special Summoned with "Mask Change"
function s.mfilter(c)
    return c:IsSetCard(0x8) and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK)
end

-- Banish on summon
function s.banishcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL + 0x8)
end

function s.banishtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.banishop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
    end
end

-- Negate attack and banish
function s.negatecon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1 - tp)
end

function s.negateop(e, tp, eg, ep, ev, re, r, rp)
    local atk = Duel.GetAttacker()
    if Duel.NegateAttack() then
        Duel.Remove(atk, POS_FACEUP, REASON_EFFECT)
    end
end

-- ATK Boost
function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsSetCard, 0x8), c:GetControler(), LOCATION_GRAVE, 0, nil) * 100
end
