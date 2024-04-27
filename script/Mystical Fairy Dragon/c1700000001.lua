--Mystical Fairy Dragon
local s, id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunction(Card.IsCode, 25862681),1,1)
    --Summon Effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.ftg)
    e1:SetOperation(s.fop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
function s.ffilter(c)
    return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK|LOCATION_GRAVE)
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.ffilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ffilter), tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1,nil)
        if #g >0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
           Duel.ConfirmCards(1-tp, g)
        end
    end
end
function s.spfilter(c,e,tp)
    return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(ev)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and tg and tg:IsContains(c) and re:GetHandler():IsType(TYPE_FIELD) and Duel.IsChainDisablable(ev)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND|LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g>0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end