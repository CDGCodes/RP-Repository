--The Corrupted Earth
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    c:AddMustBeSpecialSummonedByCardEffect()

    -- Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Track activation of "Soul Corruption" and EARTH attribute declaration
    aux.GlobalCheck(s,function()
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_CHAIN_SOLVED)
        ge1:SetOperation(s.checkop)
        Duel.RegisterEffect(ge1,0)
    end)

    -- Disable field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_DISABLE_FIELD)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
end

-- Track "Soul Corruption" activation and EARTH declaration
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    if re:GetHandler():IsCode(2100040002) then -- Assuming "Soul Corruption" has this ID
        Duel.RegisterFlagEffect(rp,id,0,0,0,Duel.GetFlagEffectLabel(1,2100040002))
    end
end

-- Special Summon condition function
function s.spcon(e)
    local c=e:GetHandler()
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil)
        and ((Duel.HasFlagEffect(tp,id) and Duel.GetFlagEffectLabel(tp,id)==ATTRIBUTE_EARTH) 
        or (Duel.HasFlagEffect(1-tp,id) and Duel.GetFlagEffectLabel(1-tp,id)==ATTRIBUTE_EARTH))
end

-- Special Summon target function
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end

-- Special Summon operation function
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_MZONE,0,2,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_MZONE,0,2,2,nil)
        if Duel.Destroy(g,REASON_COST)~=2 then return end
    end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Filter for EARTH monsters to destroy as cost
function s.spcostfilter(c)
    return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsDestructable() and not c:IsCode(id)
end

-- Disable field operation
function s.disop(e,tp)
    local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)
    if c==0 then return end
    local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
    if c>1 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,dis1)
        dis1=(dis1|dis2)
    end
    return dis1
end