-- Define the card's ID
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()  -- Enable Revive Limit

    -- Define fusion materials
    Fusion.AddProcMixN(c, true, true, s.ffilter, 2)
    s.listed_series = {0x8}

    -- Multi-attack effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ATTACK_ALL)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Gain ATK and banish battled monster automatically
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_BATTLE_DESTROYING)
    e2:SetCondition(aux.bdgcon)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Special summon effect with restrictions
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.spcost)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- Damage effect for HERO monsters
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCondition(s.dmgcon_hero)
    e4:SetTarget(s.dmgtg_hero)
    e4:SetOperation(s.dmgop_hero)
    c:RegisterEffect(e4)
end

function s.ffilter(c, fc, sumtype, tp, sub, mg, sg)
    return c:IsLevelAbove(0) and (not sg or not sg:IsExists(s.fusfilter, 1, c, c:GetLevel(), fc, sumtype, tp))
end

function s.fusfilter(c, lv, fc, sumtype, tp)
    return c:GetLevel() == lv
end

function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local bc = e:GetHandler():GetBattleTarget()
    if chk == 0 then return bc and bc:IsAbleToRemove() end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, bc, 1, 0, 0)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local bc = e:GetHandler():GetBattleTarget()
    if bc and Duel.Remove(bc, POS_FACEUP, REASON_EFFECT) ~= 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetTargetRange(LOCATION_MZONE, 0)
        e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard, 0x8))
        e1:SetValue(500)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end

function s.spcost(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(1 - tp, LOCATION_MZONE) <= 0 then return false end
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_REMOVED)
    return g:FilterCount(Card.IsControler, nil, 1 - tp) >= 3
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.spfilter, tp, 0, LOCATION_REMOVED, 1, nil, e, tp)
    end
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(1 - tp, LOCATION_MZONE) <= 0 then return end
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, 0, LOCATION_REMOVED, 1, 3, nil, e, tp)
    if #g > 0 then
        for tc in aux.Next(g) do
            Duel.SpecialSummonStep(tc, 0, tp, 1 - tp, false, false, POS_FACEUP_DEFENSE)
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
        Duel.SpecialSummonComplete()
    end
end

function s.spfilter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE, 1 - tp)
end

function s.dmgcon_hero(e, tp, eg, ep, ev, re, r, rp)
    -- Check if 'eg' is not nil and has at least one card
    if not eg or #eg == 0 then return false end
    
    local dc = eg:GetFirst()
    -- Further check that 'dc' and 'dt' are valid
    if not dc then return false end
    local dt = dc:GetBattleTarget()
    if not dt then return false end
    
    -- Conditions for the effect to trigger
    return dc:IsSetCard(0x8) and dc:IsControler(tp) and
           dt:IsControler(1-tp) and dt:IsDisabled()
end

function s.dmgtg_hero(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, 500)
end

function s.dmgop_hero(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
