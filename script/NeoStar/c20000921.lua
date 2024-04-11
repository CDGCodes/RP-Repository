local s, id = GetID()
function s.initial_effect(c)
    -- Effect to change the card's name to "Neo-Spacian Grand Mole"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(80344569) -- The card ID for "Neo-Spacian Grand Mole"
    c:RegisterEffect(e1)

    -- Conditional Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Summon once per turn
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetRange(LOCATION_HAND)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.sumlimit)
    c:RegisterEffect(e3)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x1f),tp,LOCATION_MZONE,0,1,nil)
       or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x9),tp,LOCATION_MZONE,0,1,nil)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
end

function s.sumlimit(e,c)
    return c:IsCode(id) and c:GetFlagEffect(id)>0
end
