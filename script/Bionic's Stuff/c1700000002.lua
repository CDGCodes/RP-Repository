--Raiden, Hand of the Twlightsworn
local s, id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Link.AddProcedure(c, aux.FilterBoolFunction(Card.IsSetCard, 0x38), 1, 1, nil, nil)
  --Summon Effect
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
  e1:SetCountLimit(1,{id,0})
  e1:SetTarget(s.sptg)
  e1:SetOperation(s.spop)
  e1:SetCost(s.spcost)
  c:RegisterEffect(e1)
  Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.spfilter)
end
function s.spfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)
    end
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK) end)
    Duel.RegisterEffect(e1,tp)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x38) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND|LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND|LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g>0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end