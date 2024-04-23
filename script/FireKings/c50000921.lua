local s,id=GetID()
function s.initial_effect(c)
    -- Continuous Trap Card
    c:SetUniqueOnField(1,0,id)
    
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- Trigger effect once per turn
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.descon)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    e1:SetCountLimit(1, id)
    c:RegisterEffect(e1)
end

function s.cfilter(c,tp)
    return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
        and c:IsPreviousControler(tp) and c:IsSetCard(0x81)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter, 1, nil, tp)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local ct=1
    if Duel.IsExistingMatchingCard(s.garunixfilter, tp, LOCATION_ONFIELD, 0, 1, nil) then
        ct=2
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct, nil)
    if #dg>0 then
        Duel.Destroy(dg, REASON_EFFECT)
    end
end

function s.garunixfilter(c)
    return c:IsFaceup() and c:IsCode(23015696)  -- Corrected ID for Fire King High Avatar Garunix
end
