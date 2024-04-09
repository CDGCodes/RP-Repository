local s, id = GetID()
function s.initial_effect(c)
    -- Fusion Materials
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c, true, true, s.ffilter, 2)
    
    -- Special Summon Condition
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    -- Cannot be targeted or destroyed by opponent's card effects
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Draw Cards
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.drcon)
    e3:SetTarget(s.drtg)
    e3:SetOperation(s.drop)
    c:RegisterEffect(e3)

    -- Special Summon from GY or hand when leaves field
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetCondition(s.spcon2)
    e4:SetTarget(s.sptg2)
    e4:SetOperation(s.spop2)
    c:RegisterEffect(e4)

    -- Attack while in Defense Position using DEF for damage calculation
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DEFENSE_ATTACK)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    -- DEF gain per HERO monster in the GY
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)  -- Applied only to itself
    e7:SetCode(EFFECT_UPDATE_DEFENSE)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e7:SetRange(LOCATION_MZONE)
    e7:SetValue(s.defval)
    c:RegisterEffect(e7)
end

function s.ffilter(c, fc, sumtype, tp)
    return c:IsCode(79979666, 84327329) and c:IsType(TYPE_MONSTER, fc, sumtype, tp)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.spfilter(c)
    return c:IsCode(79979666, 84327329) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeckOrExtraAsCost()
end

function s.drcon(e)
    return Duel.IsTurnPlayer(e:GetHandlerPlayer())
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(Auxiliary.FaceupFilter(Card.IsSetCard,0x8),tp,LOCATION_MZONE,0,nil)
    if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(ct)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
    local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
    if ct>0 then
        Duel.Draw(p,ct,REASON_EFFECT)
    end
end

function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
        Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spfilter2(c,e,tp)
    return c:IsLevelBelow(4) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.defval(e,c)
    return Duel.GetMatchingGroupCount(Auxiliary.FaceupFilter(Card.IsSetCard,0x8),e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*200
end