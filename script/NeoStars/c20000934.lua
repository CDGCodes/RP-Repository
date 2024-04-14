local s, id = GetID()

-- Define the IDs of the cards
local id_neospacian = 0x1f -- ID of your "Neo-Spacian" card
local id_neos = 89943723 -- ID of your "Elemental HERO Neos" card

function s.initial_effect(c)
    -- Contact Fusion Material
    c:EnableReviveLimit()
    Fusion.AddProcMix(c, true, true, id_neos, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_DARK))
    Fusion.AddContactProc(c, s.contactfil, s.contactop, nil)  -- Removed the splimit parameter as it's no longer needed

    -- Defense trigger effect with "Once Per Duel" limit
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCondition(s.defcon)
    e1:SetCost(s.defcost)
    e1:SetTarget(s.deftg)
    e1:SetOperation(s.defop)
    e1:SetCountLimit(1, id)  -- "Once Per Duel" limit, using the card's unique ID
    c:RegisterEffect(e1)

    -- Effect to add "Neo Space", "Neos", or "Neo-Spacian" card from Deck or GY to hand by tributing this card
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Special summon a "Neo-Spacian" or "Elemental HERO Neos" from GY when this card is removed from the field
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 3))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCondition(s.spcon)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- Contact Fusion Material Filter
function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

-- Contact Fusion Operation
function s.contactop(g, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

-- Condition for the defensive trigger effect
function s.defcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetAttacker():IsControler(1-tp) and 
           not Duel.IsExistingMatchingCard(Card.IsLevelAbove, tp, LOCATION_MZONE, 0, 1, nil, 3)
end

-- Cost for the defensive trigger effect
function s.defcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_HAND, 0, 1, nil, id_neospacian) and
               Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE, 0, 1, nil, id_neos)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g1 = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_HAND, 0, 1, 1, nil, id_neospacian)
    Duel.ConfirmCards(1-tp, g1)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g2 = Duel.SelectMatchingCard(tp, Card.IsCode, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE, 0, 1, 1, nil, id_neos)
    Duel.SendtoGrave(g2, REASON_COST)
end

-- Targeting function for the special summon effect
function s.deftg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then
        return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- Special summon operation and apply indestructible effect
function s.defop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        e:GetHandler():RegisterEffect(e1)
    end
end

-- Tribute this card to add 1 "Neo Space", "Neos", or "Neo-Spacian" card from Deck or GY to hand
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp, nil, 1, e:GetHandler()) end
    local g = Duel.SelectReleaseGroup(tp, nil, 1, 1, e:GetHandler())
    Duel.Release(g, REASON_COST)
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType, TYPE_FIELD + TYPE_MONSTER), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, aux.FilterFaceupFunction(Card.IsType, TYPE_FIELD + TYPE_MONSTER), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- Special summon a "Neo-Spacian" or "Elemental HERO Neos" from GY when this card is removed from the field
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, id_neospacian + id_neos)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg = g:Select(tp, 1, 1, nil)
        Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        local tc = sg:GetFirst()
        if tc:IsType(TYPE_MONSTER) then
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end
