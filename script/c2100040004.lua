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

    -- Attack in Defense Position
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DEFENSE_ATTACK)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Flip opponent's monster to face-down Defense Position (Quick Effect)
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_POSITION)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1) -- Once per turn
    e4:SetTarget(s.postg)
    e4:SetOperation(s.posop)
    c:RegisterEffect(e4)

    -- Inflict piercing damage
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e5)

    -- Destroy a face-down Defense Position monster and gain Defense Points
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3)) -- Adjust the string ID as needed
    e6:SetCategory(CATEGORY_DESTROY+CATEGORY_DEFCHANGE)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCountLimit(1) -- Once per turn
    e6:SetCondition(s.descon) -- Add a condition to check the turn
    e6:SetTarget(s.destg)
    e6:SetOperation(s.desop)
    c:RegisterEffect(e6)
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

-- Target function for flipping a monster
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end

-- Operation function for flipping a monster
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,Card.IsCanTurnSet,tp,0,LOCATION_MZONE,1,1,nil)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end

-- Condition to check if it's the controller's End Phase
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return tp==Duel.GetTurnPlayer() -- Only activate during the controller's turn
end

-- Target function for destroying a face-down Defense Position monster
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Filter for opponent's face-down Defense Position monsters
function s.desfilter(c,tp)
    return c:IsFacedown() and c:IsDefensePos() and c:IsDestructable() and c:IsControler(1-tp)
end

-- Operation function for destroying a monster and gaining Defense Points
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        local tc=g:GetFirst()
        if tc and tc:IsLocation(LOCATION_GRAVE) then
            local def=tc:GetDefense()
            local c=e:GetHandler()
            if c:IsFaceup() and c:IsRelateToEffect(e) then
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_DEFENSE)
                e1:SetValue(def)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                c:RegisterEffect(e1)
            end
        end
    end
end
