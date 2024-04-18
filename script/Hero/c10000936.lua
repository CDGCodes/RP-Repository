-- Evil HERO Sinister Shocker
-- This card's name is also treated as "Elemental HERO Sparkman" while on the field or in the graveyard.
-- You can only use each of the following effects of "Evil Hero Sinister Shocker" once per turn.

local s, id = GetID()

function s.initial_effect(c)
    -- Name treated as Elemental HERO Sparkman while on field or in GY
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(20721928) -- Elemental HERO Sparkman's card ID
    c:RegisterEffect(e1)

    -- Special Summon an "Evil HERO" monster from hand or Deck when "Evil HERO Sinister Shocker" is Summoned.
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- When an "Evil HERO" monster you control is targeted for an attack: You can banish this card from your GY; negate the attack, and if you do, inflict damage to your opponent equal to half the ATK of the attacking monster.
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetCountLimit(1, id + 100)
    e3:SetCondition(s.negcon)
    e3:SetCost(s.negcost)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end

-- Special Summon an "Evil HERO" monster from hand or Deck when "Evil HERO Sinister Shocker" is Summoned.
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        -- Negate the effects of the Special Summoned monster
        local tc = g:GetFirst()
        if tc then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1,true)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e2,true)
            local e3 = Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            e3:SetCode(EFFECT_CANNOT_ATTACK)
            e3:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e3,true)
        end
    end
end

-- Negate the attack and inflict damage
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    local atk = Duel.GetAttacker():GetAttack()
    return atk and atk > 0 and e:GetHandler():IsAbleToRemoveAsCost()
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
    local atk = Duel.GetAttacker():GetAttack() / 2
    if atk > 0 then
        Duel.Damage(1 - tp, atk, REASON_EFFECT)
    end
end

-- Filter for "Evil HERO" monsters
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x6008) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
