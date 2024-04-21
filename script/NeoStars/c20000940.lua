-- Define the script's local variables and ID
local s, id = GetID()

-- Initial effect function
function s.initial_effect(c)
    -- Link summon condition
    Link.AddProcedure(c, s.matfilter, 1, 1)
    c:EnableReviveLimit()

    -- Search effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.searchCondition)
    e1:SetTarget(s.searchTarget)
    e1:SetOperation(s.searchOperation)
    c:RegisterEffect(e1)

    -- Cannot be targeted for attacks if other "Neo-Spacian" or "Neos" monsters are present
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.tgcond)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)

    -- Quick effect to special summon "Elemental HERO Neos"
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptarget)
    e3:SetOperation(s.spoperation)
    c:RegisterEffect(e3)

    -- Additional effect to banish and retrieve a card from the GY
   local e4 = Effect.CreateEffect(c)
   e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_IGNITION)
   e4:SetCode(EVENT_PHASE + PHASE_MAIN1)
   e4:SetRange(LOCATION_GRAVE)
   e4:SetCountLimit(1, id + 100)
   e4:SetOperation(s.banishOperation)
   c:RegisterEffect(e4)
end

-- Material filter for link summoning
function s.matfilter(c)
    return c:IsSetCard(0x1f) or c:IsCode(89943723) -- Filtering for "Neo-Spacian" or "Neos"
end

-- Condition for the "cannot be targeted for attacks" effect
function s.tgcond(e)
    local tp = e:GetHandlerPlayer()
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard, 0x1f), tp, LOCATION_MZONE, 0, nil)
    return g:GetCount() > 0
end

-- Quick effect cost to tribute this card
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(), REASON_COST)
end

-- Quick effect target to special summon "Elemental HERO Neos"
function s.sptarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_GRAVE)
    return true
end

-- Filter for the "Elemental HERO Neos" card
function s.spfilter(c)
    return c:IsCode(89943723) -- Code for "Elemental HERO Neos"
end

-- Quick effect operation to special summon "Elemental HERO Neos"
function s.spoperation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        local tc = g:GetFirst()
        if tc then
            -- Apply effect that prevents attacks this turn
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end

-- Search effect condition
function s.searchCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local seq = c:GetSequence()
    local zone = 0
    if seq and seq < 5 then
        zone = zone | (2 ^ seq)
    end
    local lg = c:GetLinkedGroup()
    if lg:IsExists(function(mc) return mc:IsControler(tp) and mc:IsLocation(LOCATION_MZONE) end, 1, nil) then
        local g = eg:Filter(Card.IsControler, nil, tp)
        return g:IsExists(function(mc) return mc:IsLocation(LOCATION_MZONE) and mc:IsLocation(LOCATION_MZONE) and mc:IsControler(tp) end, 1, nil)
    end
    return false
end


-- Search effect target
function s.searchTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

-- Search effect operation
function s.searchOperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- Filter for searching "Neo Space" Spell, "Neos" Spell, or "Neo-Spacian" cards
function s.filter(c)
    return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsAbleToHand()
end

-- Additional effect function for banishing from GY
function s.banishOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c or not c:IsLocation(LOCATION_GRAVE) then return end
    if not Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then return end
    -- Banish this card from the GY
    Duel.Remove(c, POS_FACEUP, REASON_EFFECT)
    -- Retrieve another "Neo-Spacian", "Neo Space", or "Neos" card from your GY to your hand
    local rg = Duel.SelectMatchingCard(tp, s.retrieveFilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
    if #rg > 0 then
        Duel.SendtoHand(rg, nil, REASON_EFFECT)
    end
end


-- Filter for retrieving another card from the GY to the hand
function s.retrieveFilter(c)
    return (c:IsSetCard(0x1f) or c:IsCode(89943723)) and c:IsAbleToHand()
end