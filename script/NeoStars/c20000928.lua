-- Neo-Spacian Pure Core
local s, id = GetID()

function s.initial_effect(c)
    -- Special Summon from hand or GY if you control "Elemental HERO Neos"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.spSummonCondition)
    e1:SetTarget(s.spSummonTarget)
    e1:SetOperation(s.spSummonOperation)
    c:RegisterEffect(e1)

    -- Protection effect if this card was Special Summoned during your opponent’s turn
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.protectionCondition)
    e2:SetOperation(s.protectionOperation)
    c:RegisterEffect(e2)

    -- Activate Fusion Substitute effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.substituteTarget)
    e3:SetOperation(s.substituteOperation)
    c:RegisterEffect(e3)

    -- Shuffle into Deck when leaving the field
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetOperation(s.shuffleOperation)
    c:RegisterEffect(e4)
end

-- Check if you control "Elemental HERO Neos"
function s.spSummonCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 89943723)
end

-- Special Summon from hand or GY
function s.spSummonTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spSummonOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- Protection effect if this card was Special Summoned during your opponent’s turn
function s.protectionCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= e:GetHandlerPlayer() and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.protectionOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsSetCard, tp, LOCATION_MZONE, 0, nil, 0x1f)
    for tc in aux.Next(g) do
        -- Apply the protection effect
        local e1 = Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end

-- Activate Fusion Substitute effect
function s.substituteTarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

-- Fusion Substitute effect operation
function s.substituteOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    -- Select a Neo-Spacian monster
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local code = Duel.AnnounceCard(tp, 0x1f)
    local card = Duel.CreateToken(tp, code)
    -- Copy the selected Neo-Spacian monster's name
    if card then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        e1:SetValue(code)
        c:RegisterEffect(e1)
    end
end

-- Shuffle into Deck when leaving the field if Special Summoned
function s.shuffleOperation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsPreviousPosition(POS_FACEUP) and c:IsSummonType(SUMMON_TYPE_SPECIAL) then
        Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
    end
end
