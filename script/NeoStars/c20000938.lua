local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    
    -- Fusion materials
    Fusion.AddProcMix(c, true, true, 89943723, s.matfilter)
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
    
    -- ATK gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)
    
    -- Special Summon from GY effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BATTLE_DESTROYING)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
    
    -- Name change effect
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_CHANGE_CODE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_ONFIELD + LOCATION_GRAVE)
    e5:SetValue(89943723)
    c:RegisterEffect(e5)
    
    -- Draw effect when Fusion Summoned
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_DRAW)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_SPSUMMON_SUCCESS)
    e6:SetCondition(s.drawcon)
    e6:SetTarget(s.drawtg)
    e6:SetOperation(s.drawop)
    c:RegisterEffect(e6)
end

function s.matfilter(c, sc, sumtype, tp)
    return c:IsLevelBelow(3) and not c:IsType(TYPE_TOKEN)
end

function s.contactfil(tp)
    return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil)
end

function s.contactop(g, tp)
    Duel.ConfirmCards(1-tp, g)
    Duel.SendtoDeck(g, nil, 2, REASON_COST+REASON_MATERIAL)
end

function s.splimit(e, se, sp, st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.tdcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end

function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetMatchingGroupCount(Card.IsType, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, nil, TYPE_SPELL + TYPE_TRAP) > 0
    end
    local g = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_ONFIELD, 0, nil, TYPE_SPELL + TYPE_TRAP)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.SelectMatchingCard(tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
        Duel.Destroy(g, REASON_EFFECT)
    end
end

function s.atkval(e, c)
    return Duel.GetMatchingGroupCount(s.level3orlower, c:GetControler(), LOCATION_MZONE, LOCATION_MZONE, nil) * 200
end

function s.level3orlower(c)
    return c:IsFaceup() and c:IsLevelBelow(3)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsRelateToBattle() and e:GetHandler():IsFaceup()
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local tc = g:GetFirst()
        if tc then
            -- Prevent the summoned monster from attacking this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end


function s.spfilter(c, e, tp)
    return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.drawcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():GetFlagEffect(id) == 0
end

function s.drawtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.drawop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Draw(tp, 1, REASON_EFFECT)
    e:GetHandler():RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000 + RESET_PHASE + PHASE_END, 0, 1)
end
