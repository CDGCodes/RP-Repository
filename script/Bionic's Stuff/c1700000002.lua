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
  local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.tdcondition)
	e2:SetTarget(s.tdtarget)
	e2:SetOperation(s.tdoperation)
	c:RegisterEffect(e2)
  Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.spfilter)
end
function s.spfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON)
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not s.spfilter(c) end)
    Duel.RegisterEffect(e1,tp)
end
function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x38) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.AddFilter(c)
    return c:IsCode(77558536) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_HAND|LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_HAND|LOCATION_DECK, 0, 1, 1, nil, e, tp)
    local tc=g:GetFirst()
    if #g>0 and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        tc:NegateEffects(e:GetHandler())
    end
    Duel.SpecialSummonComplete()
end
function s.tdcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and rp==1-tp
end
function s.tdtarget (e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tdoperation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.GetFirstMatchingCard(s.AddFilter,tp,LOCATION_DECK,0,nil)
	if tc~=nil then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end