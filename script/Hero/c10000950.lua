local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Fusion material
    Fusion.AddProcMix(c,true,true,aux.FilterBoolFunction(Card.IsSetCard,0x8),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK))

    -- Change original ATK/DEF
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- Destroy monsters
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Special Summon from Deck/GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.spcon)
    e4:SetTarget(s.sptg)
    e4:SetOperation(s.spop)
    c:RegisterEffect(e4)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=c:GetMaterial()
    local val=0
    for tc in aux.Next(g) do
        local a=tc:GetAttack()
        if a < 0 then a = 0 end
        val = val + a
    end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
    c:RegisterEffect(e1)

    local def = 0
    for tc in aux.Next(g) do
        local d=tc:GetDefense()
        if d < 0 then d = 0 end
        def = def + d
    end
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(def)
    c:RegisterEffect(e2)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
    local g = Duel.GetMatchingGroup(Card.IsDestructable, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, g:GetCount(), 0, 0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(function(card) return card:IsFaceup() and card:GetAttack() <= c:GetAttack() and card:IsDestructable() end, tp, 0, LOCATION_MZONE, nil)
    if g:GetCount() > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_BATTLE+REASON_EFFECT~=0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Ensure there's room for the Special Summon and check if there is a valid Special Summon target
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0 
               and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK+LOCATION_GRAVE)
end

function s.spfilter(c, e, tp)
    -- Ensure c can be Special Summoned with the current effect in play
    return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end


function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, function(c) return s.spfilter(c, e, tp) end, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        -- Negate its effects
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end
