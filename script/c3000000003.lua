--The Corrupted Wind
local s,id=GetID()
function s.initial_effect(c)
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
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(3000000002) and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
        Duel.RegisterFlagEffect(ep,3000000002,RESET_PHASE+PHASE_END,0,1,ATTRIBUTE_WIND)
    end
end

--Special summon condition function
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(tp,3000000002)>0
        and Duel.GetFlagEffectLabel(tp,3000000002)==ATTRIBUTE_WIND
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,2,nil)
end

--Special summon operation function
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,2,2,nil)
    Duel.Destroy(g,REASON_COST)
end

--Filter to check WIND attribute monsters, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDestructable() and not c:IsCode(3000000003)
end
