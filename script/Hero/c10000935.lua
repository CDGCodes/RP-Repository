local s, id = GetID()

function s.initial_effect(c)
    -- Name treated as Elemental HERO Avian
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(21844576)  -- Code of "Elemental HERO Burstinatrix"
    c:RegisterEffect(e1)
    
    -- Add "Dark Fusion" or "Dark Calling" from deck or graveyard to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetRange(LOCATION_HAND)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.thcon)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Special Summon from Graveyard by sending 1 "Hero" monster from field or hand to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+100)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsDiscardable() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end

function s.filter(c)
    return c:IsCode(94820406) or c:IsCode(12071500) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.spcfilter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.spcfilter(c)
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
    end
end
