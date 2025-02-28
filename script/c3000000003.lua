--The Corrupted Wind
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be normal summoned/set
    c:EnableUnsummonable()
    
    --Special summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --Track activation of the card with ID 3000000002 and WIND attribute choice
    if not s.global_check then
        s.global_check=true
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAINING)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end

    --Special summon a WIND attribute monster from the graveyard once per turn during the end phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0)) 
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)

    --Quick effect: Move a WIND monster to the spell and trap zone or vice versa
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.stztg)
    e3:SetOperation(s.stzop)
    c:RegisterEffect(e3)
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(3000000002) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
        Duel.RegisterFlagEffect(ep,3000000002,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,2,ATTRIBUTE_WIND)
    end
end

--Special summon condition function
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(tp,3000000002)>0
        and Duel.GetFlagEffectLabel(tp,3000000002)==ATTRIBUTE_WIND
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
end

--Special summon operation function
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
    Duel.Destroy(g,REASON_COST)
end

--Filter to check WIND attribute monsters on the field, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDestructable() and not c:IsCode(id)
end

--Target function for special summoning WIND attribute monster from the graveyard
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(Card.IsAttribute,tp,LOCATION_GRAVE,0,1,nil,ATTRIBUTE_WIND) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

--Operation function for special summoning WIND attribute monster from the graveyard
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsAttribute,tp,LOCATION_GRAVE,0,1,1,nil,ATTRIBUTE_WIND)
    if g:GetCount()>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

--Target function for moving WIND monster to spell and trap zone or vice versa
function s.stztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_MZONE,0,1,nil)
        or Duel.IsExistingMatchingCard(s.stzfilter,tp,LOCATION_SZONE,0,1,nil) end
end

--Operation function for moving WIND monster to spell and trap zone or vice versa
function s.stzop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
    local g=Duel.SelectMatchingCard(tp,s.stzfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        if tc:IsLocation(LOCATION_MZONE) then
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        else
            Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
        end
    end
end

--Filter for WIND monsters on the field
function s.stzfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_SZONE))
end
