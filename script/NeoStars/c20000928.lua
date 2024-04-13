local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon from hand or GY if you control "Elemental HERO Neos"
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spSummonCondition)
    e1:SetTarget(s.spSummonTarget)
    e1:SetOperation(s.spSummonOperation)
    c:RegisterEffect(e1)

    -- Protection effect if this card was Special Summoned during your opponent’s turn
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.protectionCondition)
    e2:SetOperation(s.protectionOperation)
    c:RegisterEffect(e2)

    -- Activate Fusion Substitute effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCost(s.substituteCost)
    e3:SetOperation(s.substituteOperation)
    c:RegisterEffect(e3)

    -- Shuffle into Deck when leaving the field
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetOperation(s.shuffleOperation)
    c:RegisterEffect(e4)

    -- Equip to Fusion Monster instead when shuffled into Deck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_EQUIP)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_DECK)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCondition(s.eqCondition)
    e5:SetOperation(s.eqOperation)
    c:RegisterEffect(e5)
    aux.AddEREquipLimit(c, nil, aux.TRUE, s.equipLimit, e5)
    
    -- Flag to prevent re-equip
    c:RegisterFlagEffect(id,RESET_EVENT+0x1fe0000,0,1,0)
end

function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 89943723)
end

function s.spSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spSummonOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.protectionCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.protectionOperation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsSetCard, 0x1f), tp, LOCATION_MZONE, 0, nil)
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end

function s.substituteFilter(c)
    return c:IsSetCard(0x1f) and c:IsAbleToGraveAsCost()
end

function s.substituteCost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.substituteFilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local cg = Duel.SelectMatchingCard(tp, s.substituteFilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    Duel.SendtoGrave(cg, REASON_COST)
    e:SetLabel(cg:GetFirst():GetCode())
end

function s.substituteOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    e1:SetValue(e:GetLabel())
    c:RegisterEffect(e1)
end

function s.shuffleOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:ResetFlagEffect(id)  -- Reset flag when shuffled back to deck
    if c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SPECIAL) then
        Duel.SendtoDeck(c, nil, 2, REASON_EFFECT)
    end
end

function s.eqCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) == 0 and c:IsLocation(LOCATION_DECK) and c:GetPreviousLocation() ~= LOCATION_SZONE and c:IsPreviousPosition(POS_FACEUP)
end

function s.eqOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id) == 0 and c:IsLocation(LOCATION_DECK) and c:GetPreviousLocation() ~= LOCATION_SZONE then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
        local g = Duel.SelectMatchingCard(tp, Auxiliary.FaceupFilter(Card.IsType, TYPE_FUSION), tp, LOCATION_MZONE, 0, 1, 1, nil)
        local tc = g:GetFirst()
        if tc and Duel.Equip(tp, c, tc) then
            -- Set equip limit
            local e1 = Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_EQUIP_LIMIT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            e1:SetValue(s.eqlimit)
            e1:SetLabelObject(tc)
            c:RegisterEffect(e1)

            -- Additional flags for equipped monster effects here...

            c:SetFlagEffect(id,RESET_EVENT+0x1fe0000,0,1) -- Set the flag to prevent re-equip
        end
    end
end

function s.equipLimit(c, e, tp, tc)
    return tc:IsControler(tp) and tc:IsType(TYPE_FUSION)
end

function s.eqlimit(e, c)
    return c == e:GetLabelObject()
end

function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) and eg:IsContains(e:GetHandler():GetEquipTarget())
    end
    return true
end

function s.repop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Destroy(e:GetHandler(), REASON_EFFECT + REASON_REPLACE)
end
