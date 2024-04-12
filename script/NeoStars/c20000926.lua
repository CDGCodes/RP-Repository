local s, id = GetID()

function s.initial_effect(c)
    -- Change name to "Neo-Spacian Glow Moss" while on the field, in hand, or in GY
    local e0 = Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE + LOCATION_HAND + LOCATION_GRAVE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetValue(17732278) -- Card ID for "Neo-Spacian Glow Moss"
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
    c:RegisterEffect(e1)

    -- Banish top card on Special Summon and draw if Spell/Trap
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Search effect when leaving the field
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_DECK)
    e4:SetOperation(s.leave)
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
function s.spcon(e,c)
    if c==nil then return true end
    local tp = c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
        (Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsCode,89943723),tp,LOCATION_MZONE,0,1,nil) or
        Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsSetCard,0x1f),tp,LOCATION_MZONE,0,1,nil))
end

function s.spsumcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 1-tp, LOCATION_DECK)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Remove(Duel.GetDecktopGroup(1-tp,1), POS_FACEUP, REASON_EFFECT)~=0 then
        local tc=Duel.GetOperatedGroup():GetFirst()
        if tc and tc:IsType(TYPE_SPELL+TYPE_TRAP) then
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE) or c:IsPreviousLocation(LOCATION_HAND) or c:IsPreviousLocation(LOCATION_DECK)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.searchfilter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND + CATEGORY_SEARCH, nil, 1, tp, LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end

-- Search effect when leaving the field or sent from hand/deck to graveyard
function s.leaveCondition(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.leave(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsReason(REASON_EFFECT) and e:GetHandler():IsReason(REASON_COST) then return end
    if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
        local g = Duel.SelectMatchingCard(tp, s.searchfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    end
end

-- Filter for searching cards (listing "Elemental HERO Neos," "Neos Space," or "Neo-Spacian")
function s.searchfilter(c)
    return c:IsAbleToHand() and (c:IsCode(89943723) or c:IsSetCard(0x9) or c:IsSetCard(0x1f))
end