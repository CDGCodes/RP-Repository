local s, id = GetID()

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- Increase ATK/DEF
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetTarget(s.atktg)
    e2:SetValue(1000)
    c:RegisterEffect(e2)
    local e3 = e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)
    
    -- "Neos" Fusions do not return to the Extra Deck
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(42015635)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	c:RegisterEffect(e4)
    
    -- Treat as "Neo Space"
    local e6 = Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_ALL)
    e6:SetCode(EFFECT_ADD_CODE)
    e6:SetValue(42015635)  -- Neo Space's ID
    c:RegisterEffect(e6)
    
     
    -- Quick Effect
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,0))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_SZONE)
    e7:SetCountLimit(1, id)
    e7:SetCondition(s.condition)
    e7:SetCost(s.cost)
    e7:SetTarget(s.target)
    e7:SetOperation(s.operation)
    c:RegisterEffect(e7)
end

-- Activation condition for ATK/DEF boost
function s.atkcon(e)
    return Duel.IsBattlePhase()
end

-- Targeting filter for ATK/DEF boost
function s.atktg(e, c)
    return c:IsSetCard(0x1f) and c:IsLevel(3)
end

function s.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsSetCard(0x9) and c:IsAbleToExtraAsCost() -- Assuming "Neos" fusions are correctly tagged with SetCard
end

function s.spfilter(c, e, tp)
    return (c:IsCode(89943723) or c:IsSetCard(0x1f)) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

-- Condition to activate the quick effect
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return true
end

-- Cost: Return 1 "Neos" Fusion Monster to the Extra Deck
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoDeck(g, nil, 0 , REASON_COST)
    end
end

-- Target for special summon
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, nil, 1, tp, LOCATION_MZONE)
end

-- Operation to special summon
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.spfilter), tp, LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if g:GetCount() > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        -- Attack restriction implementation
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetTargetRange(1, 0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end