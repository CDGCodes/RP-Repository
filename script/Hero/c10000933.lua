-- Shadow Catapulter
-- Card Script

local s, id = GetID()

function s.initial_effect(c)
    c:EnableCounterPermit(0x28)
    c:SetCounterLimit(0x28, 3) -- Max counters set to 3
    -- Special Summon from hand or graveyard by discarding 1 "HERO" monster
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Add Dark Counters during the turn player's standby phase
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE + PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.addccon)
    e2:SetTarget(s.addct)
    e2:SetOperation(s.addc)
    c:RegisterEffect(e2)
    -- Destroy Spells/Traps depending on the number of Dark Counters
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCost(s.descost)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    -- Draw 1 card if 3 Spell/Trap cards were destroyed with this effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.drawcon)
    e4:SetOperation(s.drawop)
    c:RegisterEffect(e4)
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsDiscardable() and Duel.IsExistingMatchingCard(s.heroFilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, s.heroFilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.heroFilter(c)
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8) and c:IsAbleToGrave()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.addccon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and e:GetHandler():IsDefensePos()
end

function s.addct(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_COUNTER, nil, 1, 0, 0x28)
end

function s.addc(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsRelateToEffect(e) then
        e:GetHandler():AddCounter(0x28, 1)
    end
end

function s.descost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ct = e:GetHandler():GetCounter(0x28)
    if chk == 0 then return ct > 0 end
    e:SetLabel(ct) -- Store the counter value for later use
    return true
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = e:GetHandler():GetCounter(0x28)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1 - tp) and chkc:IsType(TYPE_SPELL + TYPE_TRAP) end
    if chk == 0 then return Duel.IsExistingTarget(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, ct, ct, nil, TYPE_SPELL + TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, ct, ct, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, ct, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    if g and #g > 0 then
        Duel.Destroy(g, REASON_EFFECT)
    end
    local ct = e:GetLabel() -- Retrieve the stored counter value
    e:GetHandler():RemoveCounter(tp, 0x28, ct, REASON_EFFECT)
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    local ct = e:GetHandler():GetCounter(0x28)
    return eg:IsExists(Card.IsControler, 1, nil, 1 - tp) and ct >= 3
end

function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Draw(tp, 1, REASON_EFFECT)
end
