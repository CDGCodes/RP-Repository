local s, id = GetID()

function s.initial_effect(c)
    -- XYZ summon
    Xyz.AddProcedure(c, nil, 4, 2)
    c:EnableReviveLimit()

    -- Attach a Pyro monster from hand or graveyard as material
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- Detach 1 material to destroy a spell/trap on the field (once per turn)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription("Detach 1 material to destroy a spell/trap on the field")
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)

    -- Inflict damage to opponent at the end of the turn (based on attached materials)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription("At the end of the turn, inflict damage based on attached materials")
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.damageCondition)
    e3:SetOperation(s.damageOperation)
    c:RegisterEffect(e3)
end

function s.filter(c)
    return c:IsRace(RACE_PYRO)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsRace(RACE_PYRO) and Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil)
    end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.filter), tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.Overlay(c, g)
    end
end

function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.target2(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL + TYPE_TRAP) end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, TYPE_SPELL + TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.operation2(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.Destroy(tc, REASON_EFFECT)
    end
end

function s.damageCondition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp
end

function s.damageOperation(e, tp, eg, ep, ev, re, r, rp)
    local dam = e:GetHandler():GetOverlayCount() * 500
    Duel.Damage(1 - tp, dam, REASON_EFFECT)
end
