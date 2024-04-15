-- Elemental HERO Neospathian Inferno Panther
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Fusion materials
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 43237273, 89621922) -- Neo-Spacian Dark Panther + Neo-Spacian Flare Scarab
    Fusion.AddContactProc(c, s.contactfil, s.contactop, s.splimit)

    -- Special Summon effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCondition(s.tdcon)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local spellTrapCount = Duel.GetMatchingGroupCount(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL + TYPE_TRAP)
    if chk == 0 then
        return spellTrapCount > 0
    end
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, math.min(spellTrapCount, 5), 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local spellTrapCount = Duel.GetMatchingGroupCount(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL + TYPE_TRAP)
    local g = Duel.GetMatchingGroup(nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    local max_targets = math.min(spellTrapCount, 5)
    if max_targets > 0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg = g:Select(tp,1,max_targets,nil)
        Duel.Destroy(dg, REASON_EFFECT)
        local ct = #dg
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then
            local atk = ct * 400
            if atk > 0 then
                local e1 = Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
                e1:SetValue(atk)
                c:RegisterEffect(e1)
            end
        end
        -- Halve battle damage
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
        e2:SetOperation(s.bdop)
        e2:SetReset(RESET_PHASE + PHASE_DAMAGE)
        Duel.RegisterEffect(e2, tp)
    end
end

function s.bdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.ChangeBattleDamage(tp, Duel.GetBattleDamage(tp) / 2)
    Duel.ChangeBattleDamage(1 - tp, Duel.GetBattleDamage(1 - tp) / 2)
end
