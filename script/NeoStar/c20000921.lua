local s, id = GetID()

function s.initial_effect(c)
    -- Change name to "Neo-Spacian Grand Mole" while on the field, in hand, or in GY
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetValue(80344569) -- Card ID for "Neo-Spacian Grand Mole"
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
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e2:SetTargetRange(1,0)
    e2:SetLabelObject(e1)
    e2:SetCondition(s.sumcon)
    c:RegisterEffect(e2)

    -- Bounce effect on summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)

    -- Fusion Material effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BE_MATERIAL)
    e4:SetCondition(s.matcon)
    e4:SetOperation(s.matop)
    c:RegisterEffect(e4)

    -- Search effect for cards listing "Elemental HERO Neos," "Neos Space," or "Neo-Spacian"
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_DECK)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCondition(s.searchcon)
    e5:SetTarget(s.searchtg)
    e5:SetOperation(s.searchop)
    c:RegisterEffect(e5)
end

-- Special Summon from hand condition
function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
           Duel.GetFlagEffect(tp, id) == 0 and
           (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 89943723), tp, LOCATION_MZONE, 0, 1, nil) or
            Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x1f), tp, LOCATION_MZONE, 0, 1, nil))
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
end

function s.sumcon(e)
    return Duel.GetFlagEffect(e:GetHandlerPlayer(), id) ~= 0
end

-- Bounce target
function s.rettg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand, tp, 0, LOCATION_MZONE, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, 0, LOCATION_MZONE, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
    end
end

-- Fusion material condition and operation
function s.matcon(e, tp, eg, ep, ev, re, r, rp)
    return r & REASON_FUSION ~= 0
end

function s.matop(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    local e1 = Effect.CreateEffect(rc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(89943723) -- Elemental HERO Neos
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    rc:RegisterEffect(e1)
end

-- Search effect condition (activated when this card is returned to the Deck)
function s.searchcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return re and rc and rc:IsType(TYPE_FUSION) and rc:IsSetCard(0x1f) and rc:IsControler(tp)
end

-- Search effect target (cards listing "Elemental HERO Neos," "Neos Space," or "Neo-Spacian")
function s.searchtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.searchfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

-- Search effect operation (add a card that lists "Elemental HERO Neos," "Neos Space," or "Neo-Spacian" to hand)
function s.searchop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

-- Filter for searching cards (listing "Elemental HERO Neos," "Neos Space," or "Neo-Spacian")
function s.searchfilter(c)
    return c:IsAbleToHand() and (c:ListsCard(89943723) or c:ListsCard(0x9) or c:ListsCard(0x1f))
end