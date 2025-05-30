-- Neo-Spacian Dark Panther
local s, id = GetID()

function s.initial_effect(c)
    -- Change name to "Neo-Spacian Dark Panther" while on the field, in hand, or in GY
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE + LOCATION_HAND + LOCATION_GRAVE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetValue(43237273) -- Card ID for "Neo-Spacian Dark Panther"
    c:RegisterEffect(e0)

    -- Special Summon condition
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Special Summon limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e2:SetTargetRange(1, 0)
    e2:SetLabelObject(e1)
    e2:SetCondition(s.sumcon)
    c:RegisterEffect(e2)

    -- Negate effect on summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e3:SetTarget(s.negtgt)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- Search effect when leaving the field or sent from hand/deck to graveyard
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_DECK)
    e4:SetOperation(s.leave)
    e4:SetTarget(s.leavetarget)
    c:RegisterEffect(e4)

    local e5 = e4:Clone()
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetCondition(s.leaveCondition)
    c:RegisterEffect(e5)

    local e6 = e4:Clone()
    e6:SetCode(EVENT_LEAVE_FIELD)
    c:RegisterEffect(e6)
end

-- Special Summon from hand condition
function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.GetFlagEffect(tp, id) == 0 and
               (Duel.IsExistingMatchingCard(s.faceupFilter, tp, LOCATION_MZONE, 0, 1, nil) or
                   Duel.IsExistingMatchingCard(s.setCardFilter, tp, LOCATION_MZONE, 0, 1, nil))
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
end

function s.sumcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(), id) ~= 0
end

-- Negate effect target
function s.negtgt(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_STANDBY, 2)
        tc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_STANDBY, 2)
        tc:RegisterEffect(e2)
    end
end

-- Search effect when leaving the field or sent from hand/deck to graveyard
function s.leaveCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.leavetarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.leave(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- Filter for searching cards (listing "Elemental HERO Neos," "Neos Space," or "Neo-Spacian")
function s.searchfilter(c)
    return c:IsAbleToHand() and (c:IsCode(89943723) or c:IsSetCard(0x9) or c:IsSetCard(0x1f))
end

-- Filter for face-up cards with specific condition
function s.faceupFilter(c)
    return c:IsFaceup() and (c:IsCode(89943723) or c:IsSetCard(0x1f))
end

-- Filter for cards with a specific set
function s.setCardFilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x9) or c:IsSetCard(0x1f))
end
