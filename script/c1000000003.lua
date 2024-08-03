--Stuffed Kuriboh
local s,id=GetID()
function s.initial_effect(c)
    -- Tribute this card; Add 1 Ritual Monster and Ritual Spell from your Deck or GY to your hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

-- Cost function to tribute this card
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Updated filter to separate Ritual Monster and Ritual Spell
function s.thfilter(c,tp)
    return c:IsType(TYPE_RITUAL) and c:IsAbleToHand() and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL))
end

-- Updated target function to include both Ritual Monster and Ritual Spell
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)
        and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end

-- Updated operation function to select and add both Ritual Monster and Ritual Spell
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp)
    g1:Merge(g2)
    if #g1>0 then
        Duel.SendtoHand(g1,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g1)
    end
end
