-- Custom Fusion Monster: Elemental HERO Neos + 1 non-Token Monster with 1000 or less ATK
-- Contact Fusion

local s, id = GetID()

function s.initial_effect(c)
    -- Fusion Material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, CARD_NEOS, aux.FilterBoolFunction(Card.IsAttackBelow, 1001)) -- Elemental HERO Neos + 1 non-Token Monster with 1000 or less ATK
    Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit) -- Contact Fusion
    
    -- To Hand
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    
    -- Special Summon "Dandy STAR Token"
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1, {id, 3})
    e6:SetCost(s.sscost)
    e6:SetTarget(s.sstg)
    e6:SetOperation(s.ssop)
    c:RegisterEffect(e6)

    -- Retrieve "Neo Space" or "Neo-Spacian" when "Dandy STAR Token" is destroyed
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 3))
    e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_DESTROYED)
    e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
    e7:SetRange(LOCATION_MZONE)
    e7:SetCountLimit(1, {id, 4})
    e7:SetCondition(s.thcon)
    e7:SetTarget(s.thtg_neo)
    e7:SetOperation(s.thop_neo)
    c:RegisterEffect(e7)

    -- When removed from field, Special Summon 1 "Neo-Spacian" monster with battle protection
    local e8 = Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id, 4)) -- New description ID for this effect
    e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e8:SetCode(EVENT_LEAVE_FIELD)
    e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e8:SetCondition(s.spcon)
    e8:SetTarget(s.sptg)
    e8:SetOperation(s.spop)
    c:RegisterEffect(e8)
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.filter(c)
    return c:IsAbleToHand() and c:IsLevelBelow(3)
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and s.filter(chkc) end
    if chk == 0 then return Duel.IsExistingTarget(s.filter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.filter, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end

function s.sscost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND, 0, 1, 1, nil)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
end

function s.sstg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_MZONE)
end

function s.ssop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local token = Duel.CreateToken(tp, 20000930) -- Adjusted token number
    local b1 = Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and token:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    local b2 = Duel.GetLocationCount(1-tp, LOCATION_MZONE) > 0 and token:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1-tp)
    local op = 0
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    if b1 and b2 then
        op = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
    elseif b1 then
        op = 0
    elseif b2 then
        op = 1
    end

    if op == 0 then
        if Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(1)
            token:RegisterEffect(e1, true)
        end
    else
        if Duel.SpecialSummon(token, 0, tp, 1-tp, false, false, POS_FACEUP) ~= 0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(1)
            token:RegisterEffect(e1, true)
        end
    end
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.tokenfilter, 1, nil)
end

function s.tokenfilter(c)
    return c:GetPreviousCodeOnField() == 20000930 and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end

function s.thtg_neo(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter_neo, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop_neo(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.thfilter_neo), tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

function s.thfilter_neo(c)
    return (c:IsSetCard(0x1f) or c:IsCode(42015635)) and c:IsAbleToHand()
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then
        local tc = g:GetFirst()
        if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end