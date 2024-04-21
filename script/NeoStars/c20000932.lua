local s, id = GetID()

function s.initial_effect(c)
    -- XYZ summon
    c:EnableReviveLimit()
    Xyz.AddProcedure(c, nil, 3, 2, nil, nil, 5)

    -- Special Summon "Neo STAR Token"
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(2, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Copy effect of a "Neo-Spacian" monster
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id+1)
    e2:SetTarget(s.cptarget)
    e2:SetOperation(s.cpoperation)
    c:RegisterEffect(e2)

    -- Attach a Level 3 "Neo-Spacian" Monster from hand, GY, or that is banished
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id+2)
    e3:SetCondition(s.xyzcon)
    e3:SetTarget(s.xyztg)
    e3:SetOperation(s.xyzop)
    c:RegisterEffect(e3)

    -- New effect: Tribute and Special Summon "Elemental HERO Neos"
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, id+3)
    e4:SetCondition(s.neoscon)
    e4:SetCost(s.neoscost)
    e4:SetTarget(s.neostg)
    e4:SetOperation(s.neosop)
    c:RegisterEffect(e4)
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
        return ft > 0 and Duel.IsPlayerCanSpecialSummonMonster(tp, 20000933, 0, 0x4011, 400, 400, 1, RACE_THUNDER, ATTRIBUTE_LIGHT)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_MZONE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local token = Duel.CreateToken(tp, 20000933)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP)
end

function s.filter(c)
    return c:IsSetCard(0x1f) and c:IsAbleToGrave() and c:IsLevel(3)
end

function s.cptarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, nil)
           and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsControler, tp), tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end

function s.cpoperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_HAND+LOCATION_DECK, 0, 1, 1, nil)
    local nc = g:GetFirst()
    if not nc or Duel.SendtoGrave(nc, REASON_EFFECT) == 0 or not nc:IsLocation(LOCATION_GRAVE) then return end
    
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tg = Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsControler, tp), tp, LOCATION_MZONE, 0, 1, 1, nil)
    local tc = tg:GetFirst()
    if not tc then return end

    local code = nc:GetOriginalCode()
    tc:CopyEffect(code, RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 1)
    
    -- Change the name of the target monster
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(code)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end

function s.xyzfilter(c)
    return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsLevel(3) and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_REMOVED))
end

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer() == tp and e:GetHandler():IsType(TYPE_XYZ)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.xyzfilter, tp, LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, nil)
    end
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.SelectMatchingCard(tp, s.xyzfilter, tp, LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        Duel.Overlay(e:GetHandler(), tc)
    end
end

function s.neosfilter(c, tp)  -- Ensure tp is explicitly referenced
    return (c:IsSetCard(0x1f) or c:GetCode() == 20000933) and c:IsControler(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end

function s.neoscon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer() == tp
end

function s.neoscost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return Duel.CheckReleaseGroup(tp, s.neosfilter, 2, nil, tp)  -- Pass tp explicitly to the filter
    end
    local g = Duel.SelectReleaseGroup(tp, s.neosfilter, 2, 2, nil, tp)
    Duel.Release(g, REASON_COST)
end

function s.neostg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE)>0 and
               Duel.IsExistingMatchingCard(s.neofilter, tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_GRAVE)
end
function s.neofilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and c:IsCode(89943723)
end

function s.neosop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(Card.IsCode), tp, LOCATION_HAND+LOCATION_GRAVE, 0, 1, 1, nil, 89943723)
    if #g > 0 then
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CANNOT_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        g:GetFirst():RegisterEffect(e1)
    end
end
