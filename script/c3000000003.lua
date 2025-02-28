--The Corrupted Wind
local s,id=GetID()
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    c:EnableReviveLimit()

    --Cannot be normal summoned/set
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_SUMMON)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_MSET)
    c:RegisterEffect(e1)

    --Cannot be tribute summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_TRIBUTE_SUMMON)
    c:RegisterEffect(e2)

    --Special summon restriction
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_SPSUMMON_CONDITION)
    e3:SetValue(aux.FALSE)
    c:RegisterEffect(e3)

    --Special summon procedure
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EFFECT_SPSUMMON_PROC)
    e4:SetRange(LOCATION_HAND)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)

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
        Duel.RegisterFlagEffect(ep,3000000002,RESET_PHASE+PHASE_END,0,1,1)
    end
end

--Special summon condition function
function s.spcon(e,c)
    if c==nil then return true end
    local tp=e:GetHandlerPlayer()
    return Duel.GetFlagEffect(tp,3000000002)>0
        and Duel.GetFlagEffectLabel(tp,3000000002)==ATTRIBUTE_WIND
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(2),1,tp,HINTMSG_DESTROY,nil,nil,true)
    if #sg>0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end

--Special summon operation function
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if not g then return end
    Duel.Destroy(g,REASON_COST)
    g:DeleteGroup()
end

--Filter to check WIND attribute monsters on the field, excluding this card
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsDestructable() and not c:IsCode(3000000003)
end
