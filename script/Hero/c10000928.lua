local s,id=GetID()
function s.initial_effect(c)
    -- Always treated as "Elemental HERO Wildheart"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(86188410)
    c:RegisterEffect(e1)

    -- Special Summon limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.sumlimit)
    c:RegisterEffect(e2)

    -- Special Summon from hand, Quick Effect, in response to Trap activation
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)  -- Quick-Play effect
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- Immunity to Trap effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.immtg)
    e4:SetValue(s.efilter)
    c:RegisterEffect(e4)

    -- ATK boost during Battle Phase
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x8))
    e5:SetCondition(s.atkcon)
    e5:SetValue(300)
    c:RegisterEffect(e5)
end

function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsCode(id) and c:IsLocation(LOCATION_HAND)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and re:IsActiveType(TYPE_TRAP) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x8),tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

function s.immtg(e,c)
    return c:IsSetCard(0x8) and c:IsLevelBelow(7) and not c:IsType(TYPE_FUSION)
end

function s.efilter(e,re)
    return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_TRAP)
end

function s.atkcon(e)
    return Duel.IsBattlePhase()
end
