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
    e1:SetTarget(s.ftg)
    e1:SetOperation(s.fop)
    c:RegisterEffect(e1)
end
function s.ffilter(c)
    return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function s.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk ==0 then return Duel.IsExistingMatchingCard(s.ffilter, tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, nil) end 
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK|LOCATION_GRAVE)
end
function s.fop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ffilter), tp, LOCATION_DECK|LOCATION_GRAVE, 0, 1, 1,nil)
    if #g >0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, g)
    end
end