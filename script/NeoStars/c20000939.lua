-- Define the script's local variables and ID
local s, id = GetID()

-- Initial effect function
function s.initial_effect(c)
    -- Treat as "Elemental HERO Neos"
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_ALL)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(89943723)  -- Card ID for "Elemental HERO Neos"
    c:RegisterEffect(e1)

    -- Special summon from hand by banishing 2 other "HERO" or "Neo-Spacian" monsters from hand or GY
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, {id, 0})
    e2:SetCost(s.spcost1)
    e2:SetTarget(s.sptarget1)
    e2:SetOperation(s.spoperation1)
    c:RegisterEffect(e2)

    -- Special summon from hand or Deck by paying 1000 LP
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(2, {id, 1})
    e3:SetCost(s.spcost2)
    e3:SetTarget(s.sptarget2)
    e3:SetOperation(s.spoperation2)
    c:RegisterEffect(e3)
end

-- Special summon from hand by banishing 2 other "HERO" or "Neo-Spacian" monsters from hand or GY
function s.spcost1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.TRUE, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 2, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 2, 2, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.sptarget1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spoperation1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

-- Special summon from hand or Deck by paying 1000 LP
function s.spcost2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFlagEffect(tp, id) < 2 and Duel.CheckLPCost(tp, 1000)
    end
    Duel.PayLPCost(tp, 1000)
end

function s.sptarget2(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.spoperation2(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 0)  -- Register LP cost usage
end

-- Filter for the "HERO" or "Neo-Spacian" monster to be Special Summoned from hand or Deck
function s.spfilter(c)
    return (c:IsSetCard(0x8) or c:IsSetCard(0x1f)) and c:IsLevelBelow(5)
end
