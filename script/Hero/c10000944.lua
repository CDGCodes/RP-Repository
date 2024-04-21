local s, id = GetID()

function s.initial_effect(c)
    -- Activate: Target and banish cards equal to the number of "Evil HERO" cards you control
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- Destroy replace effect from GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end

function s.evilherocount(tp)
    return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard, 0x6008), tp, LOCATION_MZONE, 0, nil)
end

function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = s.evilherocount(tp)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
    if chk==0 then
        return ct > 0 and Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, ct, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    end
end

function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
        and c:IsSetCard(0x6008) and not c:IsReason(REASON_REPLACE)
        and c:IsReason(REASON_BATTLE + REASON_EFFECT)
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
    return Duel.SelectEffectYesNo(tp, e:GetHandler(), 96)
end

function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_EFFECT)
end
