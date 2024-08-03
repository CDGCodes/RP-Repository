local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return eg:GetFirst():GetControler() ~= tp
end

function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x8) -- This is typically the "Elemental HERO" set
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_MZONE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, PLAYER_ALL, 1)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    local ec = eg:GetFirst()
    if ac:GetCount() > 0 then
        local tc = ac:GetFirst()

        -- Both selected monsters cannot be destroyed by battle this turn
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
        
        local e2 = e1:Clone()
        ec:RegisterEffect(e2)

        -- Neither player takes battle damage this turn
        local e3 = Effect.CreateEffect(e:GetHandler())
        e3:SetType(EFFECT_TYPE_FIELD)
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e3:SetCode(EFFECT_CHANGE_DAMAGE)
        e3:SetTargetRange(1, 1)
        e3:SetValue(0)
        e3:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e3, tp)
        
        local e4 = e3:Clone()
        Duel.RegisterEffect(e4, 1 - tp)

        -- Draw 1 card each
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
        Duel.Draw(1 - tp, 1, REASON_EFFECT)
    end
end
