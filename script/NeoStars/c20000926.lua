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
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- Search effect when sent from hand/deck to GY
    local e4 = e3:Clone()
    e4:SetCode(EVENT_TO_GRAVE)
    c:RegisterEffect(e4)
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

function s.searchfilter(c)
    return c:IsAbleToHand() and (c:IsCode(89943723) or c:IsSetCard(0x9) or c:IsSetCard(0x1f))
end